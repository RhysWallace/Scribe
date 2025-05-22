import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var loader: MarkdownLoader
    let bookmarkManager: FolderBookmarkManager
    @State private var folderURL: URL?
    
    // Provide default values so ContentView() works without parameters
    init(
        loader: MarkdownLoader = MarkdownLoader(),
        bookmarkManager: FolderBookmarkManager = FolderBookmarkManager()
    ) {
        self.loader = loader
        self.bookmarkManager = bookmarkManager
    }
    
    var body: some View {
        ZStack {
            // Translucent background
            VisualEffectBackground()
            
            VStack {
                HStack(spacing: 0) {
                    //Sidebar on left
                    SidebarView()
                    
                    // Scrollable vertical stack
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 48) {
                            ForEach(Array(0..<loader.totalCount), id: \.self) { index in
                                if let markdown = loader.loadedMarkdowns[index] {
                                    MarkdownRowView(
                                        index: index,
                                        filename: loader.filename(at: index) ?? "",
                                        content: markdown
                                    ) {
                                        loader.loadMarkdown(at: index)
                                        loader.unloadMarkdowns(keepingAround: index, window: 40)
                                        }
                                } else {
                                    ProgressView() // Show placeholder while loading
                                        .onAppear {
                                            loader.loadMarkdown(at: index)
                                        }
                                    }
                            }
                            
                            if loader.hasMore {
                                ProgressView()
                                    .padding(.top, 20)
                            }
                        }
                        .padding(32)
                        .font(.system(size: 16))
                    }
                }
                .background(Color.white.opacity(0.6))
            }
            .onAppear {
                if let restoredURL = bookmarkManager.restoreBookmark() {
                    folderURL = restoredURL
                    loader.loadFromFolder(restoredURL)
                }
            }
        }
    }
}

#Preview {
    ContentView()  // This now works without errors
}

private struct MarkdownRowView: View {
    let index: Int
    let filename: String
    let content: String
    let onAppear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(filename)
                .font(.caption)
                .foregroundColor(.gray)

            Text(content)
                .multilineTextAlignment(.leading)
        }
        .onAppear(perform: onAppear)
    }
}
