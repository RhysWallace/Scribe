/* import SwiftUI

struct SidebarView: View {
    let startDate: Date

    @State private var loadedDates: [Date] = []
    @State private var selectedDate: Date?
    private let calendar = Calendar.current
    private let loadBatchSize = 30

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(groupedDatesByMonth.reversed(), id: \.key) { (monthStart, datesInMonth) in
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(datesInMonth.reversed(), id: \.self) { date in
                                let isToday = calendar.isDate(date, inSameDayAs: Date())
                                let isSelected = selectedDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false

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
                                .onAppear {
                                    if date == loadedDates.first {
                                        loadMoreDates()
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
                .padding(.top)
                .onChange(of: loadedDates) { _, newDates in
                    // Scroll to today whenever dates are loaded/updated
                    if !newDates.isEmpty {
                        DispatchQueue.main.async {
                            let today = calendar.startOfDay(for: startDate)
                            proxy.scrollTo(today, anchor: .bottom)
                        }
                    }
                }
            }
            .frame(width: 140)
            .background(VisualEffectBackground())
            .onAppear {
                if loadedDates.isEmpty {
                    loadInitialDates()
                }
            }
        }
    }

    private func loadInitialDates() {
        let today = calendar.startOfDay(for: startDate)
        loadedDates = (0..<loadBatchSize).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    private func loadMoreDates() {
        guard let earliest = loadedDates.last else { return }
        let moreDates = (1...loadBatchSize).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: earliest)
        }
        loadedDates.append(contentsOf: moreDates)
    }

    private var groupedDatesByMonth: [(key: Date, value: [Date])] {
        let grouped = Dictionary(grouping: loadedDates) { date in
            calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        }

        return grouped
            .map { (key: $0.key, value: $0.value.sorted(by: >)) }
            .sorted { $0.key > $1.key }
    }
} */
