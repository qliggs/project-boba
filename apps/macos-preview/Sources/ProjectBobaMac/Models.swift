import Foundation
import SwiftUI

enum BobaTag: String, CaseIterable, Codable, Identifiable {
    case hygiene = "Hygiene"
    case chores = "Chores"
    case work = "Work"
    case selfCare = "Self-care"
    case mentalHealth = "Mental health"
    case social = "Social"
    case health = "Health"
    case creative = "Creative"

    var id: String { rawValue }
}

enum AvatarKind: String, CaseIterable, Codable, Identifiable {
    case penguin
    case bear
    case bunny

    var id: String { rawValue }

    var title: String {
        switch self {
        case .penguin: return "Penguin"
        case .bear: return "Bear"
        case .bunny: return "Bunny"
        }
    }
}

enum ShopItemType: String, Codable {
    case hat
    case scarf
    case eyewear
    case gloves
    case accessory
    case background
    case effect
    case phrasePack
}

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var notes: String
    var points: Int
    var tags: [BobaTag]
    var isStarter: Bool
}

struct CompletionRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var taskId: UUID
    var completedAt: Date
    var pointsAwarded: Int
}

struct ShopItem: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var detail: String
    var cost: Int
    var type: ShopItemType
    var requiredTag: BobaTag
    var contentValue: String
}

struct AppState: Codable {
    var avatarName: String
    var avatarKind: AvatarKind
    var backgroundId: String
    var pointsBalance: Int
    var lifetimePoints: Int
    var streakCount: Int
    var lastQualifiedDay: String?
    var tasks: [TaskItem]
    var completions: [CompletionRecord]
    var ownedItemIds: Set<String>
    var equippedHatId: String?
    var equippedScarfId: String?
    var equippedEyewearId: String?
    var equippedGlovesId: String?
    var equippedAccessoryId: String?
    var soundEnabled: Bool
    var lastPhraseAt: TimeInterval
}

extension AppState {
    static let starterTasks: [TaskItem] = [
        .init(id: UUID(), title: "Brush teeth", notes: "", points: 5, tags: [.hygiene], isStarter: true),
        .init(id: UUID(), title: "Drink water", notes: "", points: 5, tags: [.health, .selfCare], isStarter: true),
        .init(id: UUID(), title: "Make bed", notes: "", points: 10, tags: [.chores], isStarter: true),
        .init(id: UUID(), title: "Shower", notes: "", points: 10, tags: [.hygiene, .selfCare], isStarter: true),
        .init(id: UUID(), title: "Take meds", notes: "", points: 10, tags: [.health], isStarter: true),
        .init(id: UUID(), title: "Vacuum", notes: "", points: 20, tags: [.chores], isStarter: true),
        .init(id: UUID(), title: "Dishes", notes: "", points: 10, tags: [.chores], isStarter: true),
        .init(id: UUID(), title: "Laundry", notes: "", points: 20, tags: [.chores], isStarter: true),
        .init(id: UUID(), title: "Journal", notes: "", points: 20, tags: [.mentalHealth, .creative], isStarter: true),
        .init(id: UUID(), title: "Stretch", notes: "", points: 10, tags: [.health, .selfCare], isStarter: true),
        .init(id: UUID(), title: "Walk", notes: "", points: 20, tags: [.health], isStarter: true),
    ]

    static let shopInventory: [ShopItem] = [
        .init(id: "hat_beanie", title: "Cocoa Beanie", detail: "A soft knit hat for chilly mornings.", cost: 60, type: .hat, requiredTag: .hygiene, contentValue: "beanie"),
        .init(id: "scarf_plaid", title: "Plaid Scarf", detail: "A cozy scarf with cabin energy.", cost: 75, type: .scarf, requiredTag: .chores, contentValue: "plaid"),
        .init(id: "eyewear_round", title: "Round Glasses", detail: "Warm bookshop glasses.", cost: 80, type: .eyewear, requiredTag: .work, contentValue: "round"),
        .init(id: "gloves_mittens", title: "Cloud Mittens", detail: "Little puffy mittens.", cost: 70, type: .gloves, requiredTag: .health, contentValue: "mittens"),
        .init(id: "accessory_star", title: "Star Pin", detail: "A tiny sparkle pin for proud days.", cost: 50, type: .accessory, requiredTag: .creative, contentValue: "star"),
        .init(id: "bg_twilight", title: "Twilight Window", detail: "A dusky room with snowy panes.", cost: 120, type: .background, requiredTag: .mentalHealth, contentValue: "twilight_window"),
        .init(id: "bg_market", title: "Winter Market", detail: "Lanterns and warm stalls.", cost: 140, type: .background, requiredTag: .social, contentValue: "winter_market"),
        .init(id: "phrases_supportive", title: "Supportive Phrases", detail: "Extra kind words for tap moments.", cost: 65, type: .phrasePack, requiredTag: .selfCare, contentValue: "supportive_pack"),
        .init(id: "phrases_whimsy", title: "Whimsy Pack", detail: "Sillier cozy one-liners.", cost: 65, type: .phrasePack, requiredTag: .creative, contentValue: "whimsy_pack"),
    ]

    static let starter = AppState(
        avatarName: "Boba",
        avatarKind: .penguin,
        backgroundId: "snowy_nook",
        pointsBalance: 40,
        lifetimePoints: 40,
        streakCount: 0,
        lastQualifiedDay: nil,
        tasks: starterTasks,
        completions: [],
        ownedItemIds: [],
        equippedHatId: nil,
        equippedScarfId: nil,
        equippedEyewearId: nil,
        equippedGlovesId: nil,
        equippedAccessoryId: nil,
        soundEnabled: true,
        lastPhraseAt: 0
    )
}

enum BackgroundPalette {
    static func colors(for id: String) -> [Color] {
        switch id {
        case "twilight_window":
            return [Color(red: 0.22, green: 0.30, blue: 0.40), Color(red: 0.48, green: 0.36, blue: 0.43), Color(red: 0.84, green: 0.69, blue: 0.55)]
        case "winter_market":
            return [Color(red: 0.27, green: 0.33, blue: 0.37), Color(red: 0.49, green: 0.36, blue: 0.25), Color(red: 0.88, green: 0.76, blue: 0.61)]
        default:
            return [Color(red: 0.34, green: 0.45, blue: 0.54), Color(red: 0.61, green: 0.69, blue: 0.75), Color(red: 0.89, green: 0.76, blue: 0.60)]
        }
    }
}
