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
                    SidebarView(startDate: Date(), numberOfDays: 30)
                    
                    // Scrollable vertical stack
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 48) {
                            ForEach(loader.loadedMarkdowns.indices, id: \.self) { index in
                                Text(loader.loadedMarkdowns[index])
                                    .multilineTextAlignment(.leading)
                                    .onAppear {
                                        if index == loader.loadedMarkdowns.count - 5 {
                                            loader.loadNextBatch()
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
