import Foundation

class MarkdownLoader: ObservableObject {
    @Published var loadedMarkdowns: [String] = []

    private var allFiles: [URL] = []
    private let batchSize = 20
    private var currentIndex = 0

    private var securityScopedAccess = false

    func loadFromFolder(_ folderURL: URL) {
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
        loadedMarkdowns = []
        currentIndex = 0
        loadNextBatch()
    }

    func loadNextBatch() {
        guard currentIndex < allFiles.count else { return }

        let nextBatch = allFiles[currentIndex..<min(currentIndex + batchSize, allFiles.count)]
        for url in nextBatch {
            if let contents = try? String(contentsOf: url, encoding: .utf8) {
                loadedMarkdowns.append(contents)
            }
        }

        currentIndex += batchSize
    }

    var hasMore: Bool {
        currentIndex < allFiles.count
    }
}
