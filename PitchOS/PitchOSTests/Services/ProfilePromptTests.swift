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
