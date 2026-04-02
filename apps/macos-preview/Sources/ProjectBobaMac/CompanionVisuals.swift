import SwiftUI

struct BackgroundScene: View {
    let sceneId: String
    var expanded: Bool = false

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let colors = BackgroundPalette.colors(for: sceneId)

            ZStack {
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                BackgroundSceneContent(sceneId: sceneId, expanded: expanded, time: time)
            }
        }
    }
}

private struct BackgroundSceneContent: View {
    let sceneId: String
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        switch sceneId {
        case "twilight_window":
            AnyView(TwilightWindowScene(expanded: expanded, time: time))
        case "winter_market":
            AnyView(WinterMarketScene(expanded: expanded, time: time))
        case "fireplace_nook":
            AnyView(FireplaceNookScene(expanded: expanded, time: time))
        case "underwater":
            AnyView(UnderwaterScene(expanded: expanded, time: time))
        default:
            AnyView(SnowyNookScene(expanded: expanded, time: time))
        }
    }
}

private struct TwilightWindowScene: View {
    let expanded: Bool
    let time: TimeInterval

    private var windowWidth: CGFloat { expanded ? 430 : 210 }
    private var windowHeight: CGFloat { expanded ? 210 : 110 }
    private var sillHeight: CGFloat { expanded ? 54 : 30 }
    private var yOffset: CGFloat { expanded ? -36 : -16 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.10))
                .frame(width: windowWidth + 30, height: windowHeight + 24)
                .offset(y: yOffset)
            TwilightWindowFrame(width: windowWidth, height: windowHeight, yOffset: yOffset)
            SimpleSnowLayer(time: time, expanded: expanded)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.10))
                .frame(width: windowWidth + 34, height: sillHeight)
                .offset(y: expanded ? 126 : 74)
        }
    }
}

private struct TwilightWindowFrame: View {
    let width: CGFloat
    let height: CGFloat
    let yOffset: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.32), lineWidth: 4)
                .frame(width: width, height: height)
                .offset(y: yOffset)
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.24))
                    .frame(width: 4, height: height)
                    .offset(x: -width * 0.30)
                Spacer(minLength: max(84, width * 0.52))
                Rectangle()
                    .fill(Color.white.opacity(0.24))
                    .frame(width: 4, height: height)
                    .offset(x: width * 0.30)
            }
            .frame(width: width * 0.90)
            .offset(y: yOffset)
            Rectangle()
                .fill(Color.white.opacity(0.24))
                .frame(width: width, height: 4)
                .offset(x: 0, y: yOffset - height * 0.34)
        }
    }
}

private struct SimpleSnowLayer: View {
    let time: TimeInterval
    let expanded: Bool

    var body: some View {
        ForEach(0..<6, id: \.self) { index in
            let size: CGFloat = expanded ? 7 : 4
            Circle()
                .fill(Color.white.opacity(0.72))
                .frame(width: size, height: size)
                .offset(
                    x: CGFloat(-110 + index * 42),
                    y: CGFloat(-30 + sin(time + Double(index)) * 14)
                )
        }
    }
}

private struct WinterMarketScene: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        ZStack {
            HStack(spacing: expanded ? 28 : 14) {
                MiniMarketStall(color: Color(red: 0.73, green: 0.47, blue: 0.29), lanternPhase: time, expanded: expanded)
                MiniMarketStall(color: Color(red: 0.62, green: 0.39, blue: 0.23), lanternPhase: time + 1.3, expanded: expanded)
                if expanded {
                    MiniMarketStall(color: Color(red: 0.82, green: 0.58, blue: 0.34), lanternPhase: time + 2.0, expanded: true)
                }
            }
            .offset(y: expanded ? 54 : 30)
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.12))
                .frame(width: expanded ? 520 : 230, height: expanded ? 64 : 34)
                .offset(y: expanded ? 136 : 82)
        }
    }
}

private struct MiniMarketStall: View {
    let color: Color
    let lanternPhase: TimeInterval
    let expanded: Bool

    private var roofWidth: CGFloat { expanded ? 92 : 50 }
    private var bodyWidth: CGFloat { expanded ? 98 : 54 }
    private var bodyHeight: CGFloat { expanded ? 58 : 32 }
    private var lanternSize: CGFloat { expanded ? 12 : 8 }

    var body: some View {
        VStack(spacing: 0) {
            Triangle()
                .fill(color.opacity(0.95))
                .frame(width: roofWidth, height: expanded ? 30 : 16)
            RoundedRectangle(cornerRadius: 14)
                .fill(color)
                .frame(width: bodyWidth, height: bodyHeight)
            Circle()
                .fill(Color(red: 0.95, green: 0.79, blue: 0.45))
                .frame(width: lanternSize, height: lanternSize)
                .offset(y: sin(lanternPhase) * 3)
        }
    }
}

private struct FireplaceNookScene: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(red: 0.38, green: 0.24, blue: 0.20))
                .frame(width: expanded ? 220 : 120, height: expanded ? 164 : 92)
                .offset(x: expanded ? 108 : 52, y: 12)
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.24, green: 0.14, blue: 0.12))
                .frame(width: expanded ? 128 : 72, height: expanded ? 84 : 48)
                .offset(x: expanded ? 108 : 52, y: 18)
            SimpleFireGlow(expanded: expanded, time: time)
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.79, green: 0.60, blue: 0.44))
                .frame(width: expanded ? 116 : 66, height: expanded ? 76 : 44)
                .offset(x: expanded ? -104 : -54, y: expanded ? 52 : 34)
        }
    }
}

private struct SimpleFireGlow: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        Circle()
            .fill(Color(red: 0.96, green: 0.82, blue: 0.52).opacity(0.18 + (sin(time * 1.6) + 1) * 0.05))
            .frame(width: expanded ? 160 : 92, height: expanded ? 160 : 92)
            .offset(x: expanded ? 98 : 48, y: 8)
    }
}

private struct UnderwaterScene: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        ZStack {
            UnderwaterLightRays(expanded: expanded)
            UnderwaterKelp(expanded: expanded, time: time)
            UnderwaterBubbles(expanded: expanded, time: time)
            UnderwaterFish(expanded: expanded, time: time)
        }
    }
}

private struct UnderwaterLightRays: View {
    let expanded: Bool

    var body: some View {
        HStack(spacing: expanded ? 76 : 36) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: expanded ? 30 : 16, height: expanded ? 220 : 108)
                    .rotationEffect(.degrees(Double(index * 8 - 8)))
            }
        }
        .offset(y: expanded ? -10 : -6)
    }
}

private struct UnderwaterKelp: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        HStack(alignment: .bottom) {
            KelpBlade(height: expanded ? 118 : 56, sway: sin(time) * 6)
                .offset(x: expanded ? -72 : -34)
            Spacer(minLength: expanded ? 150 : 78)
            KelpBlade(height: expanded ? 138 : 64, sway: sin(time + 2.1) * 6)
                .offset(x: expanded ? 72 : 34)
        }
        .frame(width: expanded ? 420 : 220)
        .offset(y: expanded ? 88 : 50)
    }
}

private struct KelpBlade: View {
    let height: CGFloat
    let sway: Double

    var body: some View {
        Capsule()
            .fill(Color(red: 0.34, green: 0.58, blue: 0.42).opacity(0.78))
            .frame(width: max(10, height * 0.08), height: height)
            .rotationEffect(.degrees(sway))
    }
}

private struct UnderwaterBubbles: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        ForEach(0..<5, id: \.self) { index in
            let travel = expanded ? 210.0 : 110.0
            let startY = expanded ? 110.0 : 60.0
            let xOffsets: [CGFloat] = expanded ? [-132, -96, 96, 134, 168] : [-78, -52, 52, 82, 102]
            Circle()
                .stroke(Color.white.opacity(0.56), lineWidth: 1)
                .frame(width: expanded ? 14 : 8, height: expanded ? 14 : 8)
                .offset(
                    x: xOffsets[index],
                    y: CGFloat(startY - (time * 26 + Double(index * 22)).truncatingRemainder(dividingBy: travel))
                )
        }
    }
}

private struct UnderwaterFish: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        HStack(spacing: expanded ? 120 : 56) {
            FishSilhouette(scale: expanded ? 1.0 : 0.62)
                .offset(y: sin(time * 1.1) * 10)
            FishSilhouette(scale: expanded ? 0.82 : 0.50)
                .offset(y: sin(time * 1.2 + 1.4) * 8)
        }
        .offset(y: expanded ? 8 : 4)
    }
}

private struct FishSilhouette: View {
    let scale: CGFloat

    var body: some View {
        HStack(spacing: -4 * scale) {
            Circle()
                .fill(Color(red: 0.17, green: 0.30, blue: 0.36).opacity(0.28))
                .frame(width: 30 * scale, height: 18 * scale)
            Triangle()
                .fill(Color(red: 0.17, green: 0.30, blue: 0.36).opacity(0.24))
                .frame(width: 14 * scale, height: 14 * scale)
                .rotationEffect(.degrees(-90))
        }
    }
}

private struct SnowyNookScene: View {
    let expanded: Bool
    let time: TimeInterval

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.14))
                .frame(width: expanded ? 300 : 150, height: expanded ? 170 : 84)
                .offset(y: expanded ? 118 : 70)
            Circle()
                .fill(Color.white.opacity(0.16 + (sin(time * 1.2) + 1) * 0.04))
                .frame(width: expanded ? 110 : 68, height: expanded ? 110 : 68)
                .offset(x: expanded ? -168 : -88, y: expanded ? -100 : -52)
        }
    }
}

struct CompanionBubble: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(BobaTheme.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(BobaTheme.inputBackground, in: RoundedRectangle(cornerRadius: 20))
            Triangle()
                .fill(BobaTheme.inputBackground)
                .frame(width: 18, height: 10)
                .rotationEffect(.degrees(180))
                .offset(x: 24, y: -1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(BobaTheme.border.opacity(0.42), lineWidth: 1)
                .allowsHitTesting(false)
        )
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
        .frame(maxWidth: 280, alignment: .trailing)
    }
}

struct AvatarScene: View {
    @ObservedObject var store: BobaStore
    @State private var bodyLift: CGFloat = 0
    @State private var bodyScale: CGFloat = 1
    @State private var waveBoost: Double = 0
    @State private var blinkScale: CGFloat = 1
    @State private var confettiProgress: CGFloat = 0

    private var kind: AvatarKind { store.state.avatarKind }
    private var palette: AvatarPalette { AvatarPalette.forKind(kind) }
    private var hatStyle: String {
        AppState.shopInventory.first(where: { $0.id == store.state.equippedHatId })?.contentValue ?? "beanie"
    }
    private var eyewearStyle: String {
        AppState.shopInventory.first(where: { $0.id == store.state.equippedEyewearId })?.contentValue ?? "round"
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let idleFloat = CGFloat(sin(time * 1.1) * 3)
            let tailSway = sin(time * 1.2) * 7
            let waveAngle = Angle.degrees(-18 + sin(time * 1.5) * 2 + waveBoost)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 272, height: 272)

                if confettiProgress > 0.001 {
                    SimpleConfetti(progress: confettiProgress)
                }

                SimpleAvatarBody(
                    kind: kind,
                    palette: palette,
                    blinkScale: blinkScale,
                    tailSway: tailSway,
                    hatStyle: hatStyle,
                    eyewearStyle: eyewearStyle,
                    hasHat: store.state.equippedHatId != nil,
                    hasEyewear: store.state.equippedEyewearId != nil,
                    hasScarf: store.state.equippedScarfId != nil,
                    hasAccessory: store.state.equippedAccessoryId != nil
                )
                .offset(y: bodyLift + idleFloat)
                .scaleEffect(bodyScale)

                SimpleAvatarArm(color: palette.fur, angle: .degrees(-10), mirrored: true, hasGloves: store.state.equippedGlovesId != nil)
                    .offset(x: -62, y: 20 + bodyLift + idleFloat)
                    .scaleEffect(bodyScale)

                SimpleAvatarArm(color: palette.fur, angle: waveAngle, mirrored: false, hasGloves: store.state.equippedGlovesId != nil)
                    .offset(x: 62, y: 20 + bodyLift + idleFloat)
                    .scaleEffect(bodyScale)
            }
            .frame(width: 300, height: 300)
            .onReceive(store.$celebrationTrigger) { _ in
                withAnimation(.easeOut(duration: 0.12)) {
                    bodyLift = -24
                    bodyScale = 1.08
                    confettiProgress = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.74)) {
                        bodyLift = 0
                        bodyScale = 1
                    }
                }
                withAnimation(.easeOut(duration: 0.65)) {
                    confettiProgress = 0
                }
            }
            .onReceive(store.$greetingTrigger) { _ in
                withAnimation(.easeOut(duration: 0.16)) {
                    waveBoost = -82
                    blinkScale = 0.15
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                    withAnimation(.easeInOut(duration: 0.12)) {
                        blinkScale = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.76)) {
                        waveBoost = 0
                    }
                }
            }
        }
    }
}

private struct SimpleAvatarBody: View {
    let kind: AvatarKind
    let palette: AvatarPalette
    let blinkScale: CGFloat
    let tailSway: Double
    let hatStyle: String
    let eyewearStyle: String
    let hasHat: Bool
    let hasEyewear: Bool
    let hasScarf: Bool
    let hasAccessory: Bool

    var body: some View {
        ZStack {
            SimpleTail(kind: kind, palette: palette, tailSway: tailSway)
            SimpleBaseCompanion(kind: kind, palette: palette, blinkScale: blinkScale)
            if hasHat {
                SimpleHat(style: hatStyle)
                    .offset(y: -110)
            }
            if hasScarf {
                SimpleScarf()
                    .offset(y: 34)
            }
            if hasAccessory {
                SimpleAccessoryPin()
                    .offset(x: 34, y: 22)
            }
            if hasEyewear {
                SimpleEyewear(style: eyewearStyle)
                    .offset(y: -30)
            }
        }
    }
}

private struct SimpleBaseCompanion: View {
    let kind: AvatarKind
    let palette: AvatarPalette
    let blinkScale: CGFloat

    var body: some View {
        ZStack {
            SimpleEars(kind: kind, palette: palette)

            RoundedRectangle(cornerRadius: 72)
                .fill(palette.fur)
                .frame(width: 168, height: 184)
                .offset(y: 34)

            RoundedRectangle(cornerRadius: 52)
                .fill(palette.belly)
                .frame(width: 108, height: 100)
                .offset(y: 58)

            Circle()
                .fill(palette.fur)
                .frame(width: 150, height: 146)
                .offset(y: -32)

            FaceCheekLayer(color: palette.cheek)
                .offset(y: -2)

            SimpleEyes(blinkScale: blinkScale)
                .offset(y: -46)

            SimpleEyebrows()
                .offset(y: -64)

            HStack(spacing: 62) {
                Circle().fill(palette.blush).frame(width: 12, height: 12)
                Circle().fill(palette.blush).frame(width: 12, height: 12)
            }
            .offset(y: -14)

            SimpleFace(kind: kind)
                .offset(y: -4)

            HStack(spacing: 76) {
                SimplePaw(color: palette.paw)
                SimplePaw(color: palette.paw)
            }
            .offset(y: 102)
        }
    }
}

private struct FaceCheekLayer: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 76, height: 56)
    }
}

private struct SimpleEyes: View {
    let blinkScale: CGFloat

    var body: some View {
        HStack(spacing: 42) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.17, green: 0.14, blue: 0.14))
                .frame(width: 20, height: max(3, 24 * blinkScale))
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.17, green: 0.14, blue: 0.14))
                .frame(width: 20, height: max(3, 24 * blinkScale))
        }
    }
}

private struct SimpleEyebrows: View {
    var body: some View {
        HStack(spacing: 42) {
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

private struct SimpleFace: View {
    let kind: AvatarKind

    var body: some View {
        switch kind {
        case .penguin:
            AnyView(PenguinFace())
        case .cat:
            AnyView(CatFace())
        case .dog:
            AnyView(DogFace())
        case .bear, .bunny:
            AnyView(RoundSnoutFace())
        }
    }
}

private struct PenguinFace: View {
    var body: some View {
        VStack(spacing: 4) {
            Diamond()
                .fill(Color(red: 0.95, green: 0.68, blue: 0.43))
                .frame(width: 22, height: 16)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.17, green: 0.14, blue: 0.14))
                .frame(width: 16, height: 3)
        }
    }
}

private struct CatFace: View {
    var body: some View {
        ZStack {
            Triangle()
                .fill(Color(red: 0.90, green: 0.62, blue: 0.57))
                .frame(width: 14, height: 12)
                .offset(y: -2)
            HStack(spacing: 22) {
                Capsule().fill(Color(red: 0.58, green: 0.44, blue: 0.38)).frame(width: 16, height: 2)
                Capsule().fill(Color(red: 0.58, green: 0.44, blue: 0.38)).frame(width: 16, height: 2)
            }
            .offset(y: 8)
        }
    }
}

private struct DogFace: View {
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.72))
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.23, green: 0.16, blue: 0.14))
                        .frame(width: 12, height: 12)
                        .offset(y: -2)
                )
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.23, green: 0.16, blue: 0.14))
                .frame(width: 14, height: 3)
        }
    }
}

private struct RoundSnoutFace: View {
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color(red: 0.30, green: 0.20, blue: 0.16))
                .frame(width: 12, height: 12)
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.30, green: 0.20, blue: 0.16))
                .frame(width: 14, height: 3)
        }
    }
}

private struct SimpleEars: View {
    let kind: AvatarKind
    let palette: AvatarPalette

    var body: some View {
        switch kind {
        case .bunny:
            AnyView(BunnyEars(palette: palette))
        case .cat:
            AnyView(CatEars(palette: palette))
        case .dog:
            AnyView(DogEars(palette: palette))
        case .bear:
            AnyView(BearEars(palette: palette))
        case .penguin:
            AnyView(EmptyView())
        }
    }
}

private struct BunnyEars: View {
    let palette: AvatarPalette

    var body: some View {
        HStack(spacing: 42) {
            Capsule().fill(palette.fur).frame(width: 26, height: 84)
                .overlay(Capsule().fill(palette.earInner).frame(width: 12, height: 48).offset(y: 6))
            Capsule().fill(palette.fur).frame(width: 26, height: 84)
                .overlay(Capsule().fill(palette.earInner).frame(width: 12, height: 48).offset(y: 6))
        }
        .offset(y: -126)
    }
}

private struct CatEars: View {
    let palette: AvatarPalette

    var body: some View {
        HStack(spacing: 52) {
            Triangle().fill(palette.fur).frame(width: 34, height: 32)
                .overlay(Triangle().fill(palette.earInner).frame(width: 18, height: 16).offset(y: 4))
            Triangle().fill(palette.fur).frame(width: 34, height: 32)
                .overlay(Triangle().fill(palette.earInner).frame(width: 18, height: 16).offset(y: 4))
        }
        .offset(y: -110)
    }
}

private struct DogEars: View {
    let palette: AvatarPalette

    var body: some View {
        HStack(spacing: 70) {
            Capsule().fill(palette.earOuter).frame(width: 28, height: 66).rotationEffect(.degrees(16))
            Capsule().fill(palette.earOuter).frame(width: 28, height: 66).rotationEffect(.degrees(-16))
        }
        .offset(y: -82)
    }
}

private struct BearEars: View {
    let palette: AvatarPalette

    var body: some View {
        HStack(spacing: 58) {
            Circle().fill(palette.fur).frame(width: 32, height: 32)
            Circle().fill(palette.fur).frame(width: 32, height: 32)
        }
        .offset(y: -100)
    }
}

private struct SimpleTail: View {
    let kind: AvatarKind
    let palette: AvatarPalette
    let tailSway: Double

    var body: some View {
        switch kind {
        case .penguin:
            AnyView(EmptyView())
        case .bear:
            AnyView(Circle().fill(palette.fur).frame(width: 30, height: 30).offset(x: 74, y: 84))
        case .bunny:
            AnyView(Circle().fill(palette.tail).frame(width: 32, height: 32).offset(x: 76, y: 88))
        case .cat:
            AnyView(Capsule().fill(palette.fur).frame(width: 24, height: 56).rotationEffect(.degrees(34 + tailSway)).offset(x: 86, y: 78))
        case .dog:
            AnyView(Capsule().fill(palette.fur).frame(width: 26, height: 52).rotationEffect(.degrees(42 + tailSway)).offset(x: 84, y: 76))
        }
    }
}

private struct SimpleAvatarArm: View {
    let color: Color
    let angle: Angle
    let mirrored: Bool
    let hasGloves: Bool

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 18)
                .fill(color)
                .frame(width: 28, height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 10, height: 38)
                        .offset(x: mirrored ? 5 : -5)
                )
            if hasGloves {
                MittenView()
                    .offset(y: -4)
            }
        }
        .rotationEffect(angle, anchor: mirrored ? .topTrailing : .topLeading)
    }
}

struct MittenView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(red: 0.93, green: 0.86, blue: 0.83))
            .frame(width: 20, height: 28)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(Color(red: 0.88, green: 0.78, blue: 0.76))
                    .frame(width: 10, height: 10)
                    .offset(x: -4, y: 2)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    .allowsHitTesting(false)
            )
    }
}

private struct SimplePaw: View {
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(color)
            .frame(width: 38, height: 24)
            .overlay(
                HStack(spacing: 4) {
                    Circle().fill(Color.white.opacity(0.18)).frame(width: 5, height: 5)
                    Circle().fill(Color.white.opacity(0.18)).frame(width: 5, height: 5)
                    Circle().fill(Color.white.opacity(0.18)).frame(width: 5, height: 5)
                }
                .offset(y: 1)
            )
    }
}

private struct SimpleHat: View {
    let style: String

    var body: some View {
        switch style {
        case "mooncap":
            AnyView(
                VStack(spacing: 0) {
                    Circle().fill(Color(red: 0.64, green: 0.47, blue: 0.61)).frame(width: 16, height: 16).offset(y: 2)
                    RoundedRectangle(cornerRadius: 18).fill(Color(red: 0.57, green: 0.38, blue: 0.56)).frame(width: 74, height: 36)
                    RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.44, green: 0.28, blue: 0.42)).frame(width: 92, height: 10)
                }
            )
        case "berry_hood":
            AnyView(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.73, green: 0.34, blue: 0.32))
                    .frame(width: 92, height: 44)
                    .overlay(
                        HStack(spacing: 14) {
                            Circle().fill(Color(red: 0.47, green: 0.66, blue: 0.36)).frame(width: 12, height: 12)
                            Circle().fill(Color(red: 0.47, green: 0.66, blue: 0.36)).frame(width: 12, height: 12)
                        }
                        .offset(y: -14)
                    )
            )
        default:
            AnyView(
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.72, green: 0.44, blue: 0.31)).frame(width: 68, height: 30)
                    RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.56, green: 0.30, blue: 0.20)).frame(width: 90, height: 10)
                }
            )
        }
    }
}

private struct SimpleScarf: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.88, green: 0.77, blue: 0.58))
                .frame(width: 106, height: 22)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.77, green: 0.56, blue: 0.36))
                .frame(width: 18, height: 48)
                .offset(x: 26, y: 24)
        }
    }
}

private struct SimpleAccessoryPin: View {
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

private struct SimpleEyewear: View {
    let style: String

    var body: some View {
        switch style {
        case "heart_specs":
            AnyView(
                HStack(spacing: 8) {
                    HeartFrame().stroke(Color(red: 0.39, green: 0.24, blue: 0.28), lineWidth: 3.2).frame(width: 22, height: 20)
                    Rectangle().fill(Color(red: 0.39, green: 0.24, blue: 0.28)).frame(width: 10, height: 3.2)
                    HeartFrame().stroke(Color(red: 0.39, green: 0.24, blue: 0.28), lineWidth: 3.2).frame(width: 22, height: 20)
                }
            )
        case "sleepy_stars":
            AnyView(
                HStack(spacing: 28) {
                    Image(systemName: "sparkle").foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.35))
                    Image(systemName: "sparkle").foregroundStyle(Color(red: 0.85, green: 0.68, blue: 0.35))
                }
            )
        default:
            AnyView(
                HStack(spacing: 8) {
                    Circle().stroke(Color(red: 0.27, green: 0.21, blue: 0.18), lineWidth: 3.2).frame(width: 24, height: 24)
                    Rectangle().fill(Color(red: 0.27, green: 0.21, blue: 0.18)).frame(width: 12, height: 3.2)
                    Circle().stroke(Color(red: 0.27, green: 0.21, blue: 0.18), lineWidth: 3.2).frame(width: 24, height: 24)
                }
            )
        }
    }
}

private struct SimpleConfetti: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) / 8.0 * .pi * 2
                RoundedRectangle(cornerRadius: 3)
                    .fill(confettiColor(index))
                    .frame(width: 8, height: 6)
                    .offset(
                        x: cos(angle) * Double(progress * 64),
                        y: sin(angle) * Double(progress * 50) - Double(progress * 18)
                    )
                    .opacity(Double(progress))
            }
        }
    }

    private func confettiColor(_ index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.93, green: 0.65, blue: 0.38),
            Color(red: 0.96, green: 0.82, blue: 0.49),
            Color(red: 0.74, green: 0.86, blue: 0.67),
            Color(red: 0.72, green: 0.79, blue: 0.92)
        ]
        return colors[index % colors.count]
    }
}

struct AvatarRig {
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
            leftHand = CGPoint(x: -60, y: 42)
            rightHand = CGPoint(x: 60, y: 42)
            leftShoulder = CGPoint(x: -58, y: 20)
            rightShoulder = CGPoint(x: 58, y: 20)
        case .bear:
            head = CGPoint(x: 0, y: -94)
            face = CGPoint(x: 0, y: -44)
            neck = CGPoint(x: 0, y: 28)
            body = CGPoint(x: 38, y: 18)
            leftHand = CGPoint(x: -62, y: 42)
            rightHand = CGPoint(x: 62, y: 42)
            leftShoulder = CGPoint(x: -60, y: 22)
            rightShoulder = CGPoint(x: 60, y: 22)
        case .bunny:
            head = CGPoint(x: 0, y: -102)
            face = CGPoint(x: 0, y: -44)
            neck = CGPoint(x: 0, y: 28)
            body = CGPoint(x: 38, y: 18)
            leftHand = CGPoint(x: -58, y: 44)
            rightHand = CGPoint(x: 58, y: 44)
            leftShoulder = CGPoint(x: -56, y: 24)
            rightShoulder = CGPoint(x: 56, y: 24)
        case .cat:
            head = CGPoint(x: 0, y: -98)
            face = CGPoint(x: 0, y: -46)
            neck = CGPoint(x: 0, y: 28)
            body = CGPoint(x: 38, y: 18)
            leftHand = CGPoint(x: -60, y: 44)
            rightHand = CGPoint(x: 60, y: 44)
            leftShoulder = CGPoint(x: -58, y: 24)
            rightShoulder = CGPoint(x: 58, y: 24)
        case .dog:
            head = CGPoint(x: 0, y: -96)
            face = CGPoint(x: 0, y: -44)
            neck = CGPoint(x: 0, y: 28)
            body = CGPoint(x: 38, y: 18)
            leftHand = CGPoint(x: -62, y: 44)
            rightHand = CGPoint(x: 62, y: 44)
            leftShoulder = CGPoint(x: -60, y: 24)
            rightShoulder = CGPoint(x: 60, y: 24)
        }
    }
}

struct AvatarPalette {
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
                tail: .clear,
                earInner: .clear,
                earOuter: .clear
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

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
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

struct HeartFrame: Shape {
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
