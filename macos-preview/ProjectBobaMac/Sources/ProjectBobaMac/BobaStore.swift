import AppKit
import Foundation
import SwiftUI

@MainActor
final class BobaStore: ObservableObject {
    @Published private(set) var state: AppState
    @Published var activePhrase: String?
    @Published var latestPointsBurst: Int = 0

    private let saveURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = support.appendingPathComponent("ProjectBobaMac", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        saveURL = folder.appendingPathComponent("state.json")

        if
            let data = try? Data(contentsOf: saveURL),
            let decoded = try? JSONDecoder().decode(AppState.self, from: data)
        {
            state = decoded
        } else {
            state = .starter
        }
    }

    var shopItems: [ShopItem] { AppState.shopInventory }

    var todayCompletedCount: Int {
        let calendar = Calendar.current
        return state.completions.filter { calendar.isDateInToday($0.completedAt) }.count
    }

    func addTask(title: String, notes: String, points: Int, tags: Set<BobaTag>) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !tags.isEmpty else { return }

        state.tasks.append(
            TaskItem(
                id: UUID(),
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                points: points,
                tags: tags.sorted { $0.rawValue < $1.rawValue },
                isStarter: false
            )
        )
        persist()
    }

    func complete(_ task: TaskItem) {
        state.completions.insert(
            CompletionRecord(id: UUID(), taskId: task.id, completedAt: Date(), pointsAwarded: task.points),
            at: 0
        )
        state.pointsBalance += task.points
        state.lifetimePoints += task.points
        latestPointsBurst = task.points
        updateGentleStreak()
        if state.soundEnabled {
            NSSound.beep()
        }
        persist()
    }

    func requestPhrase() {
        let now = Date().timeIntervalSince1970
        guard now - state.lastPhraseAt > 4 else { return }
        state.lastPhraseAt = now
        activePhrase = availablePhrases.randomElement()?.replacingOccurrences(of: "%s", with: state.avatarName)
        persist()
    }

    func purchase(_ item: ShopItem) {
        guard !state.ownedItemIds.contains(item.id) else { return }
        guard state.pointsBalance >= item.cost else { return }
        state.pointsBalance -= item.cost
        state.ownedItemIds.insert(item.id)
        if item.type == .background {
            state.backgroundId = item.contentValue
        }
        persist()
    }

    func equip(_ item: ShopItem) {
        guard state.ownedItemIds.contains(item.id) || item.type == .background else { return }
        switch item.type {
        case .hat:
            state.equippedHatId = item.id
        case .scarf:
            state.equippedScarfId = item.id
        case .eyewear:
            state.equippedEyewearId = item.id
        case .gloves:
            state.equippedGlovesId = item.id
        case .accessory:
            state.equippedAccessoryId = item.id
        case .background:
            state.backgroundId = item.contentValue
        case .effect, .phrasePack:
            break
        }
        persist()
    }

    func updateAvatar(name: String? = nil, kind: AvatarKind? = nil) {
        if let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            state.avatarName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let kind {
            state.avatarKind = kind
        }
        persist()
    }

    func toggleSound() {
        state.soundEnabled.toggle()
        persist()
    }

    private var availablePhrases: [String] {
        var phrases = [
            "You did a little good thing. That counts.",
            "Tiny steps still make a path.",
            "I am legally required to cheer for you now.",
            "Warm tea energy only.",
            "You are doing enough for this moment.",
            "%s, I am very impressed with your cozy momentum.",
        ]
        if state.ownedItemIds.contains("phrases_supportive") {
            phrases += [
                "%s, you are allowed to be proud of small wins.",
                "Gentle progress is still progress.",
            ]
        }
        if state.ownedItemIds.contains("phrases_whimsy") {
            phrases += [
                "Emergency glitter report: vibes are excellent.",
                "I would do a cartwheel, but I am very round.",
            ]
        }
        return phrases
    }

    private func updateGentleStreak() {
        guard todayCompletedCount >= 3 else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let today = formatter.string(from: Date())
        let yesterday = formatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())

        if state.lastQualifiedDay == today {
            return
        } else if state.lastQualifiedDay == yesterday {
            state.streakCount += 1
        } else {
            state.streakCount = 1
        }
        state.lastQualifiedDay = today
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(state) {
            try? encoded.write(to: saveURL)
        }
    }
}
