import AppKit
import SwiftUI

@MainActor
final class PureAppKitInputIsolationAppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate, NSTextViewDelegate {
    private var window: NSWindow?
    private let titleField = NSTextField(string: "")
    private let noteTextView = NSTextView(frame: .zero)
    private let titleMirrorLabel = NSTextField(labelWithString: "Live title value: (empty)")
    private let noteMirrorLabel = NSTextField(labelWithString: "Live note count: 0")
    private let statusLabel = NSTextField(labelWithString: "Type in a field to prove whether native AppKit input works.")
    private var appendCount = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        switch rootInputIsolationMode {
        case .pureAppKitControls:
            showPureAppKitControlsWindow()
        case .appKitWindowHostingSwiftUI:
            showAppKitWindowHostingSwiftUI()
        case .appKitWindowHostingFullApp:
            showAppKitWindowHostingFullApp()
        case .minimalPureSwiftUIApp:
            return
        }
    }

    private func showPureAppKitControlsWindow() {
        NSApp.setActivationPolicy(.regular)

        let headerLabel = makeLabel(
            "Pure AppKit Input Isolation",
            font: .systemFont(ofSize: 28, weight: .bold),
            color: .labelColor
        )
        let helperLabel = makeLabel(
            "This bypasses the SwiftUI app shell. If typing fails here, the problem is app/window level. If typing works here, the bug is higher in the SwiftUI stack.",
            font: .systemFont(ofSize: 13),
            color: .secondaryLabelColor
        )
        helperLabel.lineBreakMode = .byWordWrapping
        helperLabel.maximumNumberOfLines = 0

        let textFieldLabel = makeLabel("NSTextField", font: .systemFont(ofSize: 14, weight: .semibold), color: .labelColor)
        titleField.placeholderString = "Type here"
        titleField.delegate = self
        titleField.isBezeled = true
        titleField.bezelStyle = .roundedBezel
        titleField.translatesAutoresizingMaskIntoConstraints = false

        let textViewLabel = makeLabel("NSTextView", font: .systemFont(ofSize: 14, weight: .semibold), color: .labelColor)
        noteTextView.delegate = self
        noteTextView.isEditable = true
        noteTextView.isSelectable = true
        noteTextView.allowsUndo = true
        noteTextView.isRichText = false
        noteTextView.importsGraphics = false
        noteTextView.font = .systemFont(ofSize: 14)
        noteTextView.backgroundColor = .textBackgroundColor
        noteTextView.textColor = .textColor
        noteTextView.minSize = NSSize(width: 0, height: 160)
        noteTextView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        noteTextView.isVerticallyResizable = true
        noteTextView.isHorizontallyResizable = false
        noteTextView.autoresizingMask = [.width]
        noteTextView.textContainer?.widthTracksTextView = true

        let textViewScrollView = NSScrollView()
        textViewScrollView.translatesAutoresizingMaskIntoConstraints = false
        textViewScrollView.borderType = .bezelBorder
        textViewScrollView.hasVerticalScroller = true
        textViewScrollView.drawsBackground = true
        textViewScrollView.documentView = noteTextView

        let appendButton = NSButton(title: "Append Sample", target: self, action: #selector(appendSample))
        let clearButton = NSButton(title: "Clear", target: self, action: #selector(clearInputs))
        let buttonRow = NSStackView(views: [appendButton, clearButton])
        buttonRow.orientation = .horizontal
        buttonRow.spacing = 12
        buttonRow.alignment = .leading

        titleMirrorLabel.font = .systemFont(ofSize: 12)
        noteMirrorLabel.font = .systemFont(ofSize: 12)
        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusLabel.textColor = .systemGreen

        let stack = NSStackView(views: [
            headerLabel,
            helperLabel,
            textFieldLabel,
            titleField,
            textViewLabel,
            textViewScrollView,
            buttonRow,
            titleMirrorLabel,
            noteMirrorLabel,
            statusLabel
        ])
        stack.orientation = .vertical
        stack.spacing = 14
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24),

            titleField.widthAnchor.constraint(equalTo: stack.widthAnchor),
            textViewScrollView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            textViewScrollView.heightAnchor.constraint(equalToConstant: 180),
        ])

        let window = makeWindow(
            title: "Project Boba Pure AppKit Input Isolation",
            width: 700,
            height: 540,
            contentView: contentView
        )
        self.window = window
        updateMirrors()
        DispatchQueue.main.async {
            window.makeFirstResponder(self.titleField)
        }
    }

    private func showAppKitWindowHostingSwiftUI() {
        NSApp.setActivationPolicy(.regular)

        let hostingView = NSHostingView(rootView: SwiftUIInputIsolationView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        let window = makeWindow(
            title: "Project Boba AppKit Window Hosting SwiftUI",
            width: 760,
            height: 560,
            contentView: containerView
        )
        self.window = window
    }

    private func showAppKitWindowHostingFullApp() {
        NSApp.setActivationPolicy(.regular)

        let hostingView = NSHostingView(rootView: PreviewHostedRootView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        let window = makeWindow(
            title: "Project Boba Mac Preview",
            width: 1280,
            height: 860,
            contentView: containerView
        )
        self.window = window
    }

    private func makeWindow(title: String, width: CGFloat, height: CGFloat, contentView: NSView) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = contentView
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        return window
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func controlTextDidChange(_ obj: Notification) {
        updateMirrors()
    }

    func textDidChange(_ notification: Notification) {
        updateMirrors()
    }

    @objc private func appendSample() {
        appendCount += 1
        let sample = "sample\(appendCount)"
        titleField.stringValue += titleField.stringValue.isEmpty ? sample : " \(sample)"
        if noteTextView.string.isEmpty {
            noteTextView.string = sample
        } else {
            noteTextView.string += "\n\(sample)"
        }
        updateMirrors()
    }

    @objc private func clearInputs() {
        appendCount = 0
        titleField.stringValue = ""
        noteTextView.string = ""
        updateMirrors()
    }

    private func updateMirrors() {
        let titleValue = titleField.stringValue
        let noteValue = noteTextView.string
        titleMirrorLabel.stringValue = "Live title value: \(titleValue.isEmpty ? "(empty)" : titleValue)"
        noteMirrorLabel.stringValue = "Live note count: \(noteValue.count)"
        statusLabel.stringValue = (titleValue.isEmpty && noteValue.isEmpty) ? "Type in a field to prove whether native AppKit input works." : "Typing path works"
    }

    private func makeLabel(_ text: String, font: NSFont, color: NSColor) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = font
        label.textColor = color
        return label
    }
}
