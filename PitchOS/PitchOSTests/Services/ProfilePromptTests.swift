import Foundation
import Testing
@testable import PitchOS

@Suite("Profile prompt context")
struct ProfilePromptTests {

    @Test("promptContext includes all ICP fields")
    func promptContextIncludesAllFields() {
        let profile = Profile(
            id: .init(),
            name: "Sarah Chen",
            role: "Solutions Engineer",
            product: "DataSync Platform",
            industries: ["FinTech", "HRTech"],
            buyerTitles: ["VP Engineering", "CTO"],
            methodology: "MEDDIC",
            differentiators: ["Real-time sync", "No-code builder"],
            createdAt: .now,
            updatedAt: .now
        )

        let context = profile.promptContext

        #expect(context.contains("Sarah Chen"))
        #expect(context.contains("Solutions Engineer"))
        #expect(context.contains("DataSync Platform"))
        #expect(context.contains("FinTech"))
        #expect(context.contains("HRTech"))
        #expect(context.contains("VP Engineering"))
        #expect(context.contains("CTO"))
        #expect(context.contains("MEDDIC"))
        #expect(context.contains("Real-time sync"))
        #expect(context.contains("No-code builder"))
    }

    @Test("promptContext handles empty arrays")
    func promptContextHandlesEmptyArrays() {
        let profile = Profile(
            id: .init(),
            name: "Test",
            role: "AE",
            product: "Test Product",
            industries: [],
            buyerTitles: [],
            methodology: "",
            differentiators: [],
            createdAt: .now,
            updatedAt: .now
        )

        // Should not crash
        let context = profile.promptContext
        #expect(context.contains("Test"))
    }
}

@Suite("Follow-up email prompt")
struct FollowUpEmailPromptTests {

    @Test("prompt requires sendable first-person copy without invented context")
    func promptRequiresSendableCopy() {
        let prompt = Prompts.FollowUpEmail.userPrompt(
            summary: "Marcus will schedule a procurement call next week.",
            dealContext: "Contact: Marcus Green, CISO"
        )

        #expect(Prompts.FollowUpEmail.version == "email_v1.1")
        #expect(prompt.contains("PitchOS profile user is the sender"))
        #expect(prompt.contains("Contact named in Deal context is the recipient"))
        #expect(prompt.contains("Never output brackets, placeholders"))
        #expect(prompt.contains("Preserve every owner, quantity, qualifier, and deadline"))
        #expect(prompt.contains("without naming or characterising the meeting"))
        #expect(prompt.contains("Do not turn that absence into a refusal"))
        #expect(prompt.contains("Do not generalise a specific unaccepted term"))
        #expect(prompt.contains("Mention general pricing status only when the source explicitly states it"))
        #expect(prompt.contains("Do not omit an explicitly mentioned"))
        #expect(prompt.contains("Do not invent, accept, or strengthen commitments"))
        #expect(prompt.contains("must be 120 words or fewer"))
    }
}

@Suite("Meeting brief prompt")
struct MeetingBriefPromptTests {

    @Test("prompt requires three grounded objections and counters")
    func promptRequiresObjectionsAndCounters() {
        let prompt = Prompts.MeetingBrief.userPrompt(
            dealContext: "Company: Northbank Conveyancing. Contact: Priya Shah, Operations Director."
        )

        #expect(Prompts.MeetingBrief.version == "brief_v1.1")
        #expect(prompt.contains("Objections and Counters:"))
        #expect(prompt.contains("top 3 likely objections"))
        #expect(prompt.contains("Objection:"))
        #expect(prompt.contains("Counter:"))
        #expect(prompt.contains("never invent proof, commitments, incidents, or"))
        #expect(prompt.contains("Under 280 words total"))
    }
}

@MainActor
@Suite("Activation language")
struct ActivationLanguageTests {

    @Test("general methodology is a plain-language starting point")
    func generalMethodologyUsesPlainLanguage() {
        #expect(SalesMethodology.other.displayName == "General / Not sure")
        #expect(SalesMethodology.other.bestFor.contains("Any B2B seller"))
        #expect(SalesMethodology.other.promptGuidance.contains("discovery best practices"))
        #expect(OnboardingViewModel.methodologies.contains(SalesMethodology.other.rawValue))
    }
}

@Suite("Activation routing")
struct ActivationRoutingTests {

    @Test("start-here dismissal key requires an authenticated user")
    func dismissalKeyRequiresUserID() {
        let userID = UUID()

        #expect(GenerateView.startHereDismissalKey(for: nil) == nil)
        #expect(GenerateView.startHereDismissalKey(for: userID) == "pitchos.startHere.dismissed.\(userID.uuidString)")
    }
}

@Suite("Generation limits")
struct GenerationLimitTests {

    @Test("Free plan uses the reduced allowance")
    func freePlanUsesReducedAllowance() {
        #expect(AppConfig.freeGenerationsPerMonth == 10)
        #expect(UserPlan.free.monthlyLimit == 10)
    }

    @Test("Paid plans remain unlimited")
    func paidPlansRemainUnlimited() {
        #expect(UserPlan.solo.isUnlimited)
        #expect(UserPlan.pro.isUnlimited)
        #expect(UserPlan.team.isUnlimited)
    }
}

@MainActor
@Suite("Rating prompt")
struct RatingPromptTests {

    @Test("requests once on the third successful brief per app version")
    func requestsOnceOnThirdSuccessfulBrief() {
        let suiteName = "RatingPromptTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        var requestCount = 0
        let service = RatingPromptService(
            defaults: defaults,
            versionProvider: { "1.1.0" },
            requestReview: { requestCount += 1 }
        )

        service.recordSuccessfulBrief()
        service.recordSuccessfulBrief()
        #expect(requestCount == 0)
        #expect(service.successfulBriefCount == 2)

        service.recordSuccessfulBrief()
        service.recordSuccessfulBrief()
        #expect(requestCount == 1)
        #expect(service.successfulBriefCount == 3)
        #expect(service.hasPromptedForCurrentVersion)
    }

    @Test("a new app version gets its own three-success trigger")
    func newVersionGetsOwnTrigger() {
        let suiteName = "RatingPromptTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        var currentVersion = "1.1.0"
        var requestCount = 0
        let makeService = {
            RatingPromptService(
                defaults: defaults,
                versionProvider: { currentVersion },
                requestReview: { requestCount += 1 }
            )
        }

        let firstVersion = makeService()
        firstVersion.recordSuccessfulBrief()
        firstVersion.recordSuccessfulBrief()
        firstVersion.recordSuccessfulBrief()
        #expect(requestCount == 1)

        currentVersion = "1.2.0"
        let secondVersion = makeService()
        secondVersion.recordSuccessfulBrief()
        secondVersion.recordSuccessfulBrief()
        #expect(requestCount == 1)
        secondVersion.recordSuccessfulBrief()
        #expect(requestCount == 2)
    }
}
