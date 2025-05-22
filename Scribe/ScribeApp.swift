import SwiftUI

@main
struct ScribeApp: App {
    @StateObject private var loader = MarkdownLoader()
    private let bookmarkManager = FolderBookmarkManager()

    var body: some Scene {
        WindowGroup {
            ContentView(loader: loader, bookmarkManager: bookmarkManager)
                .containerBackground(.ultraThinMaterial, for: .window)
        }
        .windowStyle(.hiddenTitleBar)
        /* .commands {
            CommandMenu("File") {
                Button("Choose Markdown Folder...") {
                    openFolderPicker()
                }
                .keyboardShortcut("O", modifiers: [.command])
            }
        } */
        .commands {
            CommandGroup(after: .newItem) {
                Button("Choose Markdown Folder") {
                    openFolderPicker()
                }
                .keyboardShortcut("O", modifiers: [.command])
            }
        }
    }

    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        if panel.runModal() == .OK, let url = panel.url {
            bookmarkManager.saveBookmark(for: url)
            loader.loadFromFolder(url)
        }
    }
}
