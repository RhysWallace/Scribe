import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var loader: MarkdownLoader
    let bookmarkManager: FolderBookmarkManager
    @State private var folderURL: URL?
    @State private var selectedDate: Date? = nil
    @StateObject private var persistenceManager: MarkdownPersistenceManager
    
    // Provide default values so ContentView() works without parameters
    init(
        loader: MarkdownLoader = MarkdownLoader(),
        bookmarkManager: FolderBookmarkManager = FolderBookmarkManager()
    ) {
        self.loader = loader
        self.bookmarkManager = bookmarkManager
        
        if let restoredURL = bookmarkManager.restoreBookmark() {
            _persistenceManager = StateObject(wrappedValue: MarkdownPersistenceManager(folderURL: restoredURL))
        } else {
            // fallback dummy path to avoid crash during preview or testing
            _persistenceManager = StateObject(wrappedValue: MarkdownPersistenceManager(folderURL: FileManager.default.temporaryDirectory))
        }
    }
    
    var body: some View {
        ZStack {
            // Translucent background
            VisualEffectBackground()
            
            VStack {
                HStack(spacing: 0) {
                    //Sidebar on left
                    SidebarView(selectedDate: $selectedDate)
                    
                    // Scrollable vertical stack
                    ScrollViewReader { proxy in
                        ScrollView {
                            MarkdownListView(loader: loader, proxy: proxy)
                                .font(.body1)

                            TextEditor(text: $persistenceManager.content)
                                .frame(minHeight: 300)
                        }
                        .padding(32)
                        .defaultScrollAnchor(.bottom)
                        .scrollIndicators(.hidden)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                proxy.scrollTo(loader.totalCount - 1, anchor: .bottom)
                            }
                        }
                        .onChange(of: selectedDate) { _, newDate in
                            if let date = newDate {
                                scrollToDate(date, using: proxy)
                            }
                        }
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
    
    // MARK: - Date Scrolling Logic
    
    private func scrollToDate(_ date: Date, using proxy: ScrollViewProxy) {
        let targetDateString = Self.format(date: date)
        
        // Find the index of the markdown file that matches this date
        for (index, filename) in loader.allFilenames.enumerated() {
            if filename.contains(targetDateString) {
                // Load the markdown if it's not already loaded
                if loader.loadedMarkdowns[index] == nil {
                    loader.loadMarkdown(at: index)
                }
                
                // Scroll to the found index
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(index, anchor: .top)
                    }
                }
                break
            }
        }
    }
    
    static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    
}

#Preview {
    ContentView()  // This now works without errors
}
