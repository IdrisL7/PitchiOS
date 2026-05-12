import Foundation
import StoreKit

@MainActor
@Observable
final class PurchaseService {
    enum PurchaseError: LocalizedError {
        case failedVerification

        var errorDescription: String? {
            switch self {
            case .failedVerification:
                return "We could not verify this purchase. Please try again."
            }
        }
    }

    static let soloMonthlyProductID = "com.pitchos.solo.monthly"
    static let proMonthlyProductID = "com.pitchos.pro.monthly"
    static let legacySoloMonthlyProductID = "com.pitchos.PitchOS.solo.monthly"
    static let legacyProMonthlyProductID = "com.pitchos.PitchOS.pro.monthly"

    private static let productIDs = [
        soloMonthlyProductID,
        proMonthlyProductID,
        legacySoloMonthlyProductID,
        legacyProMonthlyProductID
    ]

    var products: [StoreKit.Product] = []
    var purchasedPlan: UserPlan?
    var isLoading = false
    var isPurchasing = false
    var error: String?
    var loadMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()
    }

    func loadProducts(forceReload: Bool = false) async {
        guard forceReload || products.isEmpty else { return }

        isLoading = true
        error = nil
        loadMessage = nil
        do {
            let loadedProducts = try await StoreKit.Product.products(for: Self.productIDs)
            products = loadedProducts.sorted { lhs, rhs in
                Self.sortIndex(for: lhs.id) < Self.sortIndex(for: rhs.id)
            }
            if products.isEmpty {
                self.loadMessage = "Subscription options are loading from the App Store."
            }
            await refreshPurchasedPlan()
        } catch {
            self.loadMessage = "Subscription options are loading from the App Store."
        }
        isLoading = false
    }

    func purchase(_ product: StoreKit.Product) async throws -> UserPlan? {
        isPurchasing = true
        error = nil
        defer { isPurchasing = false }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            let plan = Self.plan(for: transaction.productID)
            purchasedPlan = plan
            return plan
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    func restorePurchases() async throws -> UserPlan? {
        try await AppStore.sync()
        await refreshPurchasedPlan()
        return purchasedPlan
    }

    func refreshPurchasedPlan() async {
        var bestPlan: UserPlan?

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result),
                  let plan = Self.plan(for: transaction.productID)
            else { continue }

            if bestPlan == nil || plan.priority > bestPlan!.priority {
                bestPlan = plan
            }
        }

        purchasedPlan = bestPlan
    }

    static func plan(for productID: String) -> UserPlan? {
        switch productID {
        case soloMonthlyProductID, legacySoloMonthlyProductID:
            return .solo
        case proMonthlyProductID, legacyProMonthlyProductID:
            return .pro
        default: return nil
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                guard let transaction = try? checkVerified(result) else { continue }
                purchasedPlan = Self.plan(for: transaction.productID)
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private static func sortIndex(for productID: String) -> Int {
        switch productID {
        case soloMonthlyProductID, legacySoloMonthlyProductID:
            return 0
        case proMonthlyProductID, legacyProMonthlyProductID:
            return 1
        default: return Int.max
        }
    }
}

private extension UserPlan {
    var priority: Int {
        switch self {
        case .free: return 0
        case .solo: return 1
        case .pro: return 2
        case .team: return 3
        }
    }
}
