import SwiftUI

struct SidebarView: View {
    let startDate: Date
    let numberOfDays: Int
    
    @State private var selectedDate: Date? = nil
    private let today = Calendar.current.startOfDay(for: Date())
    
    // Store all dats in advance to be able to reference them with IDs
    private var allDates: [Date] {
        (0..<numberOfDays).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: startDate)
        }.map {
            Calendar.current.startOfDay(for: $0)
        }
    }
    
    private var groupedDatesByMonth: [(key: DateComponents, value: [Date])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: allDates) { date in
            calendar.dateComponents([.year, .month], from: date)
        }
        
        return groups.sorted {
            guard let d1 = calendar.date(from: $0.key),
                  let d2 = calendar.date(from: $1.key) else { return false }
            return d1 < d2
        }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(groupedDatesByMonth.reversed(), id: \.key) { (month, dates) in
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(dates.reversed(), id: \.self) { date in
                                let isToday = Calendar.current.isDate(date, inSameDayAs: today)
                                let isSelected = selectedDate.map { Calendar.current.isDate(date, inSameDayAs: $0) } ?? false
                                
                                DateRowView(
                                    date: date,
                                    isToday: isToday,
                                    isSelected: isSelected
                                ) {
                                    withAnimation {
                                        selectedDate = date
                                        proxy.scrollTo(date, anchor: .center)
                                    }
                                }
                                .id(date)
                            }
                        }
                        .padding(.bottom, 24) // 👈 Extra padding between months
                    }
                    
                    Color.clear
                        .frame(height: 20)
                        .id("bottom")
                }
                .onAppear {
                    if let last = allDates.first {
                        DispatchQueue.main.async {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }
            .frame(width: 140)
            .background(VisualEffectBackground())
        }
    }
}
