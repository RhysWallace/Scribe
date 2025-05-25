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
        ZStack(alignment: .leading) {
            VisualEffectBackground()
            HStack {
                Spacer()
                
                VStack {
                    // Scrollable vertical stack
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 48) {
                                MarkdownListView(loader: loader, proxy: proxy)
                                
                                TextEditor(text: $persistenceManager.content)
                                    .frame(minHeight: 500)
                                
                                Color.clear
                                    .frame(height: 1)
                                    .id("scrollBottom")
                            }
                        }
                        .defaultScrollAnchor(.bottom)
                        .scrollIndicators(.hidden)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                proxy.scrollTo("scrollBottom", anchor: .bottom)
                            }
                        }
                        .onChange(of: selectedDate) { _, _ in
                            ScrollCoordinator.scrollTo(date: selectedDate, using: proxy, loader: loader)
                        }
                    }
                }
                .frame(maxWidth: 600)
                Spacer()
            }
            .onAppear {
                if let restoredURL = bookmarkManager.restoreBookmark() {
                    folderURL = restoredURL
                    loader.loadFromFolder(restoredURL)
                }
            }
            
            
            HoverSidebarContainer(selectedDate: $selectedDate) {
                SidebarView(selectedDate: $selectedDate)
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Date Scrolling Logic
    
    private func scrollToSelectedDate(using proxy: ScrollViewProxy) {
        guard let date = selectedDate else {
            // Scroll to bottom if no date is selected
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo("scrollBottom", anchor: .bottom)
                }
            }
            return
        }

        let targetDateString = Self.format(date: date)
        
        // Find the index of the markdown file that matches this date
        for (index, filename) in loader.allFilenames.enumerated() {
            if filename.contains(targetDateString) {
                if loader.loadedMarkdowns[index] == nil {
                    loader.loadMarkdown(at: index)
                }

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
