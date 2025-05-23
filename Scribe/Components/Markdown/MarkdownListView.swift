import SwiftUI

struct MarkdownListView: View {
    @ObservedObject var loader: MarkdownLoader
    let proxy: ScrollViewProxy

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 48) {
            ForEach(Array(0..<loader.totalCount), id: \.self) { index in
                if let markdown = loader.loadedMarkdowns[index] {
                    let filename = loader.allFilenames[index]
                    MarkdownRowView(
                        index: index,
                        filename: filename,
                        content: markdown
                    ) {
                        loader.loadMarkdown(at: index)
                        loader.unloadMarkdowns(keepingAround: index, window: 40)

                        if index == 0 {
                            loader.loadNextBatch()
                        }
                    }
                    .id(index)
                } else {
                    ProgressView()
                        .onAppear {
                            loader.loadMarkdown(at: index)
                        }
                        .id(index)
                }
            }
        }
    }
}
