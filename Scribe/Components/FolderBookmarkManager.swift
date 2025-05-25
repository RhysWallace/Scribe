import Foundation

// Loads the last-selected folder at runtime

class FolderBookmarkManager {
    private let bookmarkKey = "SavedFolderBookmark"

    func saveBookmark(for url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
        } catch {
            print("Failed to create bookmark: \(error)")
        }
    }

    func restoreBookmark() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return nil
        }

        var isStale = false
        do {
            let restoredURL = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            if isStale {
                print("Bookmark is stale. Consider re-saving.")
            }
            
            let started = restoredURL.startAccessingSecurityScopedResource()
            if !started {
                print("❌ Failed to start security scoped access for: \(restoredURL)")
                return nil
            }

            return restoredURL
        } catch {
            print("Failed to resolve bookmark: \(error)")
            return nil
        }
    }
}
