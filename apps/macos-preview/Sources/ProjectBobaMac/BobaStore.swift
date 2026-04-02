import AppKit
import Foundation
import SwiftUI

enum TaskMoveDirection {
    case up
    case down
}

enum TaskFilter: String, CaseIterable, Identifiable {
    case today
    case daily
    case weekly
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .all: return "All"
        }
    }
}

enum HomeTaskScope: String, CaseIterable, Identifiable {
    case today
    case thisWeek

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .thisWeek: return "This Week"
        }
    }
}

struct ProgressSummary {
    let completed: Int
    let total: Int

    var clampedCompleted: Int { min(max(completed, 0), total) }
}

@MainActor
final class BobaStore: ObservableObject {
    @Published private(set) var state: AppState
    @Published var activePhrase: String?
    @Published var latestPointsBurst: Int = 0
    @Published var celebrationTrigger = UUID()
    @Published var greetingTrigger = UUID()

    private let saveURL: URL
    private let calendar = Calendar.current
    private let goalBonusPoints = 5
    private var phraseDismissWorkItem: DispatchWorkItem?

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
            migrateStarterBalanceIfNeeded()
        } else {
            state = .starter
            persist()
        }
    }

    var shopItems: [ShopItem] { AppState.shopInventory }

    var ownedItems: [ShopItem] {
        AppState.shopInventory.filter { state.ownedItemIds.contains($0.id) }
    }

    var dueTodayTasks: [TaskItem] {
        state.tasks.filter(isDueToday)
    }

    var dueThisWeekTasks: [TaskItem] {
        state.tasks.filter { $0.recurrence == .weekly && isDueThisWeek($0) }
    }

    var completedTodayTasks: [TaskItem] {
        dueTodayTasks.filter(isTaskCompleted)
    }

    var openTodayTasks: [TaskItem] {
        dueTodayTasks.filter { !isTaskCompleted($0) }
    }

    var completedThisWeekTasks: [TaskItem] {
        dueThisWeekTasks.filter(isTaskCompleted)
    }

    var openThisWeekTasks: [TaskItem] {
        dueThisWeekTasks.filter { !isTaskCompleted($0) }
    }

    var dailyProgress: ProgressSummary {
        let due = state.tasks.filter { $0.recurrence == .daily }
        return ProgressSummary(
            completed: due.filter(isTaskCompleted).count,
            total: due.count
        )
    }

    var weeklyProgress: ProgressSummary {
        let due = dueThisWeekTasks
        return ProgressSummary(
            completed: due.filter(isTaskCompleted).count,
            total: due.count
        )
    }

    var goalOfTheDay: TaskItem? {
        openTodayTasks.sorted {
            if $0.points == $1.points {
                return $0.title < $1.title
            }
            return $0.points > $1.points
        }.first
    }

    var displayPlayerName: String {
        let trimmed = state.playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "friend" : trimmed
    }

    func tasks(for filter: TaskFilter) -> [TaskItem] {
        switch filter {
        case .today:
            return dueTodayTasks
        case .daily:
            return state.tasks.filter { $0.recurrence == .daily }
        case .weekly:
            return state.tasks.filter { $0.recurrence == .weekly }
        case .all:
            return state.tasks
        }
    }

    func addTask(
        title: String,
        notes: String,
        points: Int,
        tags: Set<BobaTag>,
        recurrence: TaskRecurrence,
        dueWeekdays: Set<BobaWeekday>,
        dueDate: Date?
    ) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !tags.isEmpty else { return }
        if recurrence == .weekly && dueWeekdays.isEmpty { return }

        state.tasks.append(
            TaskItem(
                id: UUID(),
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                points: max(5, points),
                tags: tags.sorted { $0.rawValue < $1.rawValue },
                isStarter: false,
                recurrence: recurrence,
                dueWeekdays: dueWeekdays.sorted(),
                dueDate: recurrence == .oneOff ? dueDate : nil
            )
        )
        persist()
    }

    func updateTask(_ task: TaskItem) {
        guard let index = state.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let trimmedTitle = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        let normalizedWeekdays = Array(Set(task.dueWeekdays)).sorted()
        if task.recurrence == .weekly && normalizedWeekdays.isEmpty { return }

        state.tasks[index] = TaskItem(
            id: task.id,
            title: trimmedTitle,
            notes: task.notes.trimmingCharacters(in: .whitespacesAndNewlines),
            points: max(5, task.points),
            tags: task.tags.sorted { $0.rawValue < $1.rawValue },
            isStarter: task.isStarter,
            isCompleted: task.isCompleted,
            recurrence: task.recurrence,
            dueWeekdays: normalizedWeekdays,
            dueDate: task.recurrence == .oneOff ? task.dueDate : nil,
            createdAt: task.createdAt
        )
        persist()
    }

    func deleteTask(_ task: TaskItem) {
        state.tasks.removeAll { $0.id == task.id }
        removeCompletionAndPoints(for: task)
        persist()
    }

    func moveTask(_ task: TaskItem, direction: TaskMoveDirection) {
        guard let index = state.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        switch direction {
        case .up where index > 0:
            state.tasks.swapAt(index, index - 1)
        case .down where index < state.tasks.count - 1:
            state.tasks.swapAt(index, index + 1)
        default:
            return
        }
        persist()
    }

    func toggleTaskCompletion(_ task: TaskItem) {
        guard let index = state.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        if isTaskCompleted(state.tasks[index]) {
            removeCompletionAndPoints(for: state.tasks[index])
        } else {
            let bonus = goalOfTheDay?.id == task.id ? goalBonusPoints : 0
            state.completions.insert(
                CompletionRecord(
                    id: UUID(),
                    taskId: task.id,
                    completedAt: Date(),
                    pointsAwarded: task.points,
                    goalBonusAwarded: bonus
                ),
                at: 0
            )
            state.pointsBalance += task.points + bonus
            state.lifetimePoints += task.points + bonus
            latestPointsBurst = task.points + bonus
            celebrationTrigger = UUID()
            if state.soundEnabled {
                NSSound.beep()
            }
            recalculateStreak()
        }
        persist()
    }

    func requestPhrase() {
        let now = Date().timeIntervalSince1970
        guard now - state.lastPhraseAt > 4 else { return }
        state.lastPhraseAt = now
        activePhrase = availablePhrases.randomElement()?.replacingOccurrences(of: "%s", with: displayPlayerName)
        phraseDismissWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.activePhrase = nil
        }
        phraseDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2, execute: workItem)
        persist()
    }

    func avatarTapped() {
        greetingTrigger = UUID()
        requestPhrase()
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

    func unequip(_ item: ShopItem) {
        switch item.type {
        case .hat:
            if state.equippedHatId == item.id { state.equippedHatId = nil }
        case .scarf:
            if state.equippedScarfId == item.id { state.equippedScarfId = nil }
        case .eyewear:
            if state.equippedEyewearId == item.id { state.equippedEyewearId = nil }
        case .gloves:
            if state.equippedGlovesId == item.id { state.equippedGlovesId = nil }
        case .accessory:
            if state.equippedAccessoryId == item.id { state.equippedAccessoryId = nil }
        case .background:
            if state.backgroundId == item.contentValue { state.backgroundId = "snowy_nook" }
        case .effect, .phrasePack:
            break
        }
        persist()
    }

    func isEquipped(_ item: ShopItem) -> Bool {
        switch item.type {
        case .hat: return state.equippedHatId == item.id
        case .scarf: return state.equippedScarfId == item.id
        case .eyewear: return state.equippedEyewearId == item.id
        case .gloves: return state.equippedGlovesId == item.id
        case .accessory: return state.equippedAccessoryId == item.id
        case .background: return state.backgroundId == item.contentValue
        case .effect, .phrasePack: return false
        }
    }

    func updateCompanion(name: String? = nil, kind: AvatarKind? = nil) {
        if let kind {
            state.avatarKind = kind
        }
        if let name {
            state.companionName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Henry" : name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        persist()
    }

    func updatePlayerName(_ name: String) {
        state.playerName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        persist()
    }

    func updateAvatar(name: String? = nil, kind: AvatarKind? = nil) {
        updateCompanion(name: name, kind: kind)
    }

    func toggleSound() {
        state.soundEnabled.toggle()
        persist()
    }

    func resetPreviewData() {
        state = .starter
        phraseDismissWorkItem?.cancel()
        activePhrase = nil
        latestPointsBurst = 0
        celebrationTrigger = UUID()
        greetingTrigger = UUID()
        persist()
    }

    func grantTestPoints(_ amount: Int = 200) {
        state.pointsBalance += amount
        state.lifetimePoints += amount
        persist()
    }

    func isDueToday(_ task: TaskItem) -> Bool {
        switch task.recurrence {
        case .daily:
            return true
        case .weekly:
            guard let weekday = BobaWeekday(rawValue: calendar.component(.weekday, from: .now)) else { return false }
            return task.dueWeekdays.contains(weekday)
        case .oneOff:
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: .now)
        }
    }

    func isDueThisWeek(_ task: TaskItem) -> Bool {
        switch task.recurrence {
        case .daily:
            return false
        case .weekly:
            return !task.dueWeekdays.isEmpty
        case .oneOff:
            guard let dueDate = task.dueDate else { return false }
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: .now) else { return false }
            return interval.contains(dueDate)
        }
    }

    func isTaskCompleted(_ task: TaskItem) -> Bool {
        currentCompletionRecord(for: task) != nil
    }

    private var availablePhrases: [String] {
        var phrases = [
            "%s, that little win still counts.",
            "%s, tiny steps still make a path.",
            "Warm tea energy for you today, %s.",
            "%s, you are doing enough for this moment.",
            "I am officially cheering for you, %s.",
            "%s, your cozy momentum looks real from here.",
        ]
        if state.ownedItemIds.contains("phrases_supportive") {
            phrases += [
                "%s, you are allowed to be proud of small wins.",
                "%s, gentle progress is still progress.",
            ]
        }
        if state.ownedItemIds.contains("phrases_whimsy") {
            phrases += [
                "%s, emergency glitter report: vibes are excellent.",
                "%s, I would do a cartwheel, but I am very round.",
            ]
        }
        return phrases
    }

    private func removeCompletionAndPoints(for task: TaskItem) {
        if let record = currentCompletionRecord(for: task),
           let recordIndex = state.completions.firstIndex(where: { $0.id == record.id }) {
            let removed = state.completions.remove(at: recordIndex)
            state.pointsBalance = max(0, state.pointsBalance - removed.pointsAwarded - removed.goalBonusAwarded)
            state.lifetimePoints = max(0, state.lifetimePoints - removed.pointsAwarded - removed.goalBonusAwarded)
        }
        recalculateStreak()
    }

    private func recalculateStreak() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let qualifiedDays = Set(
            Dictionary(grouping: state.completions) {
                formatter.string(from: $0.completedAt)
            }
            .filter { $0.value.count >= 3 }
            .map(\.key)
        )
        let sortedDays = qualifiedDays.sorted()

        guard let lastDay = sortedDays.last else {
            state.streakCount = 0
            state.lastQualifiedDay = nil
            return
        }

        state.lastQualifiedDay = lastDay
        var streak = 1
        if sortedDays.count > 1 {
            var index = sortedDays.count - 1
            while index > 0 {
                guard
                    let current = formatter.date(from: sortedDays[index]),
                    let previous = formatter.date(from: sortedDays[index - 1]),
                    calendar.dateComponents([.day], from: previous, to: current).day == 1
                else {
                    break
                }
                streak += 1
                index -= 1
            }
        }
        state.streakCount = streak
    }

    private func migrateStarterBalanceIfNeeded() {
        if
            state.pointsBalance <= 45,
            state.lifetimePoints <= 45,
            state.completions.isEmpty,
            state.ownedItemIds.isEmpty
        {
            state.pointsBalance = 200
            state.lifetimePoints = 200
            persist()
        }

        if state.companionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            state.companionName = "Henry"
            persist()
        }

        if state.companionName.trimmingCharacters(in: .whitespacesAndNewlines) == "Boba" {
            state.companionName = "Henry"
            persist()
        }
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(state) {
            try? encoded.write(to: saveURL)
        }
    }

    private func currentCompletionRecord(for task: TaskItem) -> CompletionRecord? {
        switch task.recurrence {
        case .daily:
            return state.completions.first {
                $0.taskId == task.id && calendar.isDateInToday($0.completedAt)
            }
        case .weekly:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: .now) else { return nil }
            return state.completions.first {
                $0.taskId == task.id && interval.contains($0.completedAt)
            }
        case .oneOff:
            guard let dueDate = task.dueDate else { return nil }
            return state.completions.first {
                $0.taskId == task.id && calendar.isDate($0.completedAt, inSameDayAs: dueDate)
            }
        }
    }
}
