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
                .foregroundStyle(Color.contentPrimaryA)
                .font(.body1)
        }
        .onAppear(perform: onAppear)
    }
}
