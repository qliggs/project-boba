import SwiftUI

struct ContentView: View {
    @StateObject private var store = BobaStore()

    var body: some View {
        TabView {
            HomeView(store: store)
                .tabItem { Label("Home", systemImage: "house.fill") }
            TasksView(store: store)
                .tabItem { Label("Tasks", systemImage: "checklist") }
            ShopView(store: store)
                .tabItem { Label("Shop", systemImage: "bag.fill") }
            AvatarView(store: store)
                .tabItem { Label("Avatar", systemImage: "face.smiling.fill") }
            SettingsView(store: store)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .frame(minWidth: 1080, minHeight: 760)
    }
}

private struct HomeView: View {
    @ObservedObject var store: BobaStore
    @State private var avatarLift: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(colors: BackgroundPalette.colors(for: store.state.backgroundId), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    CozyStat(title: "Points", value: "\(store.state.pointsBalance)")
                    CozyStat(title: "Streak", value: "\(store.state.streakCount) days")
                    CozyStat(title: "Today", value: "\(store.todayCompletedCount)/3")
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))

                if let phrase = store.activePhrase {
                    Text(phrase)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24))
                        .frame(maxWidth: 520)
                }

                ZStack {
                    if store.latestPointsBurst > 0 {
                        Text("✨ +\(store.latestPointsBurst)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color(red: 0.55, green: 0.32, blue: 0.18))
                            .offset(y: -150)
                    }
                    AvatarScene(store: store)
                        .offset(y: avatarLift)
                        .onTapGesture { store.requestPhrase() }
                }
                .onReceive(store.$latestPointsBurst) { burst in
                    guard burst > 0 else { return }
                    withAnimation(.easeOut(duration: 0.16)) { avatarLift = -18 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.7)) { avatarLift = 0 }
                    }
                }

                Text(store.state.avatarName)
                    .font(.system(size: 34, weight: .semibold, design: .serif))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Gentle goal")
                        .font(.title2.weight(.semibold))
                    ProgressView(value: min(Double(store.todayCompletedCount) / 3.0, 1.0))
                    Text("\(store.todayCompletedCount) of 3 tasks completed today")
                    Text("Three completed tasks makes today count toward the streak. Missing a day never removes what you've already done.")
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .frame(maxWidth: 720)
                .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28))

                QuickTasksPanel(store: store)
            }
            .padding(28)
        }
    }
}

private struct TasksView: View {
    @ObservedObject var store: BobaStore
    @State private var title = ""
    @State private var notes = ""
    @State private var points = "10"
    @State private var selectedTags: Set<BobaTag> = [.selfCare]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add custom task")
                        .font(.title2.weight(.semibold))
                    TextField("Task title", text: $title)
                    TextField("Optional note", text: $notes)
                    TextField("Points", text: $points)
                    FlowLayout(BobaTag.allCases) { tag in
                        TagChip(title: tag.rawValue, selected: selectedTags.contains(tag)) {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                    Button("Save task") {
                        store.addTask(title: title, notes: notes, points: Int(points) ?? 10, tags: selectedTags)
                        title = ""
                        notes = ""
                        points = "10"
                        selectedTags = [.selfCare]
                    }
                }
                .textFieldStyle(.roundedBorder)
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Master to-do list")
                        .font(.title2.weight(.semibold))
                    ForEach(store.state.tasks) { task in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(task.title).font(.headline)
                                if !task.notes.isEmpty {
                                    Text(task.notes).foregroundStyle(.secondary)
                                }
                                FlowLayout(task.tags) { tag in
                                    Text(tag.rawValue)
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.65), in: Capsule())
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("\(task.points) pts").foregroundStyle(.brown)
                                Button {
                                    store.complete(task)
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            }
            .padding(24)
        }
        .background(Color(red: 0.95, green: 0.92, blue: 0.89))
    }
}

private struct ShopView: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Balance: \(store.state.pointsBalance) points")
                    .font(.title2.weight(.semibold))
                ForEach(store.shopItems) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title).font(.headline)
                                Text(item.detail).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(item.cost) pts").foregroundStyle(.brown).fontWeight(.bold)
                        }
                        Text("Track affinity: \(item.requiredTag.rawValue)")
                            .font(.subheadline)
                        Text(previewText(for: item))
                            .foregroundStyle(.secondary)
                        HStack {
                            if store.state.ownedItemIds.contains(item.id) || (item.type == .background && store.state.backgroundId == item.contentValue) {
                                if isEquipped(item) {
                                    Text("Equipped").foregroundStyle(.green)
                                } else if item.type != .phrasePack {
                                    Button("Equip") { store.equip(item) }
                                } else {
                                    Text("Owned").foregroundStyle(.green)
                                }
                            } else {
                                Button("Buy") { store.purchase(item) }
                                    .disabled(store.state.pointsBalance < item.cost)
                            }
                        }
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 22))
                }
            }
            .padding(24)
        }
        .background(Color(red: 0.94, green: 0.91, blue: 0.88))
    }

    private func isEquipped(_ item: ShopItem) -> Bool {
        switch item.type {
        case .hat: return store.state.equippedHatId == item.id
        case .scarf: return store.state.equippedScarfId == item.id
        case .eyewear: return store.state.equippedEyewearId == item.id
        case .gloves: return store.state.equippedGlovesId == item.id
        case .accessory: return store.state.equippedAccessoryId == item.id
        case .background: return store.state.backgroundId == item.contentValue
        case .effect, .phrasePack: return false
        }
    }

    private func previewText(for item: ShopItem) -> String {
        switch item.type {
        case .background: return "Preview: changes the home scene backdrop."
        case .phrasePack: return "Preview: adds new tap phrases for your companion."
        case .effect: return "Preview: unlocks a new completion burst style."
        default: return "Preview: changes how your avatar looks."
        }
    }
}

private struct AvatarView: View {
    @ObservedObject var store: BobaStore
    @State private var draftName = "Boba"

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    AvatarScene(store: store)
                    TextField("Avatar name", text: $draftName)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 280)
                    Button("Save name") {
                        store.updateAvatar(name: draftName)
                    }
                }
                .onAppear { draftName = store.state.avatarName }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose a companion").font(.title2.weight(.semibold))
                    ForEach(AvatarKind.allCases) { avatar in
                        Button {
                            store.updateAvatar(kind: avatar)
                        } label: {
                            HStack {
                                Circle().fill(avatarColor(avatar)).frame(width: 36, height: 36)
                                Text(avatar.title)
                                Spacer()
                                if store.state.avatarKind == avatar {
                                    Text("Selected").foregroundStyle(.brown)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(12)
                        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            }
            .padding(24)
        }
        .background(Color(red: 0.95, green: 0.92, blue: 0.89))
    }

    private func avatarColor(_ kind: AvatarKind) -> Color {
        switch kind {
        case .penguin: return Color(red: 0.31, green: 0.43, blue: 0.48)
        case .bear: return Color(red: 0.55, green: 0.43, blue: 0.39)
        case .bunny: return Color(red: 0.94, green: 0.85, blue: 0.88)
        }
    }
}

private struct SettingsView: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Toggle("Reward sound", isOn: Binding(
                get: { store.state.soundEnabled },
                set: { _ in store.toggleSound() }
            ))
            .toggleStyle(.switch)

            Text("Local-only storage, a single master task list, gentle streaks, cozy avatar customization, and a small working shop built for expansion.")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
        .background(Color(red: 0.95, green: 0.92, blue: 0.89))
    }
}

private struct QuickTasksPanel: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick task list")
                .font(.title3.weight(.semibold))
            ForEach(Array(store.state.tasks.prefix(5))) { task in
                HStack {
                    VStack(alignment: .leading) {
                        Text(task.title)
                        Text("\(task.points) pts").foregroundStyle(.brown)
                    }
                    Spacer()
                    Button {
                        store.complete(task)
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: 420)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct CozyStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value).font(.title3.weight(.bold))
            Text(title).foregroundStyle(.secondary)
        }
        .frame(minWidth: 110)
    }
}

private struct TagChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? Color.brown.opacity(0.18) : Color.white.opacity(0.7), in: Capsule())
        }
        .buttonStyle(.plain)
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
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(data) { item in
                content(item)
            }
        }
    }
}

private struct AvatarScene: View {
    @ObservedObject var store: BobaStore

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 240, height: 240)

            RoundedRectangle(cornerRadius: 86)
                .fill(bodyColor)
                .frame(width: 160, height: 194)
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 54)
                        .fill(bellyColor)
                        .frame(width: 92, height: 110)
                        .padding(.bottom, 18)
                }

            Circle()
                .fill(bodyColor)
                .frame(width: 140, height: 140)
                .offset(y: -58)

            if store.state.avatarKind != .penguin {
                HStack(spacing: 48) {
                    Circle().fill(bodyColor).frame(width: 28, height: 28)
                    Circle().fill(bodyColor).frame(width: 28, height: 28)
                }
                .offset(y: -112)
            }

            HStack(spacing: 30) {
                Circle().fill(Color(red: 0.14, green: 0.19, blue: 0.22)).frame(width: 12, height: 12)
                Circle().fill(Color(red: 0.14, green: 0.19, blue: 0.22)).frame(width: 12, height: 12)
            }
            .offset(y: -64)

            Circle()
                .fill(store.state.avatarKind == .penguin ? Color(red: 0.95, green: 0.65, blue: 0.47) : Color(red: 0.32, green: 0.21, blue: 0.17))
                .frame(width: store.state.avatarKind == .penguin ? 16 : 14, height: store.state.avatarKind == .penguin ? 16 : 14)
                .offset(y: -36)

            if store.state.equippedHatId != nil {
                RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.48, green: 0.29, blue: 0.23)).frame(width: 104, height: 34).offset(y: -102)
                RoundedRectangle(cornerRadius: 22).fill(Color(red: 0.60, green: 0.40, blue: 0.32)).frame(width: 76, height: 40).offset(y: -126)
            }

            if store.state.equippedScarfId != nil {
                RoundedRectangle(cornerRadius: 18).fill(Color(red: 0.82, green: 0.71, blue: 0.55)).frame(width: 120, height: 28).offset(y: 14)
                RoundedRectangle(cornerRadius: 18).fill(Color(red: 0.70, green: 0.52, blue: 0.36)).frame(width: 24, height: 60).rotationEffect(.degrees(12)).offset(x: 26, y: 42)
            }

            if store.state.equippedEyewearId != nil {
                HStack(spacing: 10) {
                    Circle().stroke(Color(red: 0.27, green: 0.21, blue: 0.18), lineWidth: 3).frame(width: 24, height: 24)
                    Rectangle().fill(Color(red: 0.27, green: 0.21, blue: 0.18)).frame(width: 16, height: 3)
                    Circle().stroke(Color(red: 0.27, green: 0.21, blue: 0.18), lineWidth: 3).frame(width: 24, height: 24)
                }
                .offset(y: -62)
            }

            if store.state.equippedGlovesId != nil {
                HStack(spacing: 120) {
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.90, green: 0.82, blue: 0.81)).frame(width: 18, height: 26)
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.90, green: 0.82, blue: 0.81)).frame(width: 18, height: 26)
                }
                .offset(y: 42)
            }

            if store.state.equippedAccessoryId != nil {
                Circle().fill(Color(red: 0.88, green: 0.71, blue: 0.27)).frame(width: 18, height: 18).offset(x: 40, y: 2)
            }
        }
        .frame(width: 260, height: 260)
    }

    private var bodyColor: Color {
        switch store.state.avatarKind {
        case .penguin: return Color(red: 0.31, green: 0.43, blue: 0.48)
        case .bear: return Color(red: 0.55, green: 0.43, blue: 0.39)
        case .bunny: return Color(red: 0.94, green: 0.85, blue: 0.88)
        }
    }

    private var bellyColor: Color {
        switch store.state.avatarKind {
        case .penguin: return Color(red: 0.96, green: 0.97, blue: 0.98)
        case .bear: return Color(red: 0.92, green: 0.84, blue: 0.78)
        case .bunny: return Color(red: 0.99, green: 0.97, blue: 0.98)
        }
    }
}
