import SwiftUI

struct MarkdownRowView: View {
    let index: Int
    let filename: String
    let content: String
    let onAppear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(filename)
                .font(.caption)
                .foregroundColor(.contentTertiary)

            Text(content)
                .multilineTextAlignment(.leading)
        }
        .onAppear(perform: onAppear)
    }
}
