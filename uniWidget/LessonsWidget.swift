//
//  LessonsWidget.swift
//  uniWidget
//
//  Created by Francesco Zanchetta on 12/09/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Lessons Widget

struct LessonsWidget: Widget {
    let kind: String = "LessonsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UniWidgetProvider()) { entry in
            LessonsWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LessonsBackground()
                }
        }
        .configurationDisplayName("Lezioni uni")
        .description("Mostra le prossime lezioni della settimana.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Root dispatcher
struct LessonsWidgetView: View {
    var entry: UniWidgetTimelineEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  LessonsSmallView(entry: entry)
        case .systemMedium: LessonsMediumView(entry: entry)
        case .systemLarge:  LessonsLargeView(entry: entry)
        default:            LessonsSmallView(entry: entry)
        }
    }
}

// MARK: - Background
struct LessonsBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.10)
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.50, blue: 0.90).opacity(0.18),
                    Color.clear
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
    }
}

// MARK: - Small (prossima lezione)
struct LessonsSmallView: View {
    let entry: UniWidgetTimelineEntry

    var body: some View {
        let lesson = entry.snapshot.lessons.first

        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "graduationcap.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: 11, weight: .bold))
                Text("LEZIONI")
                    .font(UniWidgetFont.caption(10))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
            }

            Spacer()

            if let l = lesson {
                Text(l.dayName)
                    .font(UniWidgetFont.caption(10))
                    .foregroundStyle(Color(hex: l.courseColorHex))

                Text(l.courseName)
                    .font(UniWidgetFont.headline(13))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    Text("\(l.startTime) – \(l.endTime)")
                        .font(UniWidgetFont.body(11))
                        .foregroundStyle(.white.opacity(0.8))
                }

                if !l.room.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text(l.room)
                            .font(UniWidgetFont.caption(10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            } else {
                Spacer()
                Image(systemName: "moon.zzz.fill")
                    .foregroundStyle(.blue.opacity(0.6))
                    .font(.system(size: 24))
                Text("Nessuna lezione")
                    .font(UniWidgetFont.body(11))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(14)
        .widgetURL(URL(string: "uni://calendar"))
    }
}

// MARK: - Medium (oggi + domani)
struct LessonsMediumView: View {
    let entry: UniWidgetTimelineEntry

    private var todayDow: Int {
        let w = Calendar.current.component(.weekday, from: Date())
        return w == 1 ? 7 : w - 1
    }
    private var tomorrowDow: Int {
        return todayDow % 7 + 1
    }

    var body: some View {
        let lessons = entry.snapshot.lessons
        let todayLessons = lessons.filter { $0.dayOfWeek == todayDow }
        let tomorrowLessons = lessons.filter { $0.dayOfWeek == tomorrowDow }

        HStack(spacing: 12) {
            // Today column
            LessonsDayColumn(
                dayLabel: "OGGI",
                lessons: todayLessons,
                accentColor: .blue
            )

            Divider()
                .background(Color.white.opacity(0.12))

            // Tomorrow column
            LessonsDayColumn(
                dayLabel: "DOMANI",
                lessons: tomorrowLessons,
                accentColor: Color(red: 0.4, green: 0.7, blue: 1.0)
            )
        }
        .padding(14)
        .widgetURL(URL(string: "uni://calendar"))
    }
}

struct LessonsDayColumn: View {
    let dayLabel: String
    let lessons: [WidgetLessonEntry]
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dayLabel)
                .font(UniWidgetFont.caption(9))
                .foregroundStyle(accentColor)
                .tracking(1.5)

            if lessons.isEmpty {
                Spacer()
                Text("Libero")
                    .font(UniWidgetFont.body(11))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ForEach(lessons.prefix(3)) { l in
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: l.courseColorHex))
                            .frame(width: 3, height: 30)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(l.courseName)
                                .font(UniWidgetFont.headline(11))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text("\(l.startTime) – \(l.endTime)")
                                .font(UniWidgetFont.caption(9))
                                .foregroundStyle(.secondary)
                            if !l.room.isEmpty {
                                Text(l.room)
                                    .font(UniWidgetFont.caption(9))
                                    .foregroundStyle(.tertiary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Large (settimana compatta)
struct LessonsLargeView: View {
    let entry: UniWidgetTimelineEntry

    private var todayDow: Int {
        let w = Calendar.current.component(.weekday, from: Date())
        return w == 1 ? 7 : w - 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: 11, weight: .bold))
                Text("ORARIO SETTIMANALE · uni")
                    .font(UniWidgetFont.caption(10))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
                Spacer()
            }
            .padding(.bottom, 10)

            // Days Mon–Fri
            VStack(spacing: 6) {
                ForEach(1...5, id: \.self) { dow in
                    let dayLessons = entry.snapshot.lessons.filter { $0.dayOfWeek == dow }
                    WeekDayRow(dow: dow, lessons: dayLessons, isToday: dow == todayDow)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .widgetURL(URL(string: "uni://calendar"))
    }
}

struct WeekDayRow: View {
    let dow: Int
    let lessons: [WidgetLessonEntry]
    let isToday: Bool

    private let dayNames = ["", "Lun", "Mar", "Mer", "Gio", "Ven"]

    var body: some View {
        HStack(spacing: 8) {
            // Day label
            Text(dayNames[safe: dow] ?? "")
                .font(UniWidgetFont.headline(11))
                .foregroundStyle(isToday ? .white : .secondary)
                .frame(width: 26, alignment: .leading)

            if isToday {
                Circle()
                    .fill(.blue)
                    .frame(width: 5, height: 5)
            }

            if lessons.isEmpty {
                Text("—")
                    .font(UniWidgetFont.body(10))
                    .foregroundStyle(.tertiary)
            } else {
                // Lesson pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(lessons) { l in
                            HStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: l.courseColorHex))
                                    .frame(width: 3, height: 20)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(l.courseName)
                                        .font(UniWidgetFont.headline(10))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                    Text("\(l.startTime)–\(l.endTime)")
                                        .font(UniWidgetFont.caption(9))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, isToday ? 6 : 0)
        .background(isToday ? Color.blue.opacity(0.10) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    LessonsWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    LessonsWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}

#Preview("Large", as: .systemLarge) {
    LessonsWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}
