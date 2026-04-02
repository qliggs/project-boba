import SwiftUI

enum RootInputIsolationMode: Equatable {
    case pureAppKitControls
    case appKitWindowHostingSwiftUI
    case appKitWindowHostingFullApp
    case minimalPureSwiftUIApp
}

struct SwiftUIInputIsolationView: View {
    @State private var title = ""
    @State private var note = ""
    @State private var appendCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("SwiftUI Input Isolation")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("This is the smallest SwiftUI typing probe in the target: one TextField, one TextEditor, and live mirrors.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("TextField")
                    .font(.headline)
                TextField("Type here", text: $title)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("TextEditor")
                    .font(.headline)
                TextEditor(text: $note)
                    .font(.system(size: 15))
                    .frame(minHeight: 140)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                    )
            }

            HStack(spacing: 12) {
                Button("Append Sample") {
                    appendCount += 1
                    let sample = "sample\(appendCount)"
                    title += title.isEmpty ? sample : " \(sample)"
                    note += note.isEmpty ? sample : "\n\(sample)"
                }
                Button("Clear") {
                    title = ""
                    note = ""
                    appendCount = 0
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Live title value: \(title.isEmpty ? "(empty)" : title)")
                Text("Live note count: \(note.count)")

                if !title.isEmpty || !note.isEmpty {
                    Text("Typing path works")
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
            }
            .font(.system(size: 13))
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
        .frame(minWidth: 640, minHeight: 480)
    }
}

struct PreviewHostedRootView: View {
    var body: some View {
        ContentView()
    }
}
