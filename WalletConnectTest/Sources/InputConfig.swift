import Foundation

struct InputConfig {
    static var projectId: String {
        guard let projectId = config(for: "PROJECT_ID"), !projectId.isEmpty else {
            return "48e62aae4caa3713e482f189622f853c"
        }
        
        return projectId
    }

    static var sentryDsn: String? {
        return config(for: "WALLETAPP_SENTRY_DSN")
    }

    static var mixpanelToken: String? {
        return config(for: "MIXPANEL_TOKEN")
    }
    
    private static func config(for key: String) -> String? {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String
    }

}
