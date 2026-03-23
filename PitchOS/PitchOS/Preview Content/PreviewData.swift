import Foundation

enum PreviewData {
    static let profile = Profile(
        id: UUID(),
        name: "Sarah Chen",
        role: "Solutions Engineer",
        product: "DataSync — real-time data integration platform for enterprise finance teams",
        industries: ["FinTech", "HRTech", "MedTech"],
        buyerTitles: ["VP Engineering", "CTO", "Head of Data"],
        methodology: "MEDDIC",
        differentiators: [
            "Sub-100ms real-time sync",
            "No-code integration builder",
            "SOC 2 Type II certified"
        ],
        createdAt: Date(),
        updatedAt: Date()
    )

    static let deal = Deal(
        id: UUID(),
        userId: profile.id,
        companyName: "Acme Financial",
        contactName: "John Morrison",
        contactRole: "VP Engineering",
        stage: .evaluation,
        outcome: nil,
        notes: "Interested in real-time data sync. Currently using manual ETL processes.",
        createdAt: Date(),
        updatedAt: Date()
    )

    static let deals: [Deal] = [
        deal,
        Deal(
            id: UUID(),
            userId: profile.id,
            companyName: "TechCorp Global",
            contactName: "Lisa Park",
            contactRole: "CTO",
            stage: .discovery,
            outcome: nil,
            notes: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Deal(
            id: UUID(),
            userId: profile.id,
            companyName: "MediHealth Systems",
            contactName: "Dr. Patel",
            contactRole: "Head of Digital",
            stage: .demo,
            outcome: .progressed,
            notes: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]

    static let objectionOutput = Output(
        id: UUID(),
        userId: profile.id,
        dealId: deal.id,
        type: .objection,
        input: ["objection": "Your pricing is too high compared to Competitor X"],
        output: """
        **Acknowledge**
        That's a fair point — pricing transparency matters, especially when you're evaluating multiple vendors.

        **Reframe**
        When our customers compare total cost of ownership, they typically find that the manual workarounds with Competitor X cost 15-20 engineering hours per month. Our platform eliminates that entirely, which often makes the net investment lower within the first quarter.

        **Advance**
        Would it be helpful if I put together a side-by-side TCO comparison using your team's actual data volumes?
        """,
        promptVersion: "objection_v1.0",
        rating: 1,
        createdAt: Date()
    )
}
