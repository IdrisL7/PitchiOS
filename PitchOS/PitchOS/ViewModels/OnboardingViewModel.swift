import Foundation

@MainActor
@Observable
final class OnboardingViewModel {
    // Step 1: Name & Role
    var name = ""
    var role = ""

    // Step 2: Product
    var product = ""

    // Step 3: Buyers & Industries
    var industries: [String] = []
    var buyerTitles: [String] = []
    var industryInput = ""
    var buyerTitleInput = ""

    // Step 4: Methodology & Differentiators
    var methodology = SalesMethodology.other.rawValue
    var differentiators: [String] = []
    var differentiatorInput = ""

    // State
    var currentStep = 1
    var isLoading = false
    var error: String?

    static let totalSteps = 4

    static let methodologies = ["MEDDIC", "MEDDPICC", "SPIN", "BANT", "Challenger", "Sandler", "Other"]

    static let commonIndustries = [
        "FinTech", "HRTech", "MedTech", "LegalTech", "GovTech",
        "EdTech", "InsurTech", "PropTech", "RetailTech", "LogTech"
    ]

    private let profileService: ProfileService
    private let userId: UUID

    init(profileService: ProfileService, userId: UUID) {
        self.profileService = profileService
        self.userId = userId
    }

    var canAdvance: Bool {
        switch currentStep {
        case 1: !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                !role.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: !product.trimmingCharacters(in: .whitespaces).isEmpty
        case 3: !industries.isEmpty
        case 4: !differentiators.isEmpty
        default: false
        }
    }

    func next() {
        guard currentStep < Self.totalSteps else { return }
        currentStep += 1
    }

    func back() {
        guard currentStep > 1 else { return }
        currentStep -= 1
    }

    func addIndustry(_ industry: String) {
        let trimmed = industry.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !industries.contains(trimmed) else { return }
        industries.append(trimmed)
    }

    func addBuyerTitle(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !buyerTitles.contains(trimmed) else { return }
        buyerTitles.append(trimmed)
    }

    func addDifferentiator(_ diff: String) {
        let trimmed = diff.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !differentiators.contains(trimmed), differentiators.count < 5 else { return }
        differentiators.append(trimmed)
    }

    func saveProfile() async -> Profile? {
        isLoading = true
        error = nil

        let profile = Profile(
            id: userId,
            name: name,
            role: role,
            product: product,
            industries: industries,
            buyerTitles: buyerTitles,
            methodology: methodology,
            differentiators: differentiators,
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            let saved = try await profileService.createProfile(profile)
            isLoading = false
            return saved
        } catch {
            self.error = error.localizedDescription
            isLoading = false
            return nil
        }
    }
}
