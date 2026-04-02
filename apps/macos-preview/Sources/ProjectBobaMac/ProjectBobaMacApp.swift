import SwiftUI

let rootInputIsolationMode: RootInputIsolationMode = .appKitWindowHostingFullApp

@main
struct ProjectBobaMacApp: App {
    @NSApplicationDelegateAdaptor(PureAppKitInputIsolationAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup("Project Boba Mac Preview") {
            AppRootModeSwitchView(mode: rootInputIsolationMode)
        }
        .windowResizability(.automatic)
    }
}

private struct AppRootModeSwitchView: View {
    let mode: RootInputIsolationMode

    var body: some View {
        switch mode {
        case .pureAppKitControls, .appKitWindowHostingSwiftUI, .appKitWindowHostingFullApp:
            EmptyView()
        case .minimalPureSwiftUIApp:
            SwiftUIInputIsolationView()
        }
    }
}
