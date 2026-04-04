import SwiftUI

enum BobaTheme {
    static let primaryText = Color(red: 0.18, green: 0.14, blue: 0.12)
    static let secondaryText = Color(red: 0.36, green: 0.30, blue: 0.27)
    static let disabledText = Color(red: 0.55, green: 0.50, blue: 0.47)
    static let pageBackground = Color(red: 0.93, green: 0.89, blue: 0.85)
    static let cardBackground = Color(red: 0.98, green: 0.95, blue: 0.92)
    static let cardBackgroundStrong = Color(red: 0.95, green: 0.90, blue: 0.85)
    static let inputBackground = Color(red: 0.99, green: 0.97, blue: 0.95)
    static let border = Color(red: 0.73, green: 0.63, blue: 0.56)
    static let accent = Color(red: 0.52, green: 0.33, blue: 0.22)
    static let accentSoft = Color(red: 0.84, green: 0.74, blue: 0.66)
    static let selectedChip = Color(red: 0.55, green: 0.35, blue: 0.24)
    static let selectedChipText = Color.white
    static let unselectedChip = Color(red: 0.92, green: 0.87, blue: 0.82)
    static let unselectedChipText = Color(red: 0.25, green: 0.19, blue: 0.16)
    static let success = Color(red: 0.30, green: 0.49, blue: 0.34)
    static let warning = Color(red: 0.76, green: 0.59, blue: 0.56)
    static let featured = Color(red: 0.92, green: 0.84, blue: 0.72)
}

private struct TaskDraft {
    var title = ""
    var notes = ""
    var points = 10
    var tags: Set<BobaTag> = [.selfCare]
    var recurrence: TaskRecurrence = .daily
    var dueWeekdays: Set<BobaWeekday> = [.sunday]
    var dueDate: Date = .now

    init() {}

    init(task: TaskItem) {
        title = task.title
        notes = task.notes
        points = task.points
        tags = Set(task.tags)
        recurrence = task.recurrence
        dueWeekdays = Set(task.dueWeekdays)
        dueDate = task.dueDate ?? .now
    }
}

private enum CompanionSection: String, CaseIterable, Identifiable {
    case look
    case bag

    var id: String { rawValue }

    var title: String {
        switch self {
        case .look: return "Look"
        case .bag: return "Bag"
        }
    }
}

enum AppShellSection: String, CaseIterable, Identifiable {
    case home
    case tasks
    case shop
    case companion
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .shop: return "Shop"
        case .companion: return "Companion"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .shop: return "bag.fill"
        case .companion: return "face.smiling.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct BobaAppShell<Content: View>: View {
    @Binding var section: AppShellSection
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Text("Project Boba")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(BobaTheme.primaryText)

                Spacer()

                Picker("Section", selection: $section) {
                    ForEach(AppShellSection.allCases) { item in
                        Label(item.title, systemImage: item.systemImage)
                            .tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 560)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(BobaTheme.cardBackgroundStrong)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(BobaTheme.border.opacity(0.35))
                    .frame(height: 1)
                    .allowsHitTesting(false)
            }

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 1120, minHeight: 780)
        .background(BobaTheme.pageBackground)
    }
}

struct ContentView: View {
    @StateObject private var store = BobaStore()
    @State private var section: AppShellSection = .home

    var body: some View {
        BobaAppShell(section: $section) {
            switch section {
            case .home:
                HomeView(store: store)
            case .tasks:
                TasksView(store: store)
            case .shop:
                ShopView(store: store)
            case .companion:
                AvatarView(store: store)
            case .settings:
                SettingsView(store: store)
            }
        }
    }
}

private struct HomeView: View {
    @ObservedObject var store: BobaStore
    @State private var taskScope: HomeTaskScope = .today

    var body: some View {
        ZStack {
            BackgroundScene(sceneId: store.state.backgroundId, expanded: true)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    HomeStatsRow(store: store)
                    HomeCompanionSection(store: store)
                    TodayAtGlanceCard(store: store)
                        .frame(maxWidth: 780)

                    if let goal = store.goalOfTheDay {
                        FeaturedGoalCard(task: goal, onToggle: { store.toggleTaskCompletion(goal) })
                            .frame(maxWidth: 780)
                    }

                    QuickTasksCard(
                        store: store,
                        taskScope: $taskScope,
                        activeOpenTasks: activeOpenTasks,
                        activeCompletedTasks: activeCompletedTasks
                    )
                    .frame(maxWidth: 780)
                }
                .padding(28)
            }
        }
        .background(BobaTheme.pageBackground)
    }

    private var activeOpenTasks: [TaskItem] {
        switch taskScope {
        case .today: return store.openTodayTasks
        case .thisWeek: return store.openThisWeekTasks
        }
    }

    private var activeCompletedTasks: [TaskItem] {
        switch taskScope {
        case .today: return store.completedTodayTasks
        case .thisWeek: return store.completedThisWeekTasks
        }
    }
}

private struct HomeStatsRow: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        HStack(spacing: 16) {
            CozyStat(title: "Points", value: "\(store.state.pointsBalance)")
            CozyStat(title: "Daily", value: "\(store.dailyProgress.clampedCompleted)/\(store.dailyProgress.total)")
            CozyStat(title: "Weekly", value: "\(store.weeklyProgress.clampedCompleted)/\(store.weeklyProgress.total)")
        }
    }
}

private struct HomeCompanionSection: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        VStack(spacing: 12) {
            CompanionHero(store: store)

            Text(store.state.companionName)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(BobaTheme.primaryText)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(BobaTheme.cardBackground.opacity(0.96), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(BobaTheme.border.opacity(0.32), lineWidth: 1)
                        .allowsHitTesting(false)
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)

            Text("Tap your companion for a warm little reaction.")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(BobaTheme.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(BobaTheme.cardBackground.opacity(0.96), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(BobaTheme.border.opacity(0.35), lineWidth: 1)
                        .allowsHitTesting(false)
                )
        }
    }
}

private struct CompanionHero: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AvatarScene(store: store)
                .frame(height: 320)
                .onTapGesture { store.avatarTapped() }

            if let phrase = store.activePhrase {
                CompanionBubble(text: phrase)
                    .offset(x: -6, y: -58)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: store.activePhrase)
            }
        }
        .frame(maxWidth: 420)
    }
}

private struct TodayAtGlanceCard: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Today at a glance")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(BobaTheme.primaryText)
                ProgressWidget(title: "Daily Tasks", completed: store.dailyProgress.clampedCompleted, total: store.dailyProgress.total)
                ProgressWidget(title: "Weekly Tasks", completed: store.weeklyProgress.clampedCompleted, total: store.weeklyProgress.total)
            }
        }
    }
}

private struct QuickTasksCard: View {
    @ObservedObject var store: BobaStore
    @Binding var taskScope: HomeTaskScope
    let activeOpenTasks: [TaskItem]
    let activeCompletedTasks: [TaskItem]

    var body: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 16) {
                QuickTasksHeader(taskScope: $taskScope)

                if activeOpenTasks.isEmpty && activeCompletedTasks.isEmpty {
                    Text(emptyMessage)
                        .foregroundStyle(BobaTheme.secondaryText)
                } else {
                    TaskGroupList(tasks: activeOpenTasks, taskScope: taskScope, isCompleted: false, store: store)

                    if !activeCompletedTasks.isEmpty {
                        Divider().overlay(BobaTheme.border.opacity(0.45))
                        Text(completedLabel)
                            .font(.headline)
                            .foregroundStyle(BobaTheme.secondaryText)
                        TaskGroupList(tasks: activeCompletedTasks, taskScope: taskScope, isCompleted: true, store: store)
                    }
                }
            }
        }
    }

    private var emptyMessage: String {
        switch taskScope {
        case .today:
            return "Nothing is due today yet."
        case .thisWeek:
            return "No weekly tasks are due this week yet."
        }
    }

    private var completedLabel: String {
        switch taskScope {
        case .today:
            return "Completed today"
        case .thisWeek:
            return "Completed this week"
        }
    }
}

private struct QuickTasksHeader: View {
    @Binding var taskScope: HomeTaskScope

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Quick Tasks")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(BobaTheme.primaryText)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BobaTheme.secondaryText)
            }
            Spacer()
            PillSelector(selection: $taskScope, options: HomeTaskScope.allCases)
        }
    }

    private var subtitle: String {
        switch taskScope {
        case .today:
            return "Tasks due today"
        case .thisWeek:
            return "Weekly tasks due this week"
        }
    }
}

private struct TaskGroupList: View {
    let tasks: [TaskItem]
    let taskScope: HomeTaskScope
    let isCompleted: Bool
    @ObservedObject var store: BobaStore

    var body: some View {
        ForEach(tasks) { task in
            HomeTaskRow(
                task: task,
                mode: taskScope,
                isCompleted: isCompleted,
                onToggle: { store.toggleTaskCompletion(task) }
            )
        }
    }
}

private struct TasksView: View {
    @ObservedObject var store: BobaStore
    @State private var showingAddTaskSheet = false
    @State private var showingEditTaskSheet = false
    @State private var addTaskDraft = TaskDraft()
    @State private var editTaskDraft = TaskDraft()
    @State private var editingTaskOriginal: TaskItem?
    @State private var addTaskDebugReceiver = ""
    @State private var addTaskDebugValue = ""
    @State private var editTaskDebugReceiver = ""
    @State private var editTaskDebugValue = ""
    @State private var filter: TaskFilter = .today
    @State private var taskPendingDelete: TaskItem?
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CozyCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Task library")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(BobaTheme.primaryText)
                            Text("Create tasks from a separate native sheet so typing stays reliable on macOS.")
                                .foregroundStyle(BobaTheme.secondaryText)
                        }
                        Spacer()
                        Button("Add Task") {
                            prepareAddTaskDraft()
                        }
                        .buttonStyle(CozyButtonStyle())
                    }
                }

                CozyCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Task library")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(BobaTheme.primaryText)
                            Spacer()
                            TaskFilterPills(store: store, selection: $filter)
                        }

                        let filteredTasks = store.tasks(for: filter)
                        if filteredTasks.isEmpty {
                            VStack(spacing: 8) {
                                Text(emptyStateTitle)
                                    .font(.headline)
                                    .foregroundStyle(BobaTheme.secondaryText)
                                Text(emptyStateSubtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(BobaTheme.disabledText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        } else {
                            ForEach(Array(filteredTasks.enumerated()), id: \.element.id) { index, task in
                                TaskTile(
                                    task: task,
                                    isCompleted: store.isTaskCompleted(task),
                                    isFirst: index == 0,
                                    isLast: index == filteredTasks.count - 1,
                                    onToggleComplete: { store.toggleTaskCompletion(task) },
                                    onEdit: { prepareEditTaskDraft(task) },
                                    onDelete: {
                                        taskPendingDelete = task
                                        showingDeleteConfirmation = true
                                    },
                                    onMoveUp: { store.moveTask(task, direction: .up) },
                                    onMoveDown: { store.moveTask(task, direction: .down) }
                                )
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(BobaTheme.pageBackground)
        .sheet(isPresented: $showingAddTaskSheet) {
            AddTaskSheet(
                draft: $addTaskDraft,
                debugLastInputReceiver: $addTaskDebugReceiver,
                debugLastInputValue: $addTaskDebugValue,
                onCancel: { showingAddTaskSheet = false },
                onSave: saveAddTaskDraft
            )
        }
        .sheet(isPresented: $showingEditTaskSheet, onDismiss: {
            editingTaskOriginal = nil
        }) {
            TaskEditSheet(
                draft: $editTaskDraft,
                debugLastInputReceiver: $editTaskDebugReceiver,
                debugLastInputValue: $editTaskDebugValue,
                onCancel: {
                    showingEditTaskSheet = false
                    editingTaskOriginal = nil
                },
                onSave: saveEditedTaskDraft
            )
        }
        .alert("Delete task?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                taskPendingDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let task = taskPendingDelete {
                    store.deleteTask(task)
                }
                taskPendingDelete = nil
            }
        } message: {
            if let task = taskPendingDelete {
                Text("Are you sure you want to delete \"\(task.title)\"? This cannot be undone.")
            }
        }
    }

    private var emptyStateTitle: String {
        switch filter {
        case .today: return "No tasks due today"
        case .daily: return "No daily tasks yet"
        case .weekly: return "No weekly tasks yet"
        case .all: return "No tasks here yet"
        }
    }

    private var emptyStateSubtitle: String {
        switch filter {
        case .today: return "Tasks with today's schedule will appear here."
        case .daily: return "Add a daily task to get started."
        case .weekly: return "Add a weekly task to get started."
        case .all: return "Tap \"Add Task\" to create your first one."
        }
    }

    private func prepareAddTaskDraft() {
        addTaskDraft = TaskDraft()
        addTaskDebugReceiver = ""
        addTaskDebugValue = ""
        showingAddTaskSheet = true
    }

    private func prepareEditTaskDraft(_ task: TaskItem) {
        editingTaskOriginal = task
        editTaskDraft = TaskDraft(task: task)
        editTaskDebugReceiver = ""
        editTaskDebugValue = ""
        showingEditTaskSheet = true
    }

    private func saveAddTaskDraft() {
        store.addTask(
            title: addTaskDraft.title,
            notes: addTaskDraft.notes,
            points: addTaskDraft.points,
            tags: addTaskDraft.tags,
            recurrence: addTaskDraft.recurrence,
            dueWeekdays: addTaskDraft.dueWeekdays,
            dueDate: addTaskDraft.recurrence == .oneOff ? addTaskDraft.dueDate : nil
        )
        filter = .all
        showingAddTaskSheet = false
    }

    private func saveEditedTaskDraft() {
        guard let original = editingTaskOriginal else { return }
        let trimmedTitle = editTaskDraft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        let updated = TaskItem(
            id: original.id,
            title: trimmedTitle,
            notes: editTaskDraft.notes.trimmingCharacters(in: .whitespacesAndNewlines),
            points: max(5, editTaskDraft.points),
            tags: editTaskDraft.tags.sorted { $0.rawValue < $1.rawValue },
            isStarter: original.isStarter,
            isCompleted: original.isCompleted,
            recurrence: editTaskDraft.recurrence,
            dueWeekdays: editTaskDraft.dueWeekdays.sorted(),
            dueDate: editTaskDraft.recurrence == .oneOff ? editTaskDraft.dueDate : nil,
            createdAt: original.createdAt
        )
        store.updateTask(updated)
        filter = .all
        showingEditTaskSheet = false
        editingTaskOriginal = nil
    }
}

private struct ShopView: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ShopHeaderCard(store: store)

                ForEach(shopSections, id: \.title) { section in
                    ShopSectionView(section: section, store: store)
                }
            }
            .padding(24)
        }
        .background(BobaTheme.pageBackground)
    }

    private var shopSections: [(title: String, subtitle: String, items: [ShopItem])] {
        [
            ("Headwear", "The strongest current cosmetic category. Plush little toppers with clearer silhouettes.", store.shopItems.filter { $0.type == .hat }),
            ("Facewear", "Small face pieces that read clearly against the softer rig.", store.shopItems.filter { $0.type == .eyewear }),
            ("Cozy Extras", "Scarves, mittens, and little keepsakes.", store.shopItems.filter { [.scarf, .gloves, .accessory].contains($0.type) }),
            ("Scenes & Extras", "Background micro-scenes and extra phrase packs.", store.shopItems.filter { [.background, .phrasePack, .effect].contains($0.type) })
        ]
    }
}

private struct ShopHeaderCard: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        CozyCard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cozy shop")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(BobaTheme.primaryText)
                    Text("Small treats for your companion. Everything here uses the same local point balance you see on Home.")
                        .foregroundStyle(BobaTheme.secondaryText)
                }
                Spacer()
                Text("\(store.state.pointsBalance) points")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(BobaTheme.accent)
            }
        }
    }
}

private struct ShopSectionView: View {
    let section: (title: String, subtitle: String, items: [ShopItem])
    @ObservedObject var store: BobaStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.headline)
                .foregroundStyle(BobaTheme.primaryText)
            Text(section.subtitle)
                .font(.subheadline)
                .foregroundStyle(BobaTheme.secondaryText)
            ForEach(section.items) { item in
                ShopCard(item: item, store: store)
            }
        }
    }
}

private struct AvatarView: View {
    @ObservedObject var store: BobaStore
    @State private var section: CompanionSection = .look
    @State private var renamingCompanion = false
    @State private var companionNameDraft = ""
    @State private var renameDebugReceiver = ""
    @State private var renameDebugValue = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CozyCard {
                    VStack(alignment: .leading, spacing: 16) {
                        CompanionHeader(section: $section)
                        CompanionPreviewWithBadge(store: store)
                        CompanionSectionContent(
                            store: store,
                            section: section,
                            renamingCompanion: $renamingCompanion,
                            onStartRename: {
                                companionNameDraft = store.state.companionName
                                renameDebugReceiver = ""
                                renameDebugValue = ""
                                renamingCompanion = true
                            }
                        )
                    }
                }
            }
            .padding(24)
        }
        .background(BobaTheme.pageBackground)
        .sheet(isPresented: $renamingCompanion) {
            RenameCompanionSheet(
                name: $companionNameDraft,
                debugLastInputReceiver: $renameDebugReceiver,
                debugLastInputValue: $renameDebugValue,
                onCancel: { renamingCompanion = false },
                onSave: {
                    store.updateCompanion(name: companionNameDraft)
                    renamingCompanion = false
                }
            )
        }
    }
}

private struct CompanionHeader: View {
    @Binding var section: CompanionSection

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Companion")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(BobaTheme.primaryText)
                Text("Customize how your cozy buddy looks and what they are carrying.")
                    .foregroundStyle(BobaTheme.secondaryText)
            }
            Spacer()
            PillSelector(selection: $section, options: CompanionSection.allCases)
        }
    }
}

private struct CompanionPreviewWithBadge: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        ZStack(alignment: .topLeading) {
            CompanionPreviewPanel(store: store, title: store.state.companionName)
            if shouldShowBadge {
                PlayerBadgeOverlay(label: "For \(store.displayPlayerName)")
            }
        }
    }

    private var shouldShowBadge: Bool {
        !store.state.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct PlayerBadgeOverlay: View {
    let label: String

    var body: some View {
        SlotBadge(label: label)
            .padding(16)
    }
}

private struct CompanionSectionContent: View {
    @ObservedObject var store: BobaStore
    let section: CompanionSection
    @Binding var renamingCompanion: Bool
    let onStartRename: () -> Void

    var body: some View {
        switch section {
        case .look:
            AnyView(
                CompanionLookSection(
                    store: store,
                    renamingCompanion: $renamingCompanion,
                    onStartRename: onStartRename
                )
            )
        case .bag:
            AnyView(CompanionBagSection(store: store))
        }
    }
}

private struct CompanionLookSection: View {
    @ObservedObject var store: BobaStore
    @Binding var renamingCompanion: Bool
    let onStartRename: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Button("Rename companion") {
                    onStartRename()
                }
                .buttonStyle(CozyButtonStyle())
                Text("Current name: \(store.state.companionName)")
                    .foregroundStyle(BobaTheme.secondaryText)
            }

            Text("Choose a companion")
                .font(.headline)
                .foregroundStyle(BobaTheme.primaryText)

            VStack(spacing: 10) {
                ForEach(AvatarKind.allCases) { avatar in
                    AvatarChoiceRow(avatar: avatar, isSelected: store.state.avatarKind == avatar) {
                        store.updateCompanion(kind: avatar)
                    }
                }
            }
        }
    }
}

private struct AvatarChoiceRow: View {
    let avatar: AvatarKind
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                AvatarSpeciesBadge(kind: avatar)
                Text(avatar.title)
                    .foregroundStyle(BobaTheme.primaryText)
                Spacer()
                if isSelected {
                    Text("Selected")
                        .fontWeight(.semibold)
                        .foregroundStyle(BobaTheme.accent)
                }
            }
            .padding(12)
            .background(BobaTheme.cardBackgroundStrong, in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}

private struct CompanionBagSection: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Bag")
                .font(.headline)
                .foregroundStyle(BobaTheme.primaryText)
            Text("Owned items live here. Equip or unequip them and the preview updates right away, including backgrounds.")
                .foregroundStyle(BobaTheme.secondaryText)

            if store.ownedItems.isEmpty {
                Text("Buy something in the shop and it will appear here.")
                    .foregroundStyle(BobaTheme.secondaryText)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.ownedItems) { item in
                            OwnedItemRow(
                                item: item,
                                isEquipped: store.isEquipped(item),
                                onEquip: { store.equip(item) },
                                onUnequip: { store.unequip(item) }
                            )
                        }
                    }
                }
                .frame(maxHeight: 360)
            }
        }
    }
}

private struct SettingsView: View {
    @ObservedObject var store: BobaStore
    @State private var editingProfileName = false
    @State private var profileNameDraft = ""
    @State private var profileDebugReceiver = ""
    @State private var profileDebugValue = ""
    @State private var renamingCompanion = false
    @State private var companionNameDraft = ""
    @State private var renameDebugReceiver = ""
    @State private var renameDebugValue = ""
    @State private var showingResetConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CozyCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Profile")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(BobaTheme.primaryText)

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your name")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(BobaTheme.secondaryText)
                                Text(store.state.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not set" : store.state.playerName)
                                    .font(.headline)
                                    .foregroundStyle(BobaTheme.primaryText)
                            }
                            Button("Edit") {
                                profileNameDraft = store.state.playerName
                                profileDebugReceiver = ""
                                profileDebugValue = ""
                                editingProfileName = true
                            }
                            .buttonStyle(CozyButtonStyle(tint: BobaTheme.accentSoft, text: BobaTheme.primaryText))
                        }

                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Companion name")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(BobaTheme.secondaryText)
                                Text(store.state.companionName)
                                    .font(.headline)
                                    .foregroundStyle(BobaTheme.primaryText)
                            }
                            Button("Edit") {
                                companionNameDraft = store.state.companionName
                                renameDebugReceiver = ""
                                renameDebugValue = ""
                                renamingCompanion = true
                            }
                            .buttonStyle(CozyButtonStyle(tint: BobaTheme.accentSoft, text: BobaTheme.primaryText))
                        }

                        Text("Your name is used in supportive phrases. Your companion's name appears on the home screen.")
                            .font(.subheadline)
                            .foregroundStyle(BobaTheme.secondaryText)
                    }
                }

                CozyCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Comfort settings")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(BobaTheme.primaryText)

                        Toggle("Reward sound", isOn: Binding(
                            get: { store.state.soundEnabled },
                            set: { _ in store.toggleSound() }
                        ))
                        .toggleStyle(.switch)
                        .foregroundStyle(BobaTheme.primaryText)

                        Text("This preview saves local changes on your Mac, including profile name, companion name, tasks, avatar choice, owned items, equipped cosmetics, and current point balance.")
                            .foregroundStyle(BobaTheme.secondaryText)
                    }
                }

                CozyCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Preview Tools")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(BobaTheme.primaryText)
                        Text("These are for testing the preview build. Reset clears all data back to the starter state.")
                            .font(.subheadline)
                            .foregroundStyle(BobaTheme.secondaryText)

                        HStack {
                            Button("Add Test Points (+200)") {
                                store.grantTestPoints(200)
                            }
                            .buttonStyle(CozyButtonStyle())

                            Button("Reset All Data") {
                                showingResetConfirmation = true
                            }
                            .buttonStyle(CozyButtonStyle(tint: BobaTheme.warning, text: BobaTheme.primaryText))
                        }
                    }
                }

                CozyCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project Boba — macOS Preview")
                            .font(.headline)
                            .foregroundStyle(BobaTheme.primaryText)
                        Text("Preview Build")
                            .font(.subheadline)
                            .foregroundStyle(BobaTheme.secondaryText)
                    }
                }
            }
            .padding(24)
        }
        .background(BobaTheme.pageBackground)
        .alert("Reset All Data?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetPreviewData()
            }
        } message: {
            Text("This will erase all tasks, points, owned items, and names. This cannot be undone.")
        }
        .sheet(isPresented: $editingProfileName) {
            ProfileNameSheet(
                name: $profileNameDraft,
                debugLastInputReceiver: $profileDebugReceiver,
                debugLastInputValue: $profileDebugValue,
                onCancel: { editingProfileName = false },
                onSave: {
                    store.updatePlayerName(profileNameDraft)
                    editingProfileName = false
                }
            )
        }
        .sheet(isPresented: $renamingCompanion) {
            RenameCompanionSheet(
                name: $companionNameDraft,
                debugLastInputReceiver: $renameDebugReceiver,
                debugLastInputValue: $renameDebugValue,
                onCancel: { renamingCompanion = false },
                onSave: {
                    store.updateCompanion(name: companionNameDraft)
                    renamingCompanion = false
                }
            )
        }
    }
}

private struct ShopCard: View {
    let item: ShopItem
    @ObservedObject var store: BobaStore

    var body: some View {
        CozyCard {
            VStack(alignment: .leading, spacing: 14) {
                ShopCardHeader(item: item, store: store)
                ShopCardPreview(item: item, previewLine: previewLine, previewCallout: previewCallout)
                ShopCardActionRow(item: item, store: store, isOwnedOrEquippedBackground: isOwnedOrEquippedBackground)
            }
        }
    }

    private var isOwnedOrEquippedBackground: Bool {
        store.state.ownedItemIds.contains(item.id) || (item.type == .background && store.state.backgroundId == item.contentValue)
    }

    private var previewLine: String {
        switch item.slot {
        case .head: return "A warm topper that sits neatly on the plush head."
        case .face: return "Face accessories line up with the new softer eye area."
        case .neck: return "Wraps the neck anchor without hiding the cheeks."
        case .body: return "Pins a tiny trinket onto the center body anchor."
        case .hands: return "Covers both paws, including the waving hand."
        case .background: return "Changes the whole room mood in the live preview."
        case .effect: return "Reserved for future celebration polish."
        case .none: return "Adds more personality without using a wearable slot."
        }
    }

    private var previewCallout: String {
        switch item.type {
        case .background: return "Preview your companion in the new backdrop before you equip it."
        case .phrasePack: return "Unlocks more tap reactions and supportive phrases."
        case .effect: return "Planned for future sparkle styles."
        default: return "Cute, readable, and slot-aware in both the shop and bag preview."
        }
    }
}

private struct ShopCardHeader: View {
    let item: ShopItem
    @ObservedObject var store: BobaStore

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ItemThumbnail(item: item, equipped: store.isEquipped(item), style: .shop)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(BobaTheme.primaryText)
                    SlotBadge(label: item.slot.label)
                }
                Text(item.detail)
                    .foregroundStyle(BobaTheme.secondaryText)
                Text("Track affinity: \(item.requiredTag.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(BobaTheme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text("\(item.cost) pts")
                    .font(.headline)
                    .foregroundStyle(BobaTheme.accent)
                ShopStateBadge(item: item, store: store)
            }
        }
    }
}

private struct ShopCardPreview: View {
    let item: ShopItem
    let previewLine: String
    let previewCallout: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(BobaTheme.cardBackgroundStrong)
            ShopCardPreviewContent(item: item, previewLine: previewLine, previewCallout: previewCallout)
        }
        .frame(height: 94)
    }
}

private struct ShopCardPreviewContent: View {
    let item: ShopItem
    let previewLine: String
    let previewCallout: String

    var body: some View {
        HStack(spacing: 16) {
            AvatarMiniPreview(item: item)
            VStack(alignment: .leading, spacing: 4) {
                Text(previewLine)
                    .foregroundStyle(BobaTheme.primaryText)
                Text(previewCallout)
                    .font(.subheadline)
                    .foregroundStyle(BobaTheme.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

private struct ShopCardActionRow: View {
    let item: ShopItem
    @ObservedObject var store: BobaStore
    let isOwnedOrEquippedBackground: Bool

    var body: some View {
        HStack {
            if isOwnedOrEquippedBackground {
                ownedStateView
            } else {
                Button("Buy") { store.purchase(item) }
                    .buttonStyle(CozyButtonStyle())
                    .disabled(store.state.pointsBalance < item.cost)
            }
        }
    }

    private var ownedStateView: AnyView {
        if store.isEquipped(item) {
            return AnyView(
                Text("Equipped")
                    .fontWeight(.semibold)
                    .foregroundStyle(BobaTheme.success)
            )
        } else if item.isEquippable {
            return AnyView(
                HStack {
                    Text("Owned")
                        .fontWeight(.semibold)
                        .foregroundStyle(BobaTheme.secondaryText)
                    Button("Equip") { store.equip(item) }
                        .buttonStyle(CozyButtonStyle())
                }
            )
        } else {
            return AnyView(
                Text("Owned")
                    .fontWeight(.semibold)
                    .foregroundStyle(BobaTheme.success)
            )
        }
    }
}

private struct CompanionPreviewPanel: View {
    @ObservedObject var store: BobaStore
    let title: String

    var body: some View {
        ZStack {
            BackgroundScene(sceneId: store.state.backgroundId)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.12))
                .padding(14)
            VStack(spacing: 12) {
                AvatarScene(store: store)
                    .frame(height: 300)
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.95))
            }
            .padding(.vertical, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 380)
    }
}

private struct AvatarSpeciesBadge: View {
    let kind: AvatarKind

    var body: some View {
        Circle()
            .fill(AvatarPalette.forKind(kind).fur)
            .frame(width: 38, height: 38)
            .overlay(
                Circle()
                    .stroke(BobaTheme.border.opacity(0.45), lineWidth: 1)
                    .allowsHitTesting(false)
            )
    }
}

private struct OwnedItemRow: View {
    let item: ShopItem
    let isEquipped: Bool
    let onEquip: () -> Void
    let onUnequip: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ItemThumbnail(item: item, equipped: isEquipped, style: .shop)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(BobaTheme.primaryText)
                    SlotBadge(label: item.slot.label)
                }
                Text(item.slot == .none ? "Owned item" : "Slot: \(item.slot.label)")
                    .foregroundStyle(BobaTheme.secondaryText)
            }
            Spacer()
            if isEquipped {
                Text("Equipped")
                    .fontWeight(.semibold)
                    .foregroundStyle(BobaTheme.success)
                Button("Unequip", action: onUnequip)
                    .buttonStyle(CozyButtonStyle(tint: BobaTheme.accentSoft, text: BobaTheme.primaryText))
            } else if item.isEquippable {
                Button("Equip", action: onEquip)
                    .buttonStyle(CozyButtonStyle())
            } else {
                Text("Owned")
                    .fontWeight(.semibold)
                    .foregroundStyle(BobaTheme.secondaryText)
            }
        }
        .padding(14)
        .background(BobaTheme.cardBackgroundStrong, in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct FeaturedGoalCard: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Goal of the Day")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(BobaTheme.primaryText)
                Spacer()
                Text("+5 bonus")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(BobaTheme.accent.opacity(0.15), in: Capsule())
                    .foregroundStyle(BobaTheme.accent)
            }
            Text(task.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(BobaTheme.primaryText)
            if !task.notes.isEmpty {
                Text(task.notes)
                    .foregroundStyle(BobaTheme.secondaryText)
            }
            HStack {
                Text(task.recurrence.title)
                    .foregroundStyle(BobaTheme.secondaryText)
                Spacer()
                Text("\(task.points) base points")
                    .foregroundStyle(BobaTheme.accent)
                Button("Complete", action: onToggle)
                    .buttonStyle(CozyButtonStyle())
            }
        }
        .padding(22)
        .background(BobaTheme.featured, in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(BobaTheme.border.opacity(0.32), lineWidth: 1)
                .allowsHitTesting(false)
        )
    }
}

private struct ProgressWidget: View {
    let title: String
    let completed: Int
    let total: Int

    private var clampedCompleted: Int { min(max(completed, 0), total) }
    private var progressValue: Double { total == 0 ? 0 : Double(clampedCompleted) / Double(total) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(BobaTheme.primaryText)
                Spacer()
                if total > 0 && clampedCompleted == total {
                    Text("Completed!")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(BobaTheme.success.opacity(0.18), in: Capsule())
                        .foregroundStyle(BobaTheme.success)
                }
            }
            ProgressView(value: progressValue)
                .tint(BobaTheme.accent)
            Text("\(clampedCompleted)/\(total)")
                .foregroundStyle(BobaTheme.secondaryText)
        }
    }
}

private struct HomeTaskRow: View {
    let task: TaskItem
    let mode: HomeTaskScope
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(isCompleted ? BobaTheme.secondaryText : BobaTheme.primaryText)
                    .strikethrough(isCompleted)
                Text(detailLabel)
                    .foregroundStyle(BobaTheme.secondaryText)
                if mode == .thisWeek && !task.dueWeekdays.isEmpty {
                    FlowLayout(task.dueWeekdays) { weekday in
                        SlotBadge(label: weekday.shortTitle)
                    }
                }
            }
            Spacer()
            Text("\(task.points) pts")
                .foregroundStyle(BobaTheme.accent)
            Button(isCompleted ? "Reopen" : "Complete", action: onToggle)
                .buttonStyle(CozyButtonStyle(tint: isCompleted ? BobaTheme.accentSoft : BobaTheme.accent, text: isCompleted ? BobaTheme.primaryText : .white))
        }
        .padding(16)
        .background(isCompleted ? BobaTheme.cardBackground : BobaTheme.cardBackgroundStrong, in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(BobaTheme.border.opacity(0.28), lineWidth: 1)
                .allowsHitTesting(false)
        )
    }

    private var detailLabel: String {
        switch mode {
        case .today: return task.recurrenceLabel
        case .thisWeek: return task.notes.isEmpty ? "Due this week" : task.notes
        }
    }
}

private struct TaskTile: View {
    let task: TaskItem
    let isCompleted: Bool
    let isFirst: Bool
    let isLast: Bool
    let onToggleComplete: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(BobaTheme.success)
                    }
                    Text(task.title)
                        .font(.headline)
                        .foregroundStyle(isCompleted ? BobaTheme.disabledText : BobaTheme.primaryText)
                        .strikethrough(isCompleted)
                }
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .foregroundStyle(isCompleted ? BobaTheme.disabledText : BobaTheme.secondaryText)
                }
                HStack {
                    Text(task.recurrenceLabel)
                        .foregroundStyle(isCompleted ? BobaTheme.disabledText : BobaTheme.secondaryText)
                    Spacer()
                    Text("\(task.points) pts")
                        .foregroundStyle(isCompleted ? BobaTheme.disabledText : BobaTheme.accent)
                }
                FlowLayout(task.tags) { tag in
                    SlotBadge(label: tag.rawValue)
                }
            }

            HStack {
                Button(isCompleted ? "Reopen" : "Complete", action: onToggleComplete)
                    .buttonStyle(CozyButtonStyle(tint: isCompleted ? BobaTheme.accentSoft : BobaTheme.accent, text: isCompleted ? BobaTheme.primaryText : .white))
                Button("Edit", action: onEdit)
                    .buttonStyle(CozyButtonStyle(tint: BobaTheme.accentSoft, text: BobaTheme.primaryText))
                Button("Delete", action: onDelete)
                    .buttonStyle(CozyButtonStyle(tint: BobaTheme.warning, text: BobaTheme.primaryText))
                Spacer()
                Button(action: onMoveUp) { Image(systemName: "arrow.up") }
                    .buttonStyle(.borderless)
                    .disabled(isFirst)
                    .foregroundStyle(isFirst ? BobaTheme.disabledText : BobaTheme.primaryText)
                Button(action: onMoveDown) { Image(systemName: "arrow.down") }
                    .buttonStyle(.borderless)
                    .disabled(isLast)
                    .foregroundStyle(isLast ? BobaTheme.disabledText : BobaTheme.primaryText)
            }
        }
        .padding(18)
        .background(isCompleted ? BobaTheme.cardBackground : BobaTheme.cardBackgroundStrong, in: RoundedRectangle(cornerRadius: 22))
        .opacity(isCompleted ? 0.75 : 1.0)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(BobaTheme.border.opacity(0.35), lineWidth: 1)
                .allowsHitTesting(false)
        )
    }
}

private struct TaskEditSheet: View {
    @Binding var draft: TaskDraft
    @Binding var debugLastInputReceiver: String
    @Binding var debugLastInputValue: String
    let onCancel: () -> Void
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit task")
                .font(.title2.weight(.semibold))
                .foregroundStyle(BobaTheme.primaryText)

            LabeledField(title: "Task title") {
                TextField("Task title", text: titleBinding)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 42)
            }
            LabeledField(title: "Optional note") {
                TextEditor(text: noteBinding)
                    .font(.system(size: 15))
                    .padding(6)
                    .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(BobaTheme.border.opacity(0.45), lineWidth: 1)
                            .allowsHitTesting(false)
                    )
                    .frame(minHeight: 96)
            }
            InputDebugPanel(receiver: debugLastInputReceiver, value: debugLastInputValue)
            LabeledField(title: "Point value") {
                HStack(spacing: 12) {
                    Text("\(draft.points) points")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(BobaTheme.primaryText)
                        .padding(.horizontal, 14)
                        .frame(height: 42)
                        .background(BobaTheme.inputBackground, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(BobaTheme.border.opacity(0.55), lineWidth: 1)
                                .allowsHitTesting(false)
                        )
                    Stepper("", value: $draft.points, in: 5...100, step: 5)
                        .labelsHidden()
                }
            }
            RecurrenceEditor(draft: $draft)
            TagEditor(selectedTags: $draft.tags)
            HStack {
                Button("Cancel") {
                    onCancel()
                    dismiss()
                }
                    .buttonStyle(CozyButtonStyle(tint: BobaTheme.accentSoft, text: BobaTheme.primaryText))
                Button("Save changes") {
                    onSave()
                    dismiss()
                }
                .buttonStyle(CozyButtonStyle())
                .disabled(!canSave)
            }
        }
        .padding(24)
        .frame(minWidth: 560)
        .background(BobaTheme.pageBackground)
    }

    private var titleBinding: Binding<String> {
        Binding(
            get: { draft.title },
            set: { newValue in
                draft.title = newValue
                debugLastInputReceiver = "editTask.title"
                debugLastInputValue = newValue
            }
        )
    }

    private var noteBinding: Binding<String> {
        Binding(
            get: { draft.notes },
            set: { newValue in
                draft.notes = newValue
                debugLastInputReceiver = "editTask.note"
                debugLastInputValue = newValue
            }
        )
    }

    private var canSave: Bool {
        let hasTitle = !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasTags = !draft.tags.isEmpty
        let hasWeeklyDay = draft.recurrence != .weekly || !draft.dueWeekdays.isEmpty
        return hasTitle && hasTags && hasWeeklyDay
    }
}

private struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var draft: TaskDraft
    @Binding var debugLastInputReceiver: String
    @Binding var debugLastInputValue: String
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Task")
                .font(.title2.weight(.semibold))
                .foregroundStyle(BobaTheme.primaryText)

            LabeledField(title: "Task title") {
                TextField("Task title", text: titleBinding)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 42)
            }
            LabeledField(title: "Optional note") {
                TextEditor(text: noteBinding)
                    .font(.system(size: 15))
                    .padding(6)
                    .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(BobaTheme.border.opacity(0.45), lineWidth: 1)
                            .allowsHitTesting(false)
                    )
                    .frame(minHeight: 96)
            }
            InputDebugPanel(receiver: debugLastInputReceiver, value: debugLastInputValue)
            LabeledField(title: "Point value") {
                HStack(spacing: 12) {
                    Text("\(draft.points) points")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(BobaTheme.primaryText)
                        .padding(.horizontal, 14)
                        .frame(height: 42)
                        .background(BobaTheme.inputBackground, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(BobaTheme.border.opacity(0.55), lineWidth: 1)
                                .allowsHitTesting(false)
                        )
                    Stepper("", value: $draft.points, in: 5...100, step: 5)
                        .labelsHidden()
                    Text("Daily tasks usually stay smaller. Weekly chores can be worth more.")
                        .foregroundStyle(BobaTheme.secondaryText)
                }
            }
            RecurrenceEditor(draft: $draft)
            TagEditor(selectedTags: $draft.tags)

            HStack {
                Button("Cancel") {
                    onCancel()
                    dismiss()
                }
                    .buttonStyle(CozyButtonStyle(tint: BobaTheme.accentSoft, text: BobaTheme.primaryText))
                Button("Create task") {
                    onSave()
                    dismiss()
                }
                .buttonStyle(CozyButtonStyle())
                .disabled(!canSave)
            }
        }
        .padding(24)
        .frame(minWidth: 580)
        .background(BobaTheme.pageBackground)
    }

    private var titleBinding: Binding<String> {
        Binding(
            get: { draft.title },
            set: { newValue in
                draft.title = newValue
                debugLastInputReceiver = "addTask.title"
                debugLastInputValue = newValue
            }
        )
    }

    private var noteBinding: Binding<String> {
        Binding(
            get: { draft.notes },
            set: { newValue in
                draft.notes = newValue
                debugLastInputReceiver = "addTask.note"
                debugLastInputValue = newValue
            }
        )
    }

    private var canSave: Bool {
        let hasTitle = !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasTags = !draft.tags.isEmpty
        let hasWeeklyDay = draft.recurrence != .weekly || !draft.dueWeekdays.isEmpty
        return hasTitle && hasTags && hasWeeklyDay
    }
}

private struct RenameCompanionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var debugLastInputReceiver: String
    @Binding var debugLastInputValue: String
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rename companion")
                .font(.title2.weight(.semibold))
                .foregroundStyle(BobaTheme.primaryText)
            TextField("Companion name", text: nameBinding)
                .textFieldStyle(.roundedBorder)
                .frame(height: 42)
            InputDebugPanel(receiver: debugLastInputReceiver, value: debugLastInputValue)
            HStack {
                Button("Cancel") {
                    onCancel()
                    dismiss()
                }
                    .buttonStyle(CozyButtonStyle(tint: BobaTheme.accentSoft, text: BobaTheme.primaryText))
                Button("Save") {
                    onSave()
                    dismiss()
                }
                .buttonStyle(CozyButtonStyle())
            }
        }
        .padding(24)
        .frame(minWidth: 420)
        .background(BobaTheme.pageBackground)
    }

    private var nameBinding: Binding<String> {
        Binding(
            get: { name },
            set: { newValue in
                name = newValue
                debugLastInputReceiver = "renameCompanion.name"
                debugLastInputValue = newValue
            }
        )
    }
}

private struct ProfileNameSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var debugLastInputReceiver: String
    @Binding var debugLastInputValue: String
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile name")
                .font(.title2.weight(.semibold))
                .foregroundStyle(BobaTheme.primaryText)
            Text("This is the name your companion uses in supportive Home quotes.")
                .foregroundStyle(BobaTheme.secondaryText)
            TextField("Your name", text: nameBinding)
                .textFieldStyle(.roundedBorder)
                .frame(height: 42)
            InputDebugPanel(receiver: debugLastInputReceiver, value: debugLastInputValue)
            HStack {
                Button("Cancel") {
                    onCancel()
                    dismiss()
                }
                    .buttonStyle(CozyButtonStyle(tint: BobaTheme.accentSoft, text: BobaTheme.primaryText))
                Button("Save") {
                    onSave()
                    dismiss()
                }
                .buttonStyle(CozyButtonStyle())
            }
        }
        .padding(24)
        .frame(minWidth: 460)
        .background(BobaTheme.pageBackground)
    }

    private var nameBinding: Binding<String> {
        Binding(
            get: { name },
            set: { newValue in
                name = newValue
                debugLastInputReceiver = "profile.name"
                debugLastInputValue = newValue
            }
        )
    }
}

private struct InputDebugPanel: View {
    let receiver: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Last input receiver: \(receiver.isEmpty ? "none" : receiver)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BobaTheme.primaryText)
            Text("Last input value: \(valuePreview)")
                .font(.caption)
                .foregroundStyle(BobaTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(BobaTheme.cardBackgroundStrong, in: RoundedRectangle(cornerRadius: 12))
    }

    private var valuePreview: String {
        let sanitized = value.replacingOccurrences(of: "\n", with: "\\n")
        return sanitized.isEmpty ? "(empty)" : String(sanitized.prefix(80))
    }
}

private struct RecurrenceEditor: View {
    @Binding var draft: TaskDraft

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recurrence")
                .font(.headline)
                .foregroundStyle(BobaTheme.primaryText)

            PillSelector(selection: $draft.recurrence, options: TaskRecurrence.allCases)

            if draft.recurrence == .weekly {
                FlowLayout(BobaWeekday.allCases) { weekday in
                    ToggleChip(
                        title: weekday.shortTitle,
                        selected: draft.dueWeekdays.contains(weekday)
                    ) {
                        if draft.dueWeekdays.contains(weekday) {
                            draft.dueWeekdays.remove(weekday)
                        } else {
                            draft.dueWeekdays.insert(weekday)
                        }
                    }
                }
            }

            if draft.recurrence == .oneOff {
                DatePicker("Due date", selection: $draft.dueDate, displayedComponents: .date)
                    .labelsHidden()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(BobaTheme.inputBackground, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(BobaTheme.border.opacity(0.55), lineWidth: 1)
                            .allowsHitTesting(false)
                    )
                    .foregroundStyle(BobaTheme.primaryText)
            }
        }
    }
}

private struct TagEditor: View {
    @Binding var selectedTags: Set<BobaTag>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
                .foregroundStyle(BobaTheme.primaryText)
            FlowLayout(BobaTag.allCases) { tag in
                ToggleChip(title: tag.rawValue, selected: selectedTags.contains(tag)) {
                    if selectedTags.contains(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                }
            }
        }
    }
}

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(BobaTheme.primaryText)
            content
        }
    }
}

private struct CozyCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BobaTheme.cardBackground, in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(BobaTheme.border.opacity(0.28), lineWidth: 1)
                .allowsHitTesting(false)
        )
    }
}

private struct CozyStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(BobaTheme.primaryText)
            Text(title)
                .foregroundStyle(BobaTheme.secondaryText)
        }
        .frame(minWidth: 120)
        .padding(.vertical, 12)
        .background(BobaTheme.cardBackground, in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(BobaTheme.border.opacity(0.28), lineWidth: 1)
                .allowsHitTesting(false)
        )
    }
}

private struct SlotBadge: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(BobaTheme.unselectedChipText)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(BobaTheme.unselectedChip, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(BobaTheme.border.opacity(0.35), lineWidth: 1)
                    .allowsHitTesting(false)
            )
    }
}

private struct ToggleChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(selected ? BobaTheme.selectedChipText : BobaTheme.unselectedChipText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? BobaTheme.selectedChip : BobaTheme.unselectedChip, in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(BobaTheme.border.opacity(selected ? 0.0 : 0.35), lineWidth: 1)
                        .allowsHitTesting(false)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct PillSelector<Option: Identifiable & Hashable>: View {
    @Binding var selection: Option
    let options: [Option]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    Text(title(for: option))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selection == option ? BobaTheme.selectedChipText : BobaTheme.unselectedChipText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(selection == option ? BobaTheme.selectedChip : BobaTheme.unselectedChip, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(BobaTheme.border.opacity(selection == option ? 0.0 : 0.35), lineWidth: 1)
                                .allowsHitTesting(false)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func title(for option: Option) -> String {
        switch option {
        case let scope as HomeTaskScope: return scope.title
        case let filter as TaskFilter: return filter.title
        case let recurrence as TaskRecurrence: return recurrence.title
        case let section as CompanionSection: return section.title
        default: return String(describing: option.id)
        }
    }
}

private struct TaskFilterPills: View {
    @ObservedObject var store: BobaStore
    @Binding var selection: TaskFilter

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TaskFilter.allCases) { filter in
                let count = store.tasks(for: filter).count
                Button {
                    selection = filter
                } label: {
                    Text("\(filter.title) (\(count))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selection == filter ? BobaTheme.selectedChipText : BobaTheme.unselectedChipText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(selection == filter ? BobaTheme.selectedChip : BobaTheme.unselectedChip, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(BobaTheme.border.opacity(selection == filter ? 0.0 : 0.35), lineWidth: 1)
                                .allowsHitTesting(false)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct CozyButtonStyle: ButtonStyle {
    var tint: Color = BobaTheme.accent
    var text: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(tint.opacity(configuration.isPressed ? 0.82 : 1), in: Capsule())
            .foregroundStyle(text)
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    private let data: Data
    private let content: (Data.Element) -> Content

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(data) { item in
                content(item)
            }
        }
    }
}

#if false
private struct BackgroundScene: View {
    let sceneId: String
    var expanded: Bool = false

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                LinearGradient(
                    colors: BackgroundPalette.colors(for: sceneId),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                sceneContent(time: t)
            }
        }
    }

    @ViewBuilder
    private func sceneContent(time: TimeInterval) -> some View {
        switch sceneId {
        case "twilight_window":
            TwilightWindowScene(time: time, expanded: expanded)
        case "winter_market":
            WinterMarketScene(time: time, expanded: expanded)
        case "fireplace_nook":
            FireplaceNookScene(time: time, expanded: expanded)
        case "underwater":
            UnderwaterScene(time: time, expanded: expanded)
        default:
            SnowyNookScene(time: time, expanded: expanded)
        }
    }
}

private struct TwilightWindowScene: View {
    let time: TimeInterval
    let expanded: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.10))
                .frame(width: expanded ? 520 : 250, height: expanded ? 260 : 140)
                .offset(y: expanded ? -70 : -22)
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.30), lineWidth: 5)
                .frame(width: expanded ? 460 : 210, height: expanded ? 220 : 116)
                .offset(y: expanded ? -70 : -22)
            Rectangle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 5, height: expanded ? 220 : 116)
                .offset(y: expanded ? -70 : -22)
            Rectangle()
                .fill(Color.white.opacity(0.24))
                .frame(width: expanded ? 460 : 210, height: 5)
                .offset(y: expanded ? -70 : -22)
            ForEach(0..<9, id: \.self) { index in
                let flakeSize = CGFloat(4 + index % 3)
                Circle()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: flakeSize, height: flakeSize)
                    .offset(
                        x: CGFloat(-140 + index * 34),
                        y: CGFloat(-40 + sin(time + Double(index)) * 18)
                    )
            }
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.opacity(0.12))
                .frame(height: expanded ? 78 : 42)
                .offset(y: expanded ? 148 : 86)
        }
    }
}

private struct WinterMarketScene: View {
    let time: TimeInterval
    let expanded: Bool

    var body: some View {
        ZStack {
            HStack(spacing: expanded ? 42 : 18) {
                MarketStallView(color: Color(red: 0.73, green: 0.47, blue: 0.29), expanded: expanded, lanternOffset: sin(time) * 4)
                MarketStallView(color: Color(red: 0.60, green: 0.38, blue: 0.22), expanded: expanded, lanternOffset: sin(time + 1.2) * 4)
                if expanded {
                    MarketStallView(color: Color(red: 0.82, green: 0.58, blue: 0.34), expanded: expanded, lanternOffset: sin(time + 2.1) * 4)
                }
            }
            .offset(y: expanded ? 36 : 24)
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.12))
                .frame(height: expanded ? 82 : 44)
                .offset(y: expanded ? 152 : 92)
        }
    }
}

private struct FireplaceNookScene: View {
    let time: TimeInterval
    let expanded: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(red: 0.38, green: 0.24, blue: 0.20))
                .frame(width: expanded ? 250 : 132, height: expanded ? 180 : 100)
                .offset(x: expanded ? 130 : 60, y: expanded ? 10 : 12)
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.25, green: 0.14, blue: 0.12))
                .frame(width: expanded ? 150 : 82, height: expanded ? 92 : 54)
                .offset(x: expanded ? 130 : 60, y: expanded ? 18 : 18)
            FireplaceFlames(expanded: expanded, time: time)
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.79, green: 0.60, blue: 0.44))
                .frame(width: expanded ? 120 : 68, height: expanded ? 82 : 48)
                .offset(x: expanded ? -120 : -62, y: expanded ? 50 : 36)
            Circle()
                .fill(Color(red: 0.96, green: 0.82, blue: 0.52).opacity(0.14 + (sin(time * 1.4) + 1) * 0.06))
                .frame(width: expanded ? 190 : 108, height: expanded ? 190 : 108)
                .offset(x: expanded ? 110 : 56, y: expanded ? 2 : 8)
        }
    }
}

private struct FireplaceFlames: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        ForEach(0..<4, id: \.self) { index in
            let flameHeight: CGFloat = expanded ? 50 : 28
            let flameWidth: CGFloat = expanded ? 20 : 12
            let xBase: CGFloat = expanded ? 92 : 46
            let spacing: CGFloat = expanded ? 18 : 10
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.95, green: 0.65, blue: 0.30).opacity(0.7 - Double(index) * 0.1))
                .frame(width: flameWidth, height: flameHeight)
                .offset(x: xBase + CGFloat(index) * spacing, y: expanded ? 22 + sin(time + Double(index)) * 3 : 20)
        }
    }
}

private struct UnderwaterScene: View {
    let time: TimeInterval
    let expanded: Bool

    var body: some View {
        ZStack {
            UnderwaterLightRays(expanded: expanded)
            UnderwaterKelpRow(expanded: expanded, time: time)
            UnderwaterBubbles(expanded: expanded, time: time)
            UnderwaterFishRow(expanded: expanded, time: time)
        }
    }
}

private struct UnderwaterLightRays: View {
    let expanded: Bool

    var body: some View {
        ForEach(0..<4, id: \.self) { index in
            Capsule()
                .fill(Color.white.opacity(0.08))
                .frame(width: expanded ? 42 : 20, height: expanded ? 240 : 108)
                .rotationEffect(.degrees(Double(index * 8 - 12)))
                .offset(x: CGFloat(-150 + index * 110), y: expanded ? -24 : -10)
        }
    }
}

private struct UnderwaterKelpRow: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        HStack(alignment: .bottom, spacing: expanded ? 54 : 24) {
            UnderwaterKelp(height: expanded ? 142 : 68, time: time, phase: 0.2)
            UnderwaterKelp(height: expanded ? 178 : 86, time: time, phase: 1.0)
            UnderwaterKelp(height: expanded ? 156 : 74, time: time, phase: 2.2)
        }
        .offset(y: expanded ? 84 : 46)
    }
}

private struct UnderwaterKelp: View {
    let height: CGFloat
    let time: TimeInterval
    let phase: Double

    var body: some View {
        Capsule()
            .fill(Color(red: 0.34, green: 0.58, blue: 0.42).opacity(0.75))
            .frame(width: max(10, height * 0.08), height: height)
            .rotationEffect(.degrees(sin(time + phase) * 8))
    }
}

private struct UnderwaterBubbles: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        ForEach(0..<7, id: \.self) { index in
            let bubbleSize = CGFloat(expanded ? 14 + (index % 3) * 6 : 8 + (index % 3) * 3)
            let travel = CGFloat(expanded ? 240 : 118)
            Circle()
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
                .background(Circle().fill(Color.white.opacity(0.08)))
                .frame(width: bubbleSize, height: bubbleSize)
                .offset(
                    x: CGFloat(-150 + index * 52),
                    y: CGFloat((expanded ? 118 : 64) - Int((time * 32 + Double(index * 24)).truncatingRemainder(dividingBy: travel)))
                )
        }
    }
}

private struct UnderwaterFishRow: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        HStack(spacing: expanded ? 150 : 64) {
            FishSilhouette(scale: expanded ? 1.0 : 0.6)
                .offset(y: sin(time * 1.1) * 12)
            FishSilhouette(scale: expanded ? 0.86 : 0.52)
                .offset(y: sin(time * 1.15 + 1.4) * 10)
        }
        .offset(y: expanded ? 12 : 6)
    }
}

private struct FishSilhouette: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: -4 * scale) {
            Circle()
                .fill(Color(red: 0.17, green: 0.30, blue: 0.36).opacity(0.26))
                .frame(width: 30 * scale, height: 18 * scale)
            Triangle()
                .fill(Color(red: 0.17, green: 0.30, blue: 0.36).opacity(0.24))
                .frame(width: 14 * scale, height: 14 * scale)
                .rotationEffect(.degrees(-90))
        }
    }
}

private struct SnowyNookScene: View {
    let time: TimeInterval
    let expanded: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.14))
                .frame(width: expanded ? 320 : 160, height: expanded ? 180 : 90)
                .offset(y: expanded ? 120 : 74)
            Circle()
                .fill(Color.white.opacity(0.16 + (sin(time * 1.2) + 1) * 0.04))
                .frame(width: expanded ? 120 : 72, height: expanded ? 120 : 72)
                .offset(x: expanded ? -180 : -92, y: expanded ? -110 : -54)
        }
    }
}

private struct MarketStallView: View {
    let color: Color
    let expanded: Bool
    let lanternOffset: Double

    var body: some View {
        VStack(spacing: 0) {
            Triangle()
                .fill(color.opacity(0.95))
                .frame(width: expanded ? 110 : 56, height: expanded ? 38 : 20)
            RoundedRectangle(cornerRadius: 18)
                .fill(color)
                .frame(width: expanded ? 120 : 60, height: expanded ? 72 : 38)
            Circle()
                .fill(Color(red: 0.95, green: 0.79, blue: 0.45))
                .frame(width: expanded ? 16 : 10, height: expanded ? 16 : 10)
                .offset(y: lanternOffset)
        }
    }
}

private struct CompanionBubble: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(BobaTheme.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(BobaTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(BobaTheme.border.opacity(0.42), lineWidth: 1)
                        .allowsHitTesting(false)
                )
            Triangle()
                .fill(BobaTheme.inputBackground)
                .frame(width: 18, height: 10)
                .rotationEffect(.degrees(180))
                .offset(x: 24, y: -1)
        }
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
        .frame(maxWidth: 280, alignment: .trailing)
    }
}

private struct AvatarScene: View {
    @ObservedObject var store: BobaStore
    @State private var celebrateLift: CGFloat = 0
    @State private var celebrateScale: CGFloat = 1
    @State private var greetingBoost: Double = 0
    @State private var bodyBounce: CGFloat = 0
    @State private var blinkScale: CGFloat = 1
    @State private var confettiPhase: CGFloat = 0
    @State private var cheerBoost: Double = 0

    private var companionKind: AvatarKind { store.state.avatarKind }
    private var rig: AvatarRig { AvatarRig(kind: companionKind) }
    private var palette: AvatarPalette { AvatarPalette.forKind(companionKind) }

    var body: some View {
        TimelineView(.animation) { timeline in
            let metrics = AvatarAnimationMetrics(
                time: timeline.date.timeIntervalSinceReferenceDate,
                celebrateLift: celebrateLift,
                bodyBounce: bodyBounce,
                greetingBoost: greetingBoost,
                cheerBoost: cheerBoost
            )

            AvatarCanvas(
                rig: rig,
                palette: palette,
                metrics: metrics,
                blinkScale: blinkScale,
                confettiPhase: confettiPhase,
                celebrateScale: celebrateScale,
                avatarKind: companionKind,
                equippedHatStyle: equippedHatStyle,
                equippedEyewearStyle: equippedEyewearStyle,
                hasHat: store.state.equippedHatId != nil,
                hasEyewear: store.state.equippedEyewearId != nil,
                hasScarf: store.state.equippedScarfId != nil,
                hasGloves: store.state.equippedGlovesId != nil,
                hasAccessory: store.state.equippedAccessoryId != nil
            )
            .frame(width: 300, height: 300)
            .onReceive(store.$celebrationTrigger) { _ in
                withAnimation(.easeOut(duration: 0.12)) {
                    celebrateLift = -32
                    celebrateScale = 1.1
                    cheerBoost = 66
                    confettiPhase = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.7)) {
                        celebrateLift = 0
                        celebrateScale = 1
                        cheerBoost = 0
                    }
                }
                withAnimation(.easeOut(duration: 0.7)) {
                    confettiPhase = 0
                }
            }
            .onReceive(store.$greetingTrigger) { _ in
                withAnimation(.easeOut(duration: 0.16)) {
                    greetingBoost = -112
                    bodyBounce = -10
                    blinkScale = 0.14
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                    withAnimation(.easeInOut(duration: 0.12)) {
                        blinkScale = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.72)) {
                        greetingBoost = 0
                        bodyBounce = 0
                    }
                }
            }
        }
    }

    private var equippedHatStyle: String {
        AppState.shopInventory.first(where: { $0.id == store.state.equippedHatId })?.contentValue ?? "beanie"
    }

    private var equippedEyewearStyle: String {
        AppState.shopInventory.first(where: { $0.id == store.state.equippedEyewearId })?.contentValue ?? "round"
    }

}

private struct AvatarAnimationMetrics {
    let time: TimeInterval
    let celebrateLift: CGFloat
    let bodyBounce: CGFloat
    let greetingBoost: Double
    let cheerBoost: Double

    var idleFloat: CGFloat { sin(time * 1.1) * 2.8 }
    var idleEar: Double { sin(time * 1.45) * 3 }
    var idleTail: Double { sin(time * 1.4) * 6 }
    var idleWave: Double { sin(time * 1.7) * 1.8 }
    var waveAngle: Angle { .degrees(-22 + idleWave + greetingBoost + cheerBoost * 0.4) }
    var leftArmAngle: Angle { .degrees(-12 - cheerBoost) }
    var bodyOffsetY: CGFloat { idleFloat + bodyBounce + celebrateLift }
}

private struct AvatarCanvas: View {
    let rig: AvatarRig
    let palette: AvatarPalette
    let metrics: AvatarAnimationMetrics
    let blinkScale: CGFloat
    let confettiPhase: CGFloat
    let celebrateScale: CGFloat
    let avatarKind: AvatarKind
    let equippedHatStyle: String
    let equippedEyewearStyle: String
    let hasHat: Bool
    let hasEyewear: Bool
    let hasScarf: Bool
    let hasGloves: Bool
    let hasAccessory: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 272, height: 272)

            if confettiPhase > 0.001 {
                ConfettiBurst(progress: confettiPhase)
            }

            AvatarBodyLayer(
                rig: rig,
                palette: palette,
                metrics: metrics,
                blinkScale: blinkScale,
                avatarKind: avatarKind,
                equippedHatStyle: equippedHatStyle,
                equippedEyewearStyle: equippedEyewearStyle,
                hasHat: hasHat,
                hasEyewear: hasEyewear,
                hasScarf: hasScarf,
                hasAccessory: hasAccessory
            )
            .offset(y: metrics.bodyOffsetY)
            .scaleEffect(celebrateScale)

            AvatarArmLayer(
                color: palette.fur,
                angle: metrics.leftArmAngle,
                hasGloves: hasGloves,
                anchor: .topTrailing
            )
            .offset(x: rig.leftShoulder.x, y: rig.leftShoulder.y + metrics.bodyOffsetY)
            .scaleEffect(celebrateScale)

            AvatarArmLayer(
                color: palette.fur,
                angle: metrics.waveAngle,
                hasGloves: hasGloves,
                anchor: .topLeading
            )
            .offset(x: rig.rightShoulder.x, y: rig.rightShoulder.y + metrics.bodyOffsetY)
            .scaleEffect(celebrateScale)
        }
    }
}

private struct AvatarBodyLayer: View {
    let rig: AvatarRig
    let palette: AvatarPalette
    let metrics: AvatarAnimationMetrics
    let blinkScale: CGFloat
    let avatarKind: AvatarKind
    let equippedHatStyle: String
    let equippedEyewearStyle: String
    let hasHat: Bool
    let hasEyewear: Bool
    let hasScarf: Bool
    let hasAccessory: Bool

    var body: some View {
        ZStack {
            AvatarTailView(kind: avatarKind, palette: palette, idleTail: metrics.idleTail)
            AvatarBaseBody(palette: palette, blinkScale: blinkScale, avatarKind: avatarKind)
            if hasHat {
                AvatarHatView(style: equippedHatStyle)
                    .offset(x: rig.head.x, y: rig.head.y)
            }
            if hasScarf {
                AvatarScarfView()
                    .offset(x: rig.neck.x, y: rig.neck.y)
            }
            if hasAccessory {
                AvatarPinView()
                    .offset(x: rig.body.x, y: rig.body.y)
            }
            AvatarEarView(kind: avatarKind, palette: palette, idleEar: metrics.idleEar)
            if hasEyewear {
                AvatarEyewearView(style: equippedEyewearStyle)
                    .offset(x: rig.face.x, y: rig.face.y)
            }
        }
    }
}

private struct AvatarBaseBody: View {
    let palette: AvatarPalette
    let blinkScale: CGFloat
    let avatarKind: AvatarKind

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 74)
                .fill(palette.fur)
                .frame(width: 170, height: 186)
                .offset(y: 38)

            RoundedRectangle(cornerRadius: 54)
                .fill(palette.belly)
                .frame(width: 112, height: 104)
                .offset(y: 62)

            Circle()
                .fill(palette.fur)
                .frame(width: 152, height: 148)
                .offset(y: -32)

            Circle()
                .fill(palette.cheek)
                .frame(width: 78, height: 58)
                .offset(y: -4)

            AvatarEyes(blinkScale: blinkScale)
                .offset(y: -48)

            AvatarEyebrows()
                .offset(y: -66)

            HStack(spacing: 62) {
                Circle().fill(palette.blush).frame(width: 14, height: 14)
                Circle().fill(palette.blush).frame(width: 14, height: 14)
            }
            .offset(y: -18)

            AvatarFaceDetail(kind: avatarKind)
                .offset(y: -6)

            HStack(spacing: 76) {
                AvatarPawView(color: palette.paw)
                AvatarPawView(color: palette.paw)
            }
            .offset(y: 104)
        }
    }
}

private struct AvatarEyes: View {
    let blinkScale: CGFloat

    var body: some View {
        HStack(spacing: 44) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.17, green: 0.14, blue: 0.14))
                .frame(width: 22, height: 26 * blinkScale)
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.17, green: 0.14, blue: 0.14))
                .frame(width: 22, height: 26 * blinkScale)
        }
    }
}

private struct AvatarEyebrows: View {
    var body: some View {
        HStack(spacing: 44) {
            Capsule()
                .fill(Color(red: 0.33, green: 0.24, blue: 0.20).opacity(0.85))
                .frame(width: 18, height: 4)
                .rotationEffect(.degrees(-10))
            Capsule()
                .fill(Color(red: 0.33, green: 0.24, blue: 0.20).opacity(0.85))
                .frame(width: 18, height: 4)
                .rotationEffect(.degrees(10))
        }
    }
}

private struct AvatarFaceDetail: View {
    let kind: AvatarKind

    var body: some View {
        switch kind {
        case .penguin:
            AnyView(PenguinFaceDetail())
        case .cat:
            AnyView(CatFaceDetail())
        case .dog:
            AnyView(DogFaceDetail())
        case .bear, .bunny:
            AnyView(SimpleSnoutFaceDetail())
        }
    }
}

private struct PenguinFaceDetail: View {
    var body: some View {
        VStack(spacing: 4) {
            Diamond()
                .fill(Color(red: 0.95, green: 0.68, blue: 0.43))
                .frame(width: 24, height: 18)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.17, green: 0.14, blue: 0.14))
                .frame(width: 18, height: 4)
        }
    }
}

private struct CatFaceDetail: View {
    var body: some View {
        ZStack {
            Triangle()
                .fill(Color(red: 0.90, green: 0.62, blue: 0.57))
                .frame(width: 16, height: 14)
                .offset(y: -2)
            HStack(spacing: 24) {
                Capsule().fill(Color(red: 0.58, green: 0.44, blue: 0.38)).frame(width: 18, height: 2)
                Capsule().fill(Color(red: 0.58, green: 0.44, blue: 0.38)).frame(width: 18, height: 2)
            }
            .offset(y: 8)
        }
    }
}

private struct DogFaceDetail: View {
    var body: some View {
        VStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.7))
                .frame(width: 54, height: 34)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.23, green: 0.16, blue: 0.14))
                        .frame(width: 14, height: 14)
                        .offset(y: -2)
                )
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.23, green: 0.16, blue: 0.14))
                .frame(width: 16, height: 3)
        }
    }
}

private struct SimpleSnoutFaceDetail: View {
    var body: some View {
        VStack(spacing: 5) {
            Circle()
                .fill(Color(red: 0.30, green: 0.20, blue: 0.16))
                .frame(width: 14, height: 14)
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.30, green: 0.20, blue: 0.16))
                .frame(width: 16, height: 3)
        }
    }
}

private struct AvatarEarView: View {
    let kind: AvatarKind
    let palette: AvatarPalette
    let idleEar: Double

    var body: some View {
        switch kind {
        case .bunny:
            AnyView(BunnyEarGroup(palette: palette, idleEar: idleEar))
        case .cat:
            AnyView(CatEarGroup(palette: palette))
        case .dog:
            AnyView(DogEarGroup(palette: palette, idleEar: idleEar))
        case .bear:
            AnyView(BearEarGroup(palette: palette))
        case .penguin:
            AnyView(EmptyView())
        }
    }
}

private struct BunnyEarGroup: View {
    let palette: AvatarPalette
    let idleEar: Double

    var body: some View {
        HStack(spacing: 42) {
            AvatarEarShape(color: palette.fur, inner: palette.earInner)
                .rotationEffect(.degrees(-8 + idleEar))
            AvatarEarShape(color: palette.fur, inner: palette.earInner)
                .rotationEffect(.degrees(8 - idleEar))
        }
        .offset(y: -128)
    }
}

private struct CatEarGroup: View {
    let palette: AvatarPalette

    var body: some View {
        HStack(spacing: 52) {
            Triangle().fill(palette.fur).frame(width: 34, height: 32)
                .overlay(Triangle().fill(palette.earInner).frame(width: 20, height: 18).offset(y: 4))
            Triangle().fill(palette.fur).frame(width: 34, height: 32)
                .overlay(Triangle().fill(palette.earInner).frame(width: 20, height: 18).offset(y: 4))
        }
        .offset(y: -112)
    }
}

private struct DogEarGroup: View {
    let palette: AvatarPalette
    let idleEar: Double

    var body: some View {
        HStack(spacing: 72) {
            Capsule().fill(palette.earOuter).frame(width: 28, height: 70).rotationEffect(.degrees(18 + idleEar * 0.5))
            Capsule().fill(palette.earOuter).frame(width: 28, height: 70).rotationEffect(.degrees(-18 - idleEar * 0.5))
        }
        .offset(y: -82)
    }
}

private struct BearEarGroup: View {
    let palette: AvatarPalette

    var body: some View {
        HStack(spacing: 58) {
            Circle().fill(palette.fur).frame(width: 34, height: 34)
            Circle().fill(palette.fur).frame(width: 34, height: 34)
        }
        .offset(y: -102)
    }
}

private struct AvatarEarShape: View {
    let color: Color
    let inner: Color

    var body: some View {
        ZStack {
            Capsule().fill(color).frame(width: 28, height: 88)
            Capsule().fill(inner).frame(width: 14, height: 52).offset(y: 6)
        }
    }
}

private struct AvatarTailView: View {
    let kind: AvatarKind
    let palette: AvatarPalette
    let idleTail: Double

    var body: some View {
        Group {
            switch kind {
            case .penguin:
                EmptyView()
            case .bear:
                Circle()
                    .fill(palette.fur)
                    .frame(width: 26, height: 26)
                    .offset(x: 70, y: 88)
            case .bunny:
                Circle()
                    .fill(palette.tail)
                    .frame(width: 28, height: 28)
                    .offset(x: 74, y: 90)
            case .cat:
                Capsule()
                    .fill(palette.fur)
                    .frame(width: 16, height: 70)
                    .rotationEffect(.degrees(38 + idleTail))
                    .offset(x: 82, y: 76)
            case .dog:
                Capsule()
                    .fill(palette.fur)
                    .frame(width: 18, height: 64)
                    .rotationEffect(.degrees(48 + idleTail))
                    .offset(x: 80, y: 74)
            }
        }
    }
}

private struct AvatarArmLayer: View {
    let color: Color
    let angle: Angle
    let hasGloves: Bool
    let anchor: UnitPoint

    var body: some View {
        VStack(spacing: 0) {
            AvatarLimbView(color: color)
            if hasGloves {
                MittenView()
                    .offset(y: -4)
            }
        }
        .rotationEffect(angle, anchor: anchor)
    }
}

private struct AvatarLimbView: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(color)
            .frame(width: 28, height: 72)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 10, height: 56)
                    .offset(x: -5)
            )
    }
}

private struct AvatarPawView: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(color)
            .frame(width: 32, height: 20)
    }
}

private struct AvatarHatView: View {
    let style: String

    var body: some View {
        VStack(spacing: 0) {
            switch style {
            case "mooncap":
                Circle()
                    .fill(Color(red: 0.64, green: 0.47, blue: 0.61))
                    .frame(width: 18, height: 18)
                    .offset(y: 2)
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.57, green: 0.38, blue: 0.56))
                    .frame(width: 78, height: 40)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.44, green: 0.28, blue: 0.42))
                    .frame(width: 98, height: 12)
            case "berry_hood":
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.73, green: 0.34, blue: 0.32))
                    .frame(width: 98, height: 48)
                    .overlay(
                        HStack(spacing: 18) {
                            Circle().fill(Color(red: 0.47, green: 0.66, blue: 0.36)).frame(width: 14, height: 14)
                            Circle().fill(Color(red: 0.47, green: 0.66, blue: 0.36)).frame(width: 14, height: 14)
                        }
                        .offset(y: -16)
                    )
            default:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.72, green: 0.44, blue: 0.31))
                    .frame(width: 72, height: 32)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.56, green: 0.30, blue: 0.20))
                    .frame(width: 96, height: 12)
            }
        }
    }
}

private struct AvatarScarfView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.88, green: 0.77, blue: 0.58))
                .frame(width: 112, height: 24)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.77, green: 0.56, blue: 0.36))
                .frame(width: 20, height: 52)
                .offset(x: 28, y: 28)
        }
        .offset(y: 8)
    }
}

private struct AvatarPinView: View {
    var body: some View {
        Circle()
            .fill(Color(red: 0.92, green: 0.75, blue: 0.29))
            .frame(width: 18, height: 18)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                    .allowsHitTesting(false)
            )
    }
}

private struct AvatarEyewearView: View {
    let style: String

    var body: some View {
        Group {
            switch style {
            case "heart_specs":
                HStack(spacing: 8) {
                    HeartFrame()
                        .stroke(Color(red: 0.39, green: 0.24, blue: 0.28), lineWidth: 3.6)
                        .frame(width: 24, height: 22)
                    Rectangle()
                        .fill(Color(red: 0.39, green: 0.24, blue: 0.28))
                        .frame(width: 12, height: 3.6)
                    HeartFrame()
                        .stroke(Color(red: 0.39, green: 0.24, blue: 0.28), lineWidth: 3.6)
                        .frame(width: 24, height: 22)
                }
            case "sleepy_stars":
                HStack(spacing: 30) {
                    Image(systemName: "sparkle").foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.35))
                    Image(systemName: "sparkle").foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.35))
                }
            default:
                HStack(spacing: 8) {
                    Circle().stroke(Color(red: 0.27, green: 0.21, blue: 0.18), lineWidth: 3.6).frame(width: 26, height: 26)
                    Rectangle().fill(Color(red: 0.27, green: 0.21, blue: 0.18)).frame(width: 14, height: 3.6)
                    Circle().stroke(Color(red: 0.27, green: 0.21, blue: 0.18), lineWidth: 3.6).frame(width: 26, height: 26)
                }
            }
        }
    }
}

private struct ConfettiBurst: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<14, id: \.self) { index in
                let angle = Double(index) / 14.0 * .pi * 2
                RoundedRectangle(cornerRadius: 3)
                    .fill(color(for: index))
                    .frame(width: index.isMultiple(of: 2) ? 12 : 8, height: 8)
                    .offset(
                        x: cos(angle) * Double(progress * 86),
                        y: sin(angle) * Double(progress * 62) - Double(progress * 22)
                    )
                    .opacity(Double(progress))
                    .rotationEffect(.degrees(Double(index * 19)))
            }
        }
    }

    private func color(for index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.93, green: 0.65, blue: 0.38),
            Color(red: 0.96, green: 0.82, blue: 0.49),
            Color(red: 0.74, green: 0.86, blue: 0.67),
            Color(red: 0.72, green: 0.79, blue: 0.92)
        ]
        return colors[index % colors.count]
    }
}

private struct AvatarRig {
    let head: CGPoint
    let face: CGPoint
    let neck: CGPoint
    let body: CGPoint
    let leftHand: CGPoint
    let rightHand: CGPoint
    let leftShoulder: CGPoint
    let rightShoulder: CGPoint

    init(kind: AvatarKind) {
        switch kind {
        case .penguin:
            head = CGPoint(x: 0, y: -94)
            face = CGPoint(x: 0, y: -46)
            neck = CGPoint(x: 0, y: 26)
            body = CGPoint(x: 40, y: 18)
            leftHand = CGPoint(x: -64, y: 38)
            rightHand = CGPoint(x: 62, y: 38)
            leftShoulder = CGPoint(x: -62, y: 14)
            rightShoulder = CGPoint(x: 62, y: 14)
        case .bear:
            head = CGPoint(x: 0, y: -94)
            face = CGPoint(x: 0, y: -44)
            neck = CGPoint(x: 0, y: 28)
            body = CGPoint(x: 38, y: 18)
            leftHand = CGPoint(x: -66, y: 38)
            rightHand = CGPoint(x: 66, y: 38)
            leftShoulder = CGPoint(x: -64, y: 16)
            rightShoulder = CGPoint(x: 64, y: 16)
        case .bunny:
            head = CGPoint(x: 0, y: -102)
            face = CGPoint(x: 0, y: -44)
            neck = CGPoint(x: 0, y: 28)
            body = CGPoint(x: 38, y: 18)
            leftHand = CGPoint(x: -62, y: 40)
            rightHand = CGPoint(x: 62, y: 40)
            leftShoulder = CGPoint(x: -60, y: 18)
            rightShoulder = CGPoint(x: 60, y: 18)
        case .cat:
            head = CGPoint(x: 0, y: -98)
            face = CGPoint(x: 0, y: -46)
            neck = CGPoint(x: 0, y: 28)
            body = CGPoint(x: 38, y: 18)
            leftHand = CGPoint(x: -64, y: 40)
            rightHand = CGPoint(x: 64, y: 40)
            leftShoulder = CGPoint(x: -62, y: 18)
            rightShoulder = CGPoint(x: 62, y: 18)
        case .dog:
            head = CGPoint(x: 0, y: -96)
            face = CGPoint(x: 0, y: -44)
            neck = CGPoint(x: 0, y: 28)
            body = CGPoint(x: 38, y: 18)
            leftHand = CGPoint(x: -66, y: 40)
            rightHand = CGPoint(x: 66, y: 40)
            leftShoulder = CGPoint(x: -64, y: 18)
            rightShoulder = CGPoint(x: 64, y: 18)
        }
    }
}

private struct AvatarPalette {
    let fur: Color
    let belly: Color
    let cheek: Color
    let blush: Color
    let paw: Color
    let tail: Color
    let earInner: Color
    let earOuter: Color

    static func forKind(_ kind: AvatarKind) -> AvatarPalette {
        switch kind {
        case .penguin:
            return AvatarPalette(
                fur: Color(red: 0.33, green: 0.43, blue: 0.50),
                belly: Color(red: 0.96, green: 0.97, blue: 0.98),
                cheek: Color(red: 0.95, green: 0.95, blue: 0.97),
                blush: Color(red: 0.94, green: 0.78, blue: 0.78),
                paw: Color(red: 0.91, green: 0.73, blue: 0.52),
                tail: Color.clear,
                earInner: Color.clear,
                earOuter: Color.clear
            )
        case .bear:
            return AvatarPalette(
                fur: Color(red: 0.60, green: 0.46, blue: 0.38),
                belly: Color(red: 0.92, green: 0.84, blue: 0.78),
                cheek: Color(red: 0.94, green: 0.86, blue: 0.80),
                blush: Color(red: 0.92, green: 0.76, blue: 0.72),
                paw: Color(red: 0.88, green: 0.74, blue: 0.66),
                tail: Color(red: 0.60, green: 0.46, blue: 0.38),
                earInner: Color(red: 0.89, green: 0.73, blue: 0.69),
                earOuter: Color(red: 0.60, green: 0.46, blue: 0.38)
            )
        case .bunny:
            return AvatarPalette(
                fur: Color(red: 0.95, green: 0.87, blue: 0.90),
                belly: Color(red: 0.99, green: 0.97, blue: 0.98),
                cheek: Color(red: 0.99, green: 0.94, blue: 0.95),
                blush: Color(red: 0.95, green: 0.78, blue: 0.82),
                paw: Color(red: 0.92, green: 0.82, blue: 0.85),
                tail: Color(red: 0.99, green: 0.97, blue: 0.98),
                earInner: Color(red: 0.96, green: 0.77, blue: 0.82),
                earOuter: Color(red: 0.95, green: 0.87, blue: 0.90)
            )
        case .cat:
            return AvatarPalette(
                fur: Color(red: 0.76, green: 0.57, blue: 0.42),
                belly: Color(red: 0.96, green: 0.89, blue: 0.82),
                cheek: Color(red: 0.97, green: 0.90, blue: 0.84),
                blush: Color(red: 0.93, green: 0.75, blue: 0.72),
                paw: Color(red: 0.91, green: 0.78, blue: 0.70),
                tail: Color(red: 0.76, green: 0.57, blue: 0.42),
                earInner: Color(red: 0.94, green: 0.78, blue: 0.74),
                earOuter: Color(red: 0.76, green: 0.57, blue: 0.42)
            )
        case .dog:
            return AvatarPalette(
                fur: Color(red: 0.67, green: 0.50, blue: 0.34),
                belly: Color(red: 0.93, green: 0.84, blue: 0.75),
                cheek: Color(red: 0.95, green: 0.87, blue: 0.79),
                blush: Color(red: 0.92, green: 0.76, blue: 0.72),
                paw: Color(red: 0.88, green: 0.74, blue: 0.64),
                tail: Color(red: 0.67, green: 0.50, blue: 0.34),
                earInner: Color(red: 0.84, green: 0.66, blue: 0.53),
                earOuter: Color(red: 0.59, green: 0.43, blue: 0.29)
            )
        }
    }
}

#endif

private struct ItemThumbnail: View {
    let item: ShopItem
    let equipped: Bool
    var style: ThumbnailStyle = .standard

    var body: some View {
        let backgroundColors: [Color] = thumbnailBackground
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: style.size, height: style.size)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(equipped ? BobaTheme.accent : BobaTheme.border.opacity(0.35), lineWidth: equipped ? 2 : 1)
                        .allowsHitTesting(false)
                )

            ItemThumbnailContent(item: item, style: style)
        }
    }

    private var thumbnailBackground: [Color] {
        switch item.type {
        case .background:
            return BackgroundPalette.colors(for: item.contentValue)
        default:
            return [BobaTheme.inputBackground, BobaTheme.cardBackgroundStrong]
        }
    }
}

private struct ItemThumbnailContent: View {
    let item: ShopItem
    let style: ThumbnailStyle

    var body: some View {
        switch item.type {
        case .hat:
            AnyView(HatThumbnailView(contentValue: item.contentValue))
        case .scarf:
            AnyView(ScarfThumbnailView())
        case .eyewear:
            AnyView(EyewearThumbnailView(contentValue: item.contentValue))
        case .gloves:
            AnyView(GlovesThumbnailView())
        case .accessory:
            AnyView(AccessoryThumbnailView())
        case .background:
            AnyView(BackgroundThumbnailView(sceneId: item.contentValue, size: style.size))
        case .effect:
            AnyView(SymbolThumbnailView(systemName: "sparkles"))
        case .phrasePack:
            AnyView(SymbolThumbnailView(systemName: "quote.bubble.fill"))
        }
    }
}

private struct HatThumbnailView: View {
    let contentValue: String

    var body: some View {
        switch contentValue {
        case "mooncap":
            AnyView(
                VStack(spacing: 0) {
                    Circle().fill(Color(red: 0.69, green: 0.55, blue: 0.75)).frame(width: 12, height: 12).offset(y: 2)
                    RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.61, green: 0.43, blue: 0.67)).frame(width: 38, height: 24)
                    RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.46, green: 0.31, blue: 0.49)).frame(width: 48, height: 10)
                }
            )
        case "berry_hood":
            AnyView(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.76, green: 0.38, blue: 0.36))
                    .frame(width: 44, height: 34)
                    .overlay(
                        HStack(spacing: 10) {
                            Circle().fill(Color(red: 0.46, green: 0.66, blue: 0.35)).frame(width: 9, height: 9)
                            Circle().fill(Color(red: 0.46, green: 0.66, blue: 0.35)).frame(width: 9, height: 9)
                        }
                        .offset(y: -11)
                    )
            )
        default:
            AnyView(
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.74, green: 0.47, blue: 0.34)).frame(width: 34, height: 20)
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.56, green: 0.30, blue: 0.20)).frame(width: 48, height: 12)
                }
            )
        }
    }
}

private struct ScarfThumbnailView: View {
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.91, green: 0.81, blue: 0.61)).frame(width: 20, height: 32)
            RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.77, green: 0.55, blue: 0.35)).frame(width: 12, height: 26)
        }
    }
}

private struct EyewearThumbnailView: View {
    let contentValue: String

    var body: some View {
        switch contentValue {
        case "heart_specs":
            AnyView(
                HStack(spacing: 4) {
                    HeartFrame()
                        .stroke(BobaTheme.primaryText, lineWidth: 2.6)
                        .frame(width: 18, height: 16)
                    Rectangle().fill(BobaTheme.primaryText).frame(width: 8, height: 2)
                    HeartFrame()
                        .stroke(BobaTheme.primaryText, lineWidth: 2.6)
                        .frame(width: 18, height: 16)
                }
            )
        case "sleepy_stars":
            AnyView(
                HStack(spacing: 10) {
                    Image(systemName: "sparkle").foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.35))
                    Image(systemName: "sparkle").foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.35))
                }
            )
        default:
            AnyView(
                HStack(spacing: 5) {
                    Circle().stroke(BobaTheme.primaryText, lineWidth: 2.5).frame(width: 20, height: 20)
                    Rectangle().fill(BobaTheme.primaryText).frame(width: 10, height: 2.5)
                    Circle().stroke(BobaTheme.primaryText, lineWidth: 2.5).frame(width: 20, height: 20)
                }
            )
        }
    }
}

private struct GlovesThumbnailView: View {
    var body: some View {
        HStack(spacing: 8) {
            MittenView().scaleEffect(0.72)
            MittenView().scaleEffect(0.72)
        }
    }
}

private struct AccessoryThumbnailView: View {
    var body: some View {
        Circle()
            .fill(Color(red: 0.92, green: 0.75, blue: 0.29))
            .frame(width: 20, height: 20)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                    .allowsHitTesting(false)
            )
    }
}

private struct BackgroundThumbnailView: View {
    let sceneId: String
    let size: CGFloat

    var body: some View {
        BackgroundScene(sceneId: sceneId)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .frame(width: size - 10, height: size - 10)
            .clipped()
    }
}

private struct SymbolThumbnailView: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 24))
            .foregroundStyle(BobaTheme.accent)
    }
}

private enum ThumbnailStyle {
    case standard
    case shop

    var size: CGFloat {
        switch self {
        case .standard: return 58
        case .shop: return 84
        }
    }
}

private struct ShopStateBadge: View {
    let item: ShopItem
    @ObservedObject var store: BobaStore

    var body: some View {
        Text(label)
            .font(.caption.weight(.bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background, in: Capsule())
    }

    private var label: String {
        if store.isEquipped(item) {
            return "Equipped"
        }
        if store.state.ownedItemIds.contains(item.id) || (item.type == .background && store.state.backgroundId == item.contentValue) {
            return "Owned"
        }
        return "Buy"
    }

    private var foreground: Color {
        store.isEquipped(item) ? BobaTheme.success : BobaTheme.accent
    }

    private var background: Color {
        store.isEquipped(item) ? BobaTheme.success.opacity(0.18) : BobaTheme.accentSoft.opacity(0.38)
    }
}

private struct AvatarMiniPreview: View {
    let item: ShopItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(BobaTheme.inputBackground)
                .frame(width: 72, height: 72)
            ItemThumbnail(item: item, equipped: false, style: .standard)
        }
    }
}

#if false
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct HeartFrame: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let top = rect.height * 0.28
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.height * 0.42),
            control1: CGPoint(x: rect.midX - rect.width * 0.18, y: rect.maxY - rect.height * 0.12),
            control2: CGPoint(x: rect.minX, y: rect.height * 0.68)
        )
        path.addArc(
            center: CGPoint(x: rect.minX + rect.width * 0.28, y: top),
            radius: rect.width * 0.2,
            startAngle: .degrees(200),
            endAngle: .degrees(20),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: rect.maxX - rect.width * 0.28, y: top),
            radius: rect.width * 0.2,
            startAngle: .degrees(160),
            endAngle: .degrees(-20),
            clockwise: true
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.height * 0.68),
            control2: CGPoint(x: rect.midX + rect.width * 0.18, y: rect.maxY - rect.height * 0.12)
        )
        return path
    }
}
#endif

private extension TaskItem {
    var recurrenceLabel: String {
        switch recurrence {
        case .daily:
            return "Daily"
        case .weekly:
            if dueWeekdays.isEmpty { return "Weekly" }
            return "Weekly • " + dueWeekdays.map(\.shortTitle).joined(separator: ", ")
        case .oneOff:
            if let dueDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "One-off • \(formatter.string(from: dueDate))"
            }
            return "One-off"
        }
    }
}

private extension AvatarSlot {
    var label: String {
        switch self {
        case .head: return "Head"
        case .face: return "Face"
        case .neck: return "Neck"
        case .body: return "Body"
        case .hands: return "Hands"
        case .background: return "Background"
        case .effect: return "Effect"
        case .none: return "Extra"
        }
    }
}
