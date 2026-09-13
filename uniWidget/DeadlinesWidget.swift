//
//  DeadlinesWidget.swift
//  uniWidget
//
//  Created by Francesco Zanchetta on 12/09/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Deadlines Widget

struct DeadlinesWidget: Widget {
    let kind: String = "DeadlinesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UniWidgetProvider()) { entry in
            DeadlinesWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    DeadlinesBackground()
                }
        }
        .configurationDisplayName("Scadenze uni")
        .description("Mostra le prossime scadenze e consegne.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Root dispatcher
struct DeadlinesWidgetView: View {
    var entry: UniWidgetTimelineEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:  DeadlinesSmallView(entry: entry)
        case .systemMedium: DeadlinesMediumView(entry: entry)
        case .systemLarge:  DeadlinesLargeView(entry: entry)
        default:            DeadlinesSmallView(entry: entry)
        }
    }
}

// MARK: - Background
struct DeadlinesBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.06, blue: 0.10)
            LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.20, blue: 0.30).opacity(0.18),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Small (1 scadenza urgente + countdown)
struct DeadlinesSmallView: View {
    let entry: UniWidgetTimelineEntry

    var body: some View {
        let deadlines = entry.snapshot.deadlines
        let first = deadlines.first

        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 5) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 11, weight: .bold))
                Text("SCADENZE")
                    .font(UniWidgetFont.caption(10))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
            }

            Spacer()

            if let d = first {
                // Course pill
                Text(d.courseName.isEmpty ? "Generale" : d.courseName)
                    .font(UniWidgetFont.caption(9))
                    .foregroundStyle(Color(hex: d.courseColorHex))
                    .lineLimit(1)
                    .truncationMode(.tail)

                // Title
                Text(d.title)
                    .font(UniWidgetFont.headline(13))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Countdown
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(max(0, d.daysRemaining))")
                        .font(UniWidgetFont.largeNumber(30))
                        .foregroundStyle(countdownColor(days: d.daysRemaining))
                    Text("gg")
                        .font(UniWidgetFont.caption(11))
                        .foregroundStyle(.secondary)
                }
            } else {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 28))
                Text("Nessuna scadenza!")
                    .font(UniWidgetFont.body(11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .padding(14)
        .widgetURL(URL(string: "uni://deadlines"))
    }
}

// MARK: - Medium (3 scadenze)
struct DeadlinesMediumView: View {
    let entry: UniWidgetTimelineEntry

    var body: some View {
        let deadlines = Array(entry.snapshot.deadlines.prefix(3))

        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.system(size: 11, weight: .bold))
                Text("PROSSIME SCADENZE")
                    .font(UniWidgetFont.caption(10))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
                Spacer()
                Text(Date(), style: .date)
                    .font(UniWidgetFont.caption(9))
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 10)

            if deadlines.isEmpty {
                emptyState
            } else {
                VStack(spacing: 6) {
                    ForEach(deadlines) { d in
                        DeadlineRowMedium(deadline: d)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .widgetURL(URL(string: "uni://deadlines"))
    }

    var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 22))
                Text("Nessuna scadenza in programma")
                    .font(UniWidgetFont.body(11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

struct DeadlineRowMedium: View {
    let deadline: WidgetDeadlineEntry

    var body: some View {
        HStack(spacing: 10) {
            // Priority dot + color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: deadline.courseColorHex))
                .frame(width: 3)
                .frame(maxHeight: 34)

            VStack(alignment: .leading, spacing: 1) {
                Text(deadline.title)
                    .font(UniWidgetFont.headline(12))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(deadline.courseName.isEmpty ? "Generale" : deadline.courseName)
                    .font(UniWidgetFont.caption(10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(max(0, deadline.daysRemaining))")
                        .font(UniWidgetFont.largeNumber(16))
                        .foregroundStyle(countdownColor(days: deadline.daysRemaining))
                    Text("gg")
                        .font(UniWidgetFont.caption(9))
                        .foregroundStyle(.secondary)
                }
                PriorityBadge(priority: deadline.priority)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Large (5 scadenze + barra)
struct DeadlinesLargeView: View {
    let entry: UniWidgetTimelineEntry

    var body: some View {
        let deadlines = Array(entry.snapshot.deadlines.prefix(5))

        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.system(size: 11, weight: .bold))
                        Text("SCADENZE · uni")
                            .font(UniWidgetFont.caption(10))
                            .foregroundStyle(.secondary)
                            .tracking(1.5)
                    }
                    if !entry.snapshot.studentName.isEmpty {
                        Text("Ciao, \(entry.snapshot.studentName)")
                            .font(UniWidgetFont.headline(14))
                            .foregroundStyle(.white)
                    }
                }
                Spacer()
                // Count badge
                if !deadlines.isEmpty {
                    Text("\(deadlines.count)")
                        .font(UniWidgetFont.largeNumber(20))
                        .foregroundStyle(.red)
                }
            }
            .padding(.bottom, 12)

            if deadlines.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green).font(.system(size: 32))
                        Text("Nessuna scadenza\nin programma")
                            .font(UniWidgetFont.body(12))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                VStack(spacing: 8) {
                    ForEach(deadlines) { d in
                        DeadlineRowLarge(deadline: d)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .widgetURL(URL(string: "uni://deadlines"))
    }
}

struct DeadlineRowLarge: View {
    let deadline: WidgetDeadlineEntry

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: deadline.courseColorHex))
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 1) {
                    Text(deadline.title)
                        .font(UniWidgetFont.headline(12))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(deadline.courseName.isEmpty ? "Generale" : deadline.courseName)
                        .font(UniWidgetFont.caption(10))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(max(0, deadline.daysRemaining))")
                            .font(UniWidgetFont.largeNumber(15))
                            .foregroundStyle(countdownColor(days: deadline.daysRemaining))
                        Text("giorni")
                            .font(UniWidgetFont.caption(9))
                            .foregroundStyle(.secondary)
                    }
                    PriorityBadge(priority: deadline.priority)
                }
            }

            // Urgency progress bar (0–30 giorni)
            let progress = max(0, min(1.0, 1.0 - Double(deadline.daysRemaining) / 30.0))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(countdownColor(days: deadline.daysRemaining).opacity(0.8))
                        .frame(width: geo.size.width * CGFloat(progress), height: 3)
                }
            }
            .frame(height: 3)
        }
    }
}

// MARK: - Shared helpers

func countdownColor(days: Int) -> Color {
    switch days {
    case ...1:  return .red
    case 2...5: return .orange
    default:    return Color(red: 0.45, green: 0.85, blue: 0.6)
    }
}

struct PriorityBadge: View {
    let priority: WidgetPriority
    var body: some View {
        Text(priority.label)
            .font(UniWidgetFont.caption(8))
            .foregroundStyle(priority.color)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(priority.color.opacity(0.15), in: Capsule())
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    DeadlinesWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}

#Preview("Medium", as: .systemMedium) {
    DeadlinesWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}

#Preview("Large", as: .systemLarge) {
    DeadlinesWidget()
} timeline: {
    UniWidgetTimelineEntry(date: .now, snapshot: .placeholder)
}
