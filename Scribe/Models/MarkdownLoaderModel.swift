import Foundation

class MarkdownLoader: ObservableObject {
    @Published var loadedMarkdowns: [Int: String] = [:]

    private var allFiles: [URL] = []
    private let batchSize = 20
    private var currentIndex = 0

    private var securityScopedAccess = false
    private var folderURL: URL?

    func loadFromFolder(_ folderURL: URL) {
        self.folderURL = folderURL

        if folderURL.startAccessingSecurityScopedResource() {
            securityScopedAccess = true
        }

        defer {
            if securityScopedAccess {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }

        let manager = MarkdownFileManager(folderURL: folderURL)
        allFiles = manager.getAllMarkdownFileURLs()
        loadedMarkdowns = [:]
        currentIndex = 0
        loadNextBatch()
    }

    func loadNextBatch() {
        guard currentIndex < allFiles.count else { return }

        let nextBatch = allFiles[currentIndex..<min(currentIndex + batchSize, allFiles.count)]
        for (offset, url) in nextBatch.enumerated() {
            let index = currentIndex + offset
            if let contents = try? String(contentsOf: url, encoding: .utf8) {
                loadedMarkdowns[index] = contents
            }
        }

        currentIndex += batchSize
    }

    func loadMarkdown(at index: Int) {
        guard let folderURL = folderURL,
              index >= 0, index < allFiles.count else { return }

        if loadedMarkdowns[index] != nil { return } // already loaded

        let fileURL = allFiles[index]
        
        if folderURL.startAccessingSecurityScopedResource() {
            defer { folderURL.stopAccessingSecurityScopedResource() }

            if let contents = try? String(contentsOf: fileURL, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.loadedMarkdowns[index] = contents
                }
            }
        }
    }
    
    func unloadMarkdowns(keepingAround index: Int, window: Int = 30) {
        let range = (index - window)...(index + window)
        for key in loadedMarkdowns.keys where !range.contains(key) {
            loadedMarkdowns[key] = nil
        }
    }

    var hasMore: Bool {
        currentIndex < allFiles.count
    }

    var fileCount: Int {
        allFiles.count
    }

    var totalCount: Int {
        allFiles.count
    }
}
