import Foundation

@MainActor
@Observable
final class DealListViewModel {
    var deals: [Deal] = []
    var isLoading = false
    var error: String?

    // New deal form
    var showNewDealSheet = false
    var newCompanyName = ""
    var newContactName = ""
    var newContactRole = ""

    private let dealService: DealService
    private let userId: UUID

    init(dealService: DealService, userId: UUID) {
        self.dealService = dealService
        self.userId = userId
    }

    func loadDeals() async {
        isLoading = true
        do {
            deals = try await dealService.fetchDeals(userId: userId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func createDeal() async -> Deal? {
        let trimmedCompany = newCompanyName.trimmingCharacters(in: .whitespaces)
        guard !trimmedCompany.isEmpty else {
            error = "Company name is required."
            return nil
        }

        let deal = Deal(
            id: UUID(),
            userId: userId,
            companyName: trimmedCompany,
            contactName: newContactName.trimmingCharacters(in: .whitespaces),
            contactRole: newContactRole.trimmingCharacters(in: .whitespaces),
            stage: .discovery,
            outcome: nil,
            notes: nil,
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            let saved = try await dealService.createDeal(deal)
            deals.insert(saved, at: 0)
            resetNewDealForm()
            return saved
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }

    func deleteDeal(_ deal: Deal) async {
        do {
            try await dealService.deleteDeal(id: deal.id)
            deals.removeAll { $0.id == deal.id }
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func resetNewDealForm() {
        newCompanyName = ""
        newContactName = ""
        newContactRole = ""
        showNewDealSheet = false
    }
}
