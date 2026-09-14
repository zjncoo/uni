//
//  CalendarWidget.swift
//  uniWidget
//
//  Created by zinco.cc on 12/09/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Calendar Widget

struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UniWidgetProvider()) { entry in
            CalendarWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    CalendarBackground()
                }
        }
        .configurationDisplayName("Calendario uni")
        .description("Mini calendario con scadenze ed esami.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Root dispatcher
struct CalendarWidgetView: View {
    var entry: UniWidgetTimelineEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  CalendarSmallView(entry: entry)
        case .systemMedium: CalendarMediumView(entry: entry)
        case .systemLarge:  CalendarLargeView(entry: entry)
        default:            CalendarSmallView(entry: entry)
        }
    }
}

// MARK: - Background
struct CalendarBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.10)
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.20, blue: 0.85).opacity(0.20),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Small (giorno corrente + prossimo evento)
struct CalendarSmallView: View {
    let entry: UniWidgetTimelineEntry

    private var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: Date())
    }
    private var monthName: String {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        f.locale = Locale(identifier: "it_IT")
        return f.string(from: Date()).uppercased()
    }
    private var weekdayName: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        f.locale = Locale(identifier: "it_IT")
        return f.string(from: Date()).capitalized
    }

    var body: some View {
        let nextDeadline = entry.snapshot.deadlines.first
        let nextExam = entry.snapshot.exams.first

        VStack(alignment: .leading, spacing: 0) {
            // Big date
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(monthName)
                        .font(UniWidgetFont.caption(10))
                        .foregroundStyle(.purple)
                        .tracking(2)
                    Text(dayNumber)
                        .font(.custom("HelveticaNeue-CondensedBold", size: 48))
                        .foregroundStyle(.white)
                        .lineSpacing(-4)
                }
                Spacer()
                Image(systemName: "calendar")
                    .foregroundStyle(.purple.opacity(0.6))
                    .font(.system(size: 16))
            }

            Text(weekdayName)
                .font(UniWidgetFont.body(11))
                .foregroundStyle(.secondary)

            Spacer()

            // Next event
            if let d = nextDeadline {
                Divider().background(Color.white.opacity(0.1))
                    .padding(.vertical, 6)
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: d.courseColorHex))
                        .frame(width: 6, height: 6)
                    Text(d.title)
                        .font(UniWidgetFont.headline(11))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Text("fra \(max(0, d.daysRemaining)) giorni")
                    .font(UniWidgetFont.caption(9))
                    .foregroundStyle(.secondary)
            } else if let e = nextExam {
                Divider().background(Color.white.opacity(0.1))
                    .padding(.vertical, 6)
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: e.courseColorHex))
                        .frame(width: 6, height: 6)
                    Text(e.title)
                        .font(UniWidgetFont.headline(11))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Text("fra \(max(0, e.daysRemaining)) giorni")
                    .font(UniWidgetFont.caption(9))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .widgetURL(URL(string: "uni://calendar"))
    }
}

// MARK: - Medium (settimana con dot indicators)
struct CalendarMediumView: View {
    let entry: UniWidgetTimelineEntry

    private var currentWeekDays: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today) // 1=Sun
        let mondayOffset = weekday == 1 ? -6 : -(weekday - 2)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: mondayOffset + $0, to: today) }
    }

    private func eventCount(for date: Date) -> Int {
        let cal = Calendar.current
        let deadlines = entry.snapshot.deadlines.filter {
            cal.isDate($0.dueDate, inSameDayAs: date)
        }.count
        let exams = entry.snapshot.exams.filter {
            cal.isDate($0.examDate, inSameDayAs: date)
        }.count
        return deadlines + exams
    }

    private func lessonCount(for date: Date) -> Int {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) // 1=Sun
        let dow = weekday == 1 ? 7 : weekday - 1
        return entry.snapshot.lessons.filter { $0.dayOfWeek == dow }.count
    }

    var body: some View {
        let days = currentWeekDays
        let today = Calendar.current.startOfDay(for: Date())

        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.purple)
                    .font(.system(size: 11, weight: .bold))
                Text(monthYearLabel)
                    .font(UniWidgetFont.caption(10))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
                Spacer()
            }

            // Week row
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { date in
                    let isToday = Calendar.current.isDate(date, inSameDayAs: today)
                    let events = eventCount(for: date)
                    let lessons = lessonCount(for: date)

                    VStack(spacing: 4) {
                        Text(shortDayName(for: date))
                            .font(UniWidgetFont.caption(9))
                            .foregroundStyle(isToday ? .purple : .secondary)
                            .tracking(0.5)

                        ZStack {
                            Circle()
                                .fill(isToday ? Color.purple : Color.clear)
                                .frame(width: 28, height: 28)
                            Text(dayNumber(for: date))
                                .font(UniWidgetFont.headline(13))
                                .foregroundStyle(isToday ? .white : .primary)
                        }

                        // Dot indicators
                        HStack(spacing: 2) {
                            if lessons > 0 {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 4, height: 4)
                            }
                            if events > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(height: 5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Divider().background(Color.white.opacity(0.10))

            // Today's events list
            let todayDeadlines = entry.snapshot.deadlines.filter {
                Calendar.current.isDateInToday($0.dueDate)
            }
            let todayExams = entry.snapshot.exams.filter {
                Calendar.current.isDateInToday($0.examDate)
            }

            if todayDeadlines.isEmpty && todayExams.isEmpty {
                HStack {
                    Text("Nessun evento oggi")
                        .font(UniWidgetFont.body(11))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                ForEach(todayDeadlines.prefix(2)) { d in
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.system(size: 10))
                        Text(d.title)
                            .font(UniWidgetFont.headline(11))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer()
                        Text("Scadenza")
                            .font(UniWidgetFont.caption(9))
                            .foregroundStyle(.secondary)
                    }
                }
                ForEach(todayExams.prefix(1)) { e in
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.orange)
                            .font(.system(size: 10))
                        Text(e.title)
                            .font(UniWidgetFont.headline(11))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer()
                        Text("Esame")
                            .font(UniWidgetFont.caption(9))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(14)
        .widgetURL(URL(string: "uni://calendar"))
    }

    private var monthYearLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale(identifier: "it_IT")
        return f.string(from: Date()).uppercased()
    }

    private func shortDayName(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        f.locale = Locale(identifier: "it_IT")
        return f.string(from: date).prefix(2).uppercased()
    }

    private func dayNumber(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
}

// MARK: - Large (mini calendario mensile + eventi)
struct CalendarLargeView: View {
    let entry: UniWidgetTimelineEntry

    private var cal: Calendar { Calendar.current }
    private var today: Date { cal.startOfDay(for: Date()) }

    // All days in the current month + padding
    private var monthDays: [Date?] {
        let comps = cal.dateComponents([.year, .month], from: today)
        guard let firstOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        var weekday = cal.component(.weekday, from: firstOfMonth)
        weekday = weekday == 1 ? 7 : weekday - 1 // 1=Mon

        var days: [Date?] = Array(repeating: nil, count: weekday - 1)
        for day in range {
            if let d = cal.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(d)
            }
        }
        // Pad to complete last row
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private func eventColors(for date: Date) -> [Color] {
        var colors: [Color] = []
        for d in entry.snapshot.deadlines where cal.isDate(d.dueDate, inSameDayAs: date) {
            colors.append(Color(hex: d.courseColorHex))
        }
        for e in entry.snapshot.exams where cal.isDate(e.examDate, inSameDayAs: date) {
            colors.append(Color(hex: e.courseColorHex))
        }
        for l in entry.snapshot.lessons {
            let dow = cal.component(.weekday, from: date)
            let normalDow = dow == 1 ? 7 : dow - 1
            if l.dayOfWeek == normalDow { colors.append(Color(hex: l.courseColorHex)) }
        }
        return colors
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .foregroundStyle(.purple)
                            .font(.system(size: 11, weight: .bold))
                        Text("CALENDARIO · uni")
                            .font(UniWidgetFont.caption(10))
                            .foregroundStyle(.secondary)
                            .tracking(1.5)
                    }
                    Text(monthYear)
                        .font(UniWidgetFont.headline(14))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding(.bottom, 10)

            // Day headers
            HStack(spacing: 0) {
                ForEach(["L","M","M","G","V","S","D"], id: \.self) { d in
                    Text(d)
                        .font(UniWidgetFont.caption(9))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            // Calendar grid
            let weeks = monthDays.chunked(into: 7)
            ForEach(weeks.indices, id: \.self) { weekIdx in
                HStack(spacing: 0) {
                    ForEach(weeks[weekIdx].indices, id: \.self) { dayIdx in
                        let date = weeks[weekIdx][dayIdx]
                        CalendarDayCell(
                            date: date,
                            isToday: date.map { cal.isDate($0, inSameDayAs: today) } ?? false,
                            eventColors: date.map { eventColors(for: $0) } ?? []
                        )
                    }
                }
            }

            Divider().background(Color.white.opacity(0.10))
                .padding(.vertical, 8)

            // Upcoming events list
            let upcoming = upcomingItems()
            if upcoming.isEmpty {
                Text("Nessun evento in programma")
                    .font(UniWidgetFont.body(11))
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 5) {
                    ForEach(upcoming.prefix(3), id: \.id) { item in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: item.colorHex))
                                .frame(width: 3, height: 28)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.title)
                                    .font(UniWidgetFont.headline(11))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text(item.subtitle)
                                    .font(UniWidgetFont.caption(9))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(item.dateLabel)
                                .font(UniWidgetFont.body(10))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .widgetURL(URL(string: "uni://calendar"))
    }

    struct UpcomingItem {
        var id: String
        var title: String
        var subtitle: String
        var colorHex: String
        var date: Date
        var dateLabel: String
    }

    private func upcomingItems() -> [UpcomingItem] {
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        df.locale = Locale(identifier: "it_IT")

        var items: [UpcomingItem] = []
        for d in entry.snapshot.deadlines {
            items.append(UpcomingItem(id: d.id, title: d.title,
                subtitle: d.courseName.isEmpty ? "Scadenza" : d.courseName,
                colorHex: d.courseColorHex, date: d.dueDate,
                dateLabel: df.string(from: d.dueDate)))
        }
        for e in entry.snapshot.exams {
            items.append(UpcomingItem(id: e.id, title: e.title,
                subtitle: "Esame · \(e.typeRaw)",
                colorHex: e.courseColorHex, date: e.examDate,
                dateLabel: df.string(from: e.examDate)))
        }
        return items.sorted { $0.date < $1.date }
    }

    private var monthYear: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        f.locale = Locale(identifier: "it_IT")
        return f.string(from: today).capitalized
    }
}

struct CalendarDayCell: View {
    let date: Date?
    let isToday: Bool
    let eventColors: [Color]

    var body: some View {
        VStack(spacing: 2) {
            if let date = date {
                let dayNum = Calendar.current.component(.day, from: date)
                ZStack {
                    Circle()
                        .fill(isToday ? Color.purple : Color.clear)
                        .frame(width: 22, height: 22)
                    Text("\(dayNum)")
                        .font(UniWidgetFont.body(isToday ? 11 : 10))
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundStyle(isToday ? .white : .primary)
                }

                // Event dots
                HStack(spacing: 2) {
                    ForEach(eventColors.prefix(3).indices, id: \.self) { i in
                        Circle()
                            .fill(eventColors[i])
                            .frame(width: 3, height: 3)
                    }
                }
                .frame(height: 4)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 22, height: 22)
                    .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }
}

// MARK: - Array chunked helper
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    CalendarWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    CalendarWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}

#Preview("Large", as: .systemLarge) {
    CalendarWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}
