import Foundation

class MarkdownLoader: ObservableObject {
    @Published var loadedMarkdowns: [Int: String] = [:]

    private var allFiles: [URL] = []
    private let batchSize = 30
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
        let today = Calendar.current.startOfDay(for: Date())

        // Sort files by date in filename (ascending: oldest → newest)
        allFiles = manager.getAllMarkdownFileURLs()
            .filter { url in
                if let date = extractDate(from: url) {
                    return !Calendar.current.isDate(date, inSameDayAs: today)
                }
                return true
            }
            .sorted(by: { a, b in
            extractDate(from: a) ?? .distantPast < extractDate(from: b) ?? .distantPast
        })

        loadedMarkdowns = [:]
        currentIndex = 0
        loadNextBatch()
    }

    private func extractDate(from url: URL) -> Date? {
        let filename = url.deletingPathExtension().lastPathComponent
        let pattern = #"note-(\d{4})-(\d{2})-(\d{2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: filename, range: NSRange(filename.startIndex..., in: filename)),
              match.numberOfRanges == 4,
              let year = Int((filename as NSString).substring(with: match.range(at: 1))),
              let month = Int((filename as NSString).substring(with: match.range(at: 2))),
              let day = Int((filename as NSString).substring(with: match.range(at: 3))) else {
            return nil
        }
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
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
    
    // Get filenames
    func filename(at index: Int) -> String? {
        guard index >= 0, index < allFiles.count else { return nil }
        return allFiles[index].lastPathComponent
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
    
    var allFilenames: [String] {
        allFiles.map { $0.lastPathComponent }
    }
}
