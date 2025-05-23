import SwiftUI

struct DateRowView: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(formattedDate(date))
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(backgroundColor)
                .foregroundColor(.contentTertiary)
                .font(.caption)
                .cornerRadius(8)

        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.blue
        } else if isToday {
            return Color.red
        } else {
            return Color.clear
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd MMM yyyy"
        return formatter.string(from: date)
    }
}
