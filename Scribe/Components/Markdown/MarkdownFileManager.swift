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
        
        return files
            .filter { $0.pathExtension == "md" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
