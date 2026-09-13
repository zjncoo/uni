//
//  UniWidgetProvider.swift
//  uniWidget
//
//  Created by Francesco Zanchetta on 12/09/2026.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct UniWidgetTimelineEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

// MARK: - Shared Timeline Provider
struct UniWidgetProvider: TimelineProvider {
    typealias Entry = UniWidgetTimelineEntry

    // Placeholder shown while WidgetKit prepares
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), snapshot: .placeholder)
    }

    // Snapshot for widget gallery preview
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let snap = UserDefaults.widgetShared?.loadWidgetSnapshot() ?? .placeholder
        completion(Entry(date: Date(), snapshot: snap))
    }

    // Actual timeline — refresh every 30 minutes
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let snap = UserDefaults.widgetShared?.loadWidgetSnapshot() ?? .placeholder
        let entry = Entry(date: Date(), snapshot: snap)

        // Schedule next update 30 min from now
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Placeholder snapshot for previews / empty state
extension WidgetSnapshot {
    static let placeholder = WidgetSnapshot(
        deadlines: [
            WidgetDeadlineEntry(id: "1", title: "Relazione Progetto", dueDateISO: isoDate(daysFromNow: 2),
                                priorityRaw: "Alta", courseColorHex: "#FF6B6B", courseName: "Ingegneria del Software"),
            WidgetDeadlineEntry(id: "2", title: "Esercitazione Analisi", dueDateISO: isoDate(daysFromNow: 5),
                                priorityRaw: "Media", courseColorHex: "#4ECDC4", courseName: "Analisi Matematica"),
            WidgetDeadlineEntry(id: "3", title: "Quiz Online", dueDateISO: isoDate(daysFromNow: 8),
                                priorityRaw: "Bassa", courseColorHex: "#45B7D1", courseName: "Fisica Generale"),
        ],
        lessons: [
            WidgetLessonEntry(id: "l1", courseName: "Ingegneria del Software", courseColorHex: "#FF6B6B",
                              dayOfWeek: 1, startTime: "09:00", endTime: "11:00", room: "Aula A1"),
            WidgetLessonEntry(id: "l2", courseName: "Analisi Matematica", courseColorHex: "#4ECDC4",
                              dayOfWeek: 1, startTime: "14:00", endTime: "16:00", room: "Aula B3"),
            WidgetLessonEntry(id: "l3", courseName: "Fisica Generale", courseColorHex: "#45B7D1",
                              dayOfWeek: 2, startTime: "10:00", endTime: "12:00", room: "Lab Scienze"),
        ],
        exams: [
            WidgetExamEntry(id: "e1", title: "Esame Ing. del Software", courseName: "Ingegneria del Software",
                            courseColorHex: "#FF6B6B", examDateISO: isoDate(daysFromNow: 21), typeRaw: "Scritto + Orale"),
        ],
        studentName: "Francesco",
        updatedAt: isoDate(daysFromNow: 0)
    )

    private static func isoDate(daysFromNow days: Int) -> String {
        let d = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return ISO8601DateFormatter().string(from: d)
    }
}
