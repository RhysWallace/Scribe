import SwiftUI

struct SidebarView: View {
    @State private var loadedDates: [Date] = []
    @State private var isInitialLoad = true
    @State private var isLoading = false
    @State private var hasScrolledToToday = false
    @Binding var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let batchSize = 90
    
    var body: some View {
        GeometryReader { outerGeo in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedDatesByMonth, id: \.month) { monthGroup in
                            MonthSectionView(
                                monthGroup: monthGroup,
                                selectedDate: $selectedDate,
                                handleOnAppear: handleOnAppear,
                                calendar: calendar,
                                proxy: proxy
                            )
                            .padding(.bottom, 64)
                        }

                        // Dynamic bottom spacer to keep today vertically centered
                        Spacer(minLength: outerGeo.size.height / 2)
                    }
                    .padding(.horizontal, 16)
                }
                .defaultScrollAnchor(.bottom)
                .background(Color(.windowBackgroundColor))
                .scrollIndicators(.hidden)
                .onAppear {
                    if loadedDates.isEmpty {
                        loadInitialDates()
                    }
                }
            }
        }
        .frame(width: 180)
    }
    
    // MARK: - Data Loading
    
    private func loadInitialDates() {
        let today = calendar.startOfDay(for: Date())
        let dates = (0..<batchSize).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: today)
        }
        loadedDates = dates.sorted(by: <) // Store in ascending order (oldest first)
    }
    
    private func loadMoreDates() {
        guard let oldestDate = loadedDates.first else { return }
        
        let olderDates = (1...batchSize).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: oldestDate)
        }
        
        // Add older dates to the beginning
        loadedDates = (olderDates.sorted(by: <) + loadedDates)
    }
    
    // MARK: - Scroll Management
    
    private func checkForLoadMore(date: Date) {
        // Load more when we're near the oldest date (top of list)
        if date == loadedDates.first {
            loadMoreDates()
        }
    }
    
    // MARK: - Data Grouping
    
    private var groupedDatesByMonth: [MonthGroup] {
        let grouped = Dictionary(grouping: loadedDates) { date in
            calendar.dateComponents([.year, .month], from: date)
        }
        
        return grouped.compactMap { (components, dates) -> MonthGroup? in
            guard let monthStart = calendar.date(from: components) else { return nil }
            return MonthGroup(
                month: monthStart,
                dates: dates.sorted(by: <)
            )
        }
        .sorted { $0.month < $1.month } // Newest months first (top to bottom)
    }
    
    // MARK: - Handle onAppear

    private func handleOnAppear(for date: Date, using proxy: ScrollViewProxy) {
        if isInitialLoad {
            isInitialLoad = false
            let today = calendar.startOfDay(for: Date())
            DispatchQueue.main.async {
                proxy.scrollTo(today, anchor: .center)
            }
        }

        guard date == loadedDates.first, !isLoading else { return }
        isLoading = true
        let preservedDate = date

        DispatchQueue.global(qos: .userInitiated).async {
            let olderDates = (1...batchSize).compactMap {
                calendar.date(byAdding: .day, value: -$0, to: preservedDate)
            }.sorted(by: <)

            DispatchQueue.main.async {
                loadedDates.insert(contentsOf: olderDates, at: 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    proxy.scrollTo(preservedDate, anchor: .top)
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Supporting Types

private struct MonthGroup {
    let month: Date
    let dates: [Date]
}

private struct MonthSectionView: View {
    let monthGroup: MonthGroup
    @Binding var selectedDate: Date?
    let handleOnAppear: (Date, ScrollViewProxy) -> Void
    let calendar: Calendar
    let proxy: ScrollViewProxy

    var body: some View {
        VStack(spacing: 12) {
            ForEach(monthGroup.dates, id: \.self) { date in
                DateRowView(
                    date: date,
                    isToday: calendar.isDate(date, inSameDayAs: Date()),
                    isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                    onTap: {
                        if calendar.isDate(date, inSameDayAs: Date()) {
                            selectedDate = nil
                        } else {
                            selectedDate = date
                        }
                    }
                )
                .id(date)
                .onAppear {
                    handleOnAppear(date, proxy)
                }
            }
        }
    }
}


#Preview {
    ContentView()  // This now works without errors
}
