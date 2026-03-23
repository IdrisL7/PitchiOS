import Foundation

enum AppConfig {
    // MARK: - Supabase
    //
    // Development:  uses local Supabase stack (`supabase start`)
    // Production:   swap these for your Supabase project values from
    //               https://supabase.com/dashboard → Project Settings → API
    //
    #if DEBUG
    static let supabaseURL     = "http://127.0.0.1:54321"
    static let supabaseAnonKey = "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"
    #else
    static let supabaseURL     = "https://ipdyauprajeoyhhatiqm.supabase.co"
    static let supabaseAnonKey = "sb_publishable_yqRjhiu9JE-ZDdYfer0skg_Op_Dc1p-"
    #endif

    // MARK: - Usage Limits
    static let freeGenerationsPerMonth = 50

    // MARK: - App Info
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - AI Models
    static let objectionModel = "claude-haiku-4-5-20251001"
    static let summaryModel   = "claude-sonnet-4-6"
}
