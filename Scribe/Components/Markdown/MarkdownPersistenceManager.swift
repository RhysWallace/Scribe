import Foundation

class MarkdownPersistenceManager: ObservableObject {
    @Published var content: String = "" {
        didSet {
            // Cancel any existing save timer
            saveTimer?.invalidate()
            
            // Start a new timer for 0.5 seconds
            saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.save()
            }
        }
    }
    
    private let folderURL: URL
    private let todayFilename: String
    private let fileURL: URL
    private var saveTimer: Timer?
    
    init(folderURL: URL) {
        self.folderURL = folderURL
        self.todayFilename = Self.filename(for: Date())
        self.fileURL = folderURL.appendingPathComponent(todayFilename)
        loadOrCreateTodayFile()
        
        print("Loaded file from: \(fileURL.path)")
        print("Content loaded: \(self.content)")
    }
    
    deinit {
        // Clean up timer when object is deallocated
        saveTimer?.invalidate()
        // Save any pending changes immediately
        save()
    }
    
    static func filename(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "note-\(formatter.string(from: date)).md"
    }
    
    private func loadOrCreateTodayFile() {
        // Start accessing the security-scoped resource
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let fm = FileManager.default
        if !fm.fileExists(atPath: fileURL.path) {
            do {
                // Ensure the directory exists
                if !fm.fileExists(atPath: folderURL.path) {
                    try fm.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                }
                try "".write(to: fileURL, atomically: true, encoding: .utf8)
                print("📄 Created new file: \(todayFilename)")
            } catch {
                print("❌ Failed to create file: \(error.localizedDescription)")
            }
        }
        
        do {
            content = try String(contentsOf: fileURL, encoding: .utf8)
            print("✅ File contents loaded successfully. Length: \(content.count) characters.")
        } catch {
            print("❌ Failed to read file content: \(error.localizedDescription)")
            content = ""
        }
    }
    
    private func save() {
        // Start accessing the security-scoped resource
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            // Ensure the directory exists
            let fm = FileManager.default
            if !fm.fileExists(atPath: folderURL.path) {
                try fm.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("💾 Auto-saved to: \(fileURL.lastPathComponent)")
        } catch {
            print("❌ Failed to save file: \(error.localizedDescription)")
            print("File path: \(fileURL.path)")
            print("Folder exists: \(FileManager.default.fileExists(atPath: folderURL.path))")
        }
    }
    
    // Public method for manual save (if needed)
    func saveNow() {
        saveTimer?.invalidate()
        save()
    }
}
