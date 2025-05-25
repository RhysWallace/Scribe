import SwiftUI

struct ScrollCoordinator {
    static func scrollTo(date: Date?, using proxy: ScrollViewProxy, loader: MarkdownLoader) {
        guard let date = date else {
            // Scroll to bottom if no date is selected
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo("scrollBottom", anchor: .bottom)
                }
            }
            return
        }

        let targetDateString = format(date: date)
        
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

    private static func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
