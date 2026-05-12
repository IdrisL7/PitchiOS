import Foundation
@preconcurrency import StoreKit

struct SubscriptionProduct: Identifiable {
    let id: String
    let displayName: String
    let displayPrice: String
    let plan: UserPlan
    fileprivate let storeKitProduct: StoreKit.Product?
    fileprivate let legacyProduct: SKProduct?
}

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
        proMonthlyProductID
    ]

    private static let knownProductIDs = [
        soloMonthlyProductID,
        proMonthlyProductID,
        legacySoloMonthlyProductID,
        legacyProMonthlyProductID
    ]

    var products: [StoreKit.Product] = []
    var offers: [SubscriptionProduct] = []
    var purchasedPlan: UserPlan?
    var isLoading = false
    var isPurchasing = false
    var error: String?
    var loadMessage: String?
    var loadAttemptCount = 0

    private var updatesTask: Task<Void, Never>?
    private let legacyPaymentCoordinator = LegacyPaymentCoordinator()

    init() {
        updatesTask = listenForTransactions()
    }

    func loadProducts(forceReload: Bool = false) async {
        guard forceReload || offers.isEmpty else { return }

        isLoading = true
        error = nil
        loadMessage = nil
        loadAttemptCount = 0
        defer { isLoading = false }

        let maxAttempts = forceReload ? 8 : 5
        for attempt in 1...maxAttempts {
            loadAttemptCount = attempt

            do {
                let loadedProducts = try await StoreKit.Product.products(for: Self.productIDs)
                products = loadedProducts.sorted { lhs, rhs in
                    Self.sortIndex(for: lhs.id) < Self.sortIndex(for: rhs.id)
                }
                offers = products.map(Self.offer)

                if !offers.isEmpty {
                    loadMessage = nil
                    await refreshPurchasedPlan()
                    return
                }
            } catch {
                products = []
                offers = []
            }

            let legacyProducts = await LegacyProductsLoader.load(productIDs: Set(Self.productIDs))
            if !legacyProducts.isEmpty {
                products = []
                offers = legacyProducts
                    .sorted { Self.sortIndex(for: $0.productIdentifier) < Self.sortIndex(for: $1.productIdentifier) }
                    .map(Self.offer)
                loadMessage = nil
                await refreshPurchasedPlan()
                return
            }

            if attempt < maxAttempts {
                loadMessage = "Checking subscription options with the App Store."
                try? await Task.sleep(for: .seconds(2))
            }
        }

        loadMessage = "Subscription options are still syncing with the App Store. Please try Reload Subscriptions shortly."
        await refreshPurchasedPlan()
    }

    func purchase(_ offer: SubscriptionProduct) async throws -> UserPlan? {
        if let storeKitProduct = offer.storeKitProduct {
            return try await purchase(storeKitProduct)
        }

        if let legacyProduct = offer.legacyProduct {
            return try await purchaseLegacy(legacyProduct)
        }

        return nil
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

    private func purchaseLegacy(_ product: SKProduct) async throws -> UserPlan? {
        isPurchasing = true
        error = nil
        defer { isPurchasing = false }

        guard SKPaymentQueue.canMakePayments() else { return nil }

        guard let productID = try await legacyPaymentCoordinator.purchase(product) else { return nil }
        guard let plan = Self.plan(for: productID) else { return nil }
        purchasedPlan = plan
        return plan
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
        default:
            return knownProductIDs.firstIndex(of: productID) ?? Int.max
        }
    }

    private static func offer(for product: StoreKit.Product) -> SubscriptionProduct {
        let plan = plan(for: product.id) ?? .solo
        return SubscriptionProduct(
            id: product.id,
            displayName: product.displayName.isEmpty ? plan.displayName : product.displayName,
            displayPrice: product.displayPrice,
            plan: plan,
            storeKitProduct: product,
            legacyProduct: nil
        )
    }

    private static func offer(for product: SKProduct) -> SubscriptionProduct {
        let plan = plan(for: product.productIdentifier) ?? .solo
        return SubscriptionProduct(
            id: product.productIdentifier,
            displayName: product.localizedTitle.isEmpty ? plan.displayName : product.localizedTitle,
            displayPrice: legacyPriceString(for: product),
            plan: plan,
            storeKitProduct: nil,
            legacyProduct: product
        )
    }

    private static func legacyPriceString(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? product.price.stringValue
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

@MainActor
private final class LegacyProductsLoader: NSObject, @preconcurrency SKProductsRequestDelegate {
    private var continuation: CheckedContinuation<[SKProduct], Never>?
    private var request: SKProductsRequest?

    static func load(productIDs: Set<String>) async -> [SKProduct] {
        let loader = LegacyProductsLoader()
        return await loader.load(productIDs: productIDs)
    }

    private func load(productIDs: Set<String>) async -> [SKProduct] {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            let request = SKProductsRequest(productIdentifiers: productIDs)
            self.request = request
            request.delegate = self
            request.start()
        }
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        finish(response.products)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        finish([])
    }

    private func finish(_ products: [SKProduct]) {
        continuation?.resume(returning: products)
        continuation = nil
        request = nil
    }
}

private enum LegacyPurchaseError: LocalizedError {
    case failed

    var errorDescription: String? {
        "The purchase could not be completed. Please try again."
    }
}

@MainActor
private final class LegacyPaymentCoordinator: NSObject, @preconcurrency SKPaymentTransactionObserver {
    private var continuation: CheckedContinuation<String?, Error>?
    private var productID: String?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func purchase(_ product: SKProduct) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            productID = product.productIdentifier
            SKPaymentQueue.default().add(SKPayment(product: product))
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard let productID else { return }

        for transaction in transactions where transaction.payment.productIdentifier == productID {
            switch transaction.transactionState {
            case .purchased, .restored:
                queue.finishTransaction(transaction)
                finish(returning: transaction.payment.productIdentifier)
            case .failed:
                queue.finishTransaction(transaction)
                if let error = transaction.error as? SKError, error.code == .paymentCancelled {
                    finish(returning: nil)
                } else {
                    finish(throwing: transaction.error ?? LegacyPurchaseError.failed)
                }
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        }
    }

    private func finish(returning productID: String?) {
        continuation?.resume(returning: productID)
        continuation = nil
        self.productID = nil
    }

    private func finish(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
        productID = nil
    }
}
