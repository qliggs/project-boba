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
    case cat
    case dog

    var id: String { rawValue }

    var title: String {
        switch self {
        case .penguin: return "Penguin"
        case .bear: return "Bear"
        case .bunny: return "Bunny"
        case .cat: return "Cat"
        case .dog: return "Dog"
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

enum AvatarSlot: String, CaseIterable, Codable, Identifiable {
    case head
    case face
    case neck
    case body
    case hands
    case background
    case effect
    case none

    var id: String { rawValue }
}

enum TaskRecurrence: String, CaseIterable, Codable, Identifiable {
    case daily
    case weekly
    case oneOff

    var id: String { rawValue }

    var title: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .oneOff: return "One-off"
        }
    }
}

enum BobaWeekday: Int, CaseIterable, Codable, Identifiable, Comparable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    var shortTitle: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    static func < (lhs: BobaWeekday, rhs: BobaWeekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var notes: String
    var points: Int
    var tags: [BobaTag]
    var isStarter: Bool
    var isCompleted: Bool
    var recurrence: TaskRecurrence
    var dueWeekdays: [BobaWeekday]
    var dueDate: Date?
    var createdAt: Date

    init(
        id: UUID,
        title: String,
        notes: String,
        points: Int,
        tags: [BobaTag],
        isStarter: Bool,
        isCompleted: Bool = false,
        recurrence: TaskRecurrence,
        dueWeekdays: [BobaWeekday] = [],
        dueDate: Date? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.points = points
        self.tags = tags
        self.isStarter = isStarter
        self.isCompleted = isCompleted
        self.recurrence = recurrence
        self.dueWeekdays = dueWeekdays
        self.dueDate = dueDate
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case notes
        case points
        case tags
        case isStarter
        case isCompleted
        case recurrence
        case dueWeekdays
        case dueDate
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        points = try container.decode(Int.self, forKey: .points)
        tags = try container.decodeIfPresent([BobaTag].self, forKey: .tags) ?? []
        isStarter = try container.decodeIfPresent(Bool.self, forKey: .isStarter) ?? false
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        recurrence = try container.decodeIfPresent(TaskRecurrence.self, forKey: .recurrence) ?? .daily
        dueWeekdays = try container.decodeIfPresent([BobaWeekday].self, forKey: .dueWeekdays) ?? []
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? .now
    }
}

struct CompletionRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var taskId: UUID
    var completedAt: Date
    var pointsAwarded: Int
    var goalBonusAwarded: Int
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

extension ShopItem {
    var slot: AvatarSlot {
        switch type {
        case .hat:
            return .head
        case .eyewear:
            return .face
        case .scarf:
            return .neck
        case .accessory:
            return .body
        case .gloves:
            return .hands
        case .background:
            return .background
        case .effect:
            return .effect
        case .phrasePack:
            return .none
        }
    }

    var isEquippable: Bool {
        slot != .none
    }
}

struct AppState: Codable {
    var playerName: String
    var companionName: String
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

    enum CodingKeys: String, CodingKey {
        case playerName
        case companionName
        case avatarKind
        case backgroundId
        case pointsBalance
        case lifetimePoints
        case streakCount
        case lastQualifiedDay
        case tasks
        case completions
        case ownedItemIds
        case equippedHatId
        case equippedScarfId
        case equippedEyewearId
        case equippedGlovesId
        case equippedAccessoryId
        case soundEnabled
        case lastPhraseAt
    }

    private enum LegacyCodingKeys: String, CodingKey {
        case avatarName
    }

    init(
        playerName: String,
        companionName: String,
        avatarKind: AvatarKind,
        backgroundId: String,
        pointsBalance: Int,
        lifetimePoints: Int,
        streakCount: Int,
        lastQualifiedDay: String?,
        tasks: [TaskItem],
        completions: [CompletionRecord],
        ownedItemIds: Set<String>,
        equippedHatId: String?,
        equippedScarfId: String?,
        equippedEyewearId: String?,
        equippedGlovesId: String?,
        equippedAccessoryId: String?,
        soundEnabled: Bool,
        lastPhraseAt: TimeInterval
    ) {
        self.playerName = playerName
        self.companionName = companionName
        self.avatarKind = avatarKind
        self.backgroundId = backgroundId
        self.pointsBalance = pointsBalance
        self.lifetimePoints = lifetimePoints
        self.streakCount = streakCount
        self.lastQualifiedDay = lastQualifiedDay
        self.tasks = tasks
        self.completions = completions
        self.ownedItemIds = ownedItemIds
        self.equippedHatId = equippedHatId
        self.equippedScarfId = equippedScarfId
        self.equippedEyewearId = equippedEyewearId
        self.equippedGlovesId = equippedGlovesId
        self.equippedAccessoryId = equippedAccessoryId
        self.soundEnabled = soundEnabled
        self.lastPhraseAt = lastPhraseAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let legacyContainer = try decoder.container(keyedBy: LegacyCodingKeys.self)
        let legacyCompanionName = try legacyContainer.decodeIfPresent(String.self, forKey: .avatarName)
        playerName = try container.decodeIfPresent(String.self, forKey: .playerName) ?? ""
        let decodedCompanionName = try container.decodeIfPresent(String.self, forKey: .companionName)
        let legacyOrDecodedName = decodedCompanionName ?? legacyCompanionName ?? "Henry"
        companionName = legacyOrDecodedName.trimmingCharacters(in: .whitespacesAndNewlines) == "Boba" ? "Henry" : legacyOrDecodedName
        avatarKind = try container.decodeIfPresent(AvatarKind.self, forKey: .avatarKind) ?? .penguin
        backgroundId = try container.decodeIfPresent(String.self, forKey: .backgroundId) ?? "snowy_nook"
        pointsBalance = try container.decodeIfPresent(Int.self, forKey: .pointsBalance) ?? 200
        lifetimePoints = try container.decodeIfPresent(Int.self, forKey: .lifetimePoints) ?? pointsBalance
        streakCount = try container.decodeIfPresent(Int.self, forKey: .streakCount) ?? 0
        lastQualifiedDay = try container.decodeIfPresent(String.self, forKey: .lastQualifiedDay)
        tasks = try container.decodeIfPresent([TaskItem].self, forKey: .tasks) ?? AppState.starterTasks
        completions = try container.decodeIfPresent([CompletionRecord].self, forKey: .completions) ?? []
        ownedItemIds = try container.decodeIfPresent(Set<String>.self, forKey: .ownedItemIds) ?? []
        equippedHatId = try container.decodeIfPresent(String.self, forKey: .equippedHatId)
        equippedScarfId = try container.decodeIfPresent(String.self, forKey: .equippedScarfId)
        equippedEyewearId = try container.decodeIfPresent(String.self, forKey: .equippedEyewearId)
        equippedGlovesId = try container.decodeIfPresent(String.self, forKey: .equippedGlovesId)
        equippedAccessoryId = try container.decodeIfPresent(String.self, forKey: .equippedAccessoryId)
        soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
        lastPhraseAt = try container.decodeIfPresent(TimeInterval.self, forKey: .lastPhraseAt) ?? 0
    }
}

extension AppState {
    static let starterTasks: [TaskItem] = [
        .init(id: UUID(), title: "Brush teeth", notes: "Morning and evening reset.", points: 5, tags: [.hygiene], isStarter: true, recurrence: .daily),
        .init(id: UUID(), title: "Drink water", notes: "Have a full glass.", points: 5, tags: [.health, .selfCare], isStarter: true, recurrence: .daily),
        .init(id: UUID(), title: "Make bed", notes: "Small tidy win.", points: 8, tags: [.chores], isStarter: true, recurrence: .daily),
        .init(id: UUID(), title: "Take meds", notes: "Use your normal reminder routine.", points: 8, tags: [.health], isStarter: true, recurrence: .daily),
        .init(id: UUID(), title: "Do laundry", notes: "Wash, dry, and put away one load.", points: 20, tags: [.chores], isStarter: true, recurrence: .weekly, dueWeekdays: [.sunday]),
        .init(id: UUID(), title: "Vacuum living room", notes: "A quick floor reset.", points: 18, tags: [.chores], isStarter: true, recurrence: .weekly, dueWeekdays: [.saturday]),
        .init(id: UUID(), title: "Mop floors", notes: "Kitchen and main walkways.", points: 22, tags: [.chores], isStarter: true, recurrence: .weekly, dueWeekdays: [.saturday]),
        .init(id: UUID(), title: "Clean car", notes: "Trash out, quick wipe, tidy seats.", points: 25, tags: [.chores], isStarter: true, recurrence: .weekly, dueWeekdays: [.sunday]),
    ]

    static let shopInventory: [ShopItem] = [
        .init(id: "hat_beanie", title: "Cocoa Beanie", detail: "A soft knit hat for chilly mornings.", cost: 60, type: .hat, requiredTag: .hygiene, contentValue: "beanie"),
        .init(id: "hat_mooncap", title: "Mooncap", detail: "A rounded winter cap with a sleepy little pom.", cost: 95, type: .hat, requiredTag: .mentalHealth, contentValue: "mooncap"),
        .init(id: "hat_berry_hood", title: "Berry Hood", detail: "A plush hood with stitched berry leaves.", cost: 110, type: .hat, requiredTag: .creative, contentValue: "berry_hood"),
        .init(id: "scarf_plaid", title: "Plaid Scarf", detail: "A cozy scarf with cabin energy.", cost: 75, type: .scarf, requiredTag: .chores, contentValue: "plaid"),
        .init(id: "eyewear_round", title: "Round Glasses", detail: "Warm bookshop glasses.", cost: 80, type: .eyewear, requiredTag: .work, contentValue: "round"),
        .init(id: "eyewear_heart", title: "Heart Specs", detail: "Tiny heart frames with a soft rose tint.", cost: 92, type: .eyewear, requiredTag: .social, contentValue: "heart_specs"),
        .init(id: "eyewear_sleepy", title: "Sleepy Stars", detail: "Gentle star clips that sit above the eyes.", cost: 88, type: .eyewear, requiredTag: .selfCare, contentValue: "sleepy_stars"),
        .init(id: "gloves_mittens", title: "Cloud Mittens", detail: "Little puffy mittens.", cost: 70, type: .gloves, requiredTag: .health, contentValue: "mittens"),
        .init(id: "accessory_star", title: "Star Pin", detail: "A tiny sparkle pin for proud days.", cost: 50, type: .accessory, requiredTag: .creative, contentValue: "star"),
        .init(id: "bg_twilight", title: "Twilight Window", detail: "A dusky room with snowy panes.", cost: 120, type: .background, requiredTag: .mentalHealth, contentValue: "twilight_window"),
        .init(id: "bg_market", title: "Winter Market", detail: "Lanterns and warm stalls.", cost: 140, type: .background, requiredTag: .social, contentValue: "winter_market"),
        .init(id: "bg_fireplace", title: "Fireplace Nook", detail: "Blanket light, crackling glow, and a sleepy chair.", cost: 155, type: .background, requiredTag: .selfCare, contentValue: "fireplace_nook"),
        .init(id: "bg_underwater", title: "Underwater", detail: "Soft blue light, drifting bubbles, and slow kelp sway.", cost: 160, type: .background, requiredTag: .creative, contentValue: "underwater"),
        .init(id: "phrases_supportive", title: "Supportive Phrases", detail: "Extra kind words for tap moments.", cost: 65, type: .phrasePack, requiredTag: .selfCare, contentValue: "supportive_pack"),
        .init(id: "phrases_whimsy", title: "Whimsy Pack", detail: "Sillier cozy one-liners.", cost: 65, type: .phrasePack, requiredTag: .creative, contentValue: "whimsy_pack"),
    ]

    static let starter = AppState(
        playerName: "",
        companionName: "Henry",
        avatarKind: .penguin,
        backgroundId: "snowy_nook",
        pointsBalance: 200,
        lifetimePoints: 200,
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
            return [Color(red: 0.18, green: 0.24, blue: 0.34), Color(red: 0.42, green: 0.31, blue: 0.38), Color(red: 0.77, green: 0.60, blue: 0.46)]
        case "winter_market":
            return [Color(red: 0.22, green: 0.27, blue: 0.30), Color(red: 0.44, green: 0.31, blue: 0.21), Color(red: 0.79, green: 0.66, blue: 0.50)]
        case "fireplace_nook":
            return [Color(red: 0.29, green: 0.18, blue: 0.16), Color(red: 0.57, green: 0.34, blue: 0.22), Color(red: 0.88, green: 0.70, blue: 0.46)]
        case "underwater":
            return [Color(red: 0.12, green: 0.33, blue: 0.46), Color(red: 0.19, green: 0.56, blue: 0.67), Color(red: 0.69, green: 0.86, blue: 0.82)]
        default:
            return [Color(red: 0.28, green: 0.37, blue: 0.46), Color(red: 0.58, green: 0.64, blue: 0.69), Color(red: 0.82, green: 0.69, blue: 0.53)]
        }
    }
}
