import Foundation

@MainActor
@Observable
final class DealDetailViewModel {
    var deal: Deal
    var showEditSheet = false
    var isSaving = false
    var error: String?

    // Edit state (bound to DealEditSheet)
    var editStage: DealStage
    var editOutcome: DealOutcome?

    private let dealService: DealService

    init(deal: Deal, dealService: DealService) {
        self.deal = deal
        self.editStage = deal.stage
        self.editOutcome = deal.outcome
        self.dealService = dealService
    }

    func openEdit() {
        editStage = deal.stage
        editOutcome = deal.outcome
        showEditSheet = true
    }

    func saveEdit() async {
        isSaving = true
        error = nil

        var updated = deal
        updated.stage = editStage
        updated.outcome = editOutcome
        updated.updatedAt = Date()

        do {
            deal = try await dealService.updateDeal(updated)
            showEditSheet = false
            HapticService.shared.generationComplete()
        } catch {
            self.error = error.localizedDescription
            HapticService.shared.error()
        }

        isSaving = false
    }
}
