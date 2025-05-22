import Foundation

struct MarkdownFileManager {
    let folderURL: URL
    
    func getAllMarkdownFileURLs() -> [URL] {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
        else {
            print("Failed to read folder at \(folderURL.path)")
            return []
        }
        
        let markdownFiles = files
            .filter { $0.pathExtension == "md" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        print("Found markdown files")
        markdownFiles.forEach {
            print("\($0.lastPathComponent)")
        }
        
        return files
            .filter { $0.pathExtension == "md" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
