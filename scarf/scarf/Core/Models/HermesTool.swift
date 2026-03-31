import Foundation

struct HermesToolset: Identifiable, Sendable {
    var id: String { name }
    let name: String
    let description: String
    let icon: String
    var enabled: Bool
}

struct HermesToolPlatform: Identifiable, Sendable {
    var id: String { name }
    let name: String
    let displayName: String
    let icon: String
}

enum KnownPlatforms {
    static let all: [HermesToolPlatform] = [
        HermesToolPlatform(name: "cli", displayName: "CLI", icon: "terminal"),
        HermesToolPlatform(name: "telegram", displayName: "Telegram", icon: "paperplane"),
        HermesToolPlatform(name: "discord", displayName: "Discord", icon: "bubble.left.and.bubble.right"),
        HermesToolPlatform(name: "slack", displayName: "Slack", icon: "number"),
        HermesToolPlatform(name: "whatsapp", displayName: "WhatsApp", icon: "phone.bubble"),
        HermesToolPlatform(name: "signal", displayName: "Signal", icon: "lock.shield"),
        HermesToolPlatform(name: "email", displayName: "Email", icon: "envelope"),
    ]
}
