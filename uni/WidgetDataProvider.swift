//
//  WidgetDataProvider.swift
//  uni
//
//  Created by zinco.cc on 12/09/2026.
//

import Foundation
import WidgetKit

// MARK: - App Group identifier (shared with uniWidget extension)
public let uniAppGroupID = "group.zinco.cc.uni"

// MARK: - Lightweight models for widget data exchange
// These are also defined in uniWidget/UniWidgetModels.swift — keep in sync.

public struct WidgetDeadlineEntry: Codable {
    public var id: String
    public var title: String
    public var dueDateISO: String  // ISO8601
    public var priorityRaw: String // "low" / "medium" / "high"
    public var courseColorHex: String
    public var courseName: String
}

public struct WidgetLessonEntry: Codable {
    public var id: String
    public var courseName: String
    public var courseColorHex: String
    public var dayOfWeek: Int    // 1=Mon…7=Sun
    public var startTime: String // "09:00"
    public var endTime: String   // "11:00"
    public var room: String
}

public struct WidgetExamEntry: Codable {
    public var id: String
    public var title: String
    public var courseName: String
    public var courseColorHex: String
    public var examDateISO: String
    public var typeRaw: String
}

public struct WidgetSnapshot: Codable {
    public var deadlines: [WidgetDeadlineEntry]
    public var lessons: [WidgetLessonEntry]
    public var exams: [WidgetExamEntry]
    public var studentName: String
    public var updatedAt: String // ISO8601
}

// MARK: - Keys
private enum WidgetDefaultsKey {
    static let snapshot = "uniWidgetSnapshot"
}

// MARK: - Provider
public final class WidgetDataProvider {
    public static let shared = WidgetDataProvider()
    private init() {}

    private let iso = ISO8601DateFormatter()

    /// Call this after every DataManager.saveData() to push fresh data to the widget.
    public func sync(from dataManager: DataManager) {
        let now = Date()
        let isoNow = iso.string(from: now)

        // --- Deadlines: next 5 pending, sorted by dueDate
        let pendingDeadlines = dataManager.deadlines
            .filter { !$0.isCompleted && $0.dueDate >= now }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(5)

        let widgetDeadlines: [WidgetDeadlineEntry] = pendingDeadlines.map { d in
            let course = dataManager.courses.first { $0.id == d.courseId }
            return WidgetDeadlineEntry(
                id: d.id.uuidString,
                title: d.title,
                dueDateISO: iso.string(from: d.dueDate),
                priorityRaw: d.priority.rawValue,
                courseColorHex: course?.colorHex ?? "#636366",
                courseName: course?.name ?? ""
            )
        }

        // --- Lessons: next occurrences this week + next week, sorted chronologically
        let widgetLessons: [WidgetLessonEntry] = upcomingLessons(
            courses: dataManager.courses,
            from: now,
            limit: 5
        )

        // --- Exams: next 5 planned/studying, sorted by date
        let upcomingExams = dataManager.exams
            .filter { ($0.status == .planned || $0.status == .studying) && $0.examDate >= now }
            .sorted { $0.examDate < $1.examDate }
            .prefix(5)

        let widgetExams: [WidgetExamEntry] = upcomingExams.map { e in
            let course = dataManager.courses.first { $0.id == e.courseId }
            return WidgetExamEntry(
                id: e.id.uuidString,
                title: e.title,
                courseName: course?.name ?? "",
                courseColorHex: course?.colorHex ?? "#636366",
                examDateISO: iso.string(from: e.examDate),
                typeRaw: e.type.rawValue
            )
        }

        let snapshot = WidgetSnapshot(
            deadlines: widgetDeadlines,
            lessons: widgetLessons,
            exams: widgetExams,
            studentName: dataManager.studentName,
            updatedAt: isoNow
        )

        guard let defaults = UserDefaults(suiteName: uniAppGroupID) else {
            print("[WidgetDataProvider] App Group non disponibile: \(uniAppGroupID)")
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(snapshot)
            defaults.set(data, forKey: WidgetDefaultsKey.snapshot)
            defaults.synchronize()
            // Ask WidgetKit to refresh all timelines
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("[WidgetDataProvider] Errore serializzazione snapshot: \(error)")
        }
    }

    // MARK: - Helpers

    /// Returns the next `limit` lesson slots starting from `date`, looking forward up to 14 days.
    private func upcomingLessons(courses: [Course], from date: Date, limit: Int) -> [WidgetLessonEntry] {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "it_IT")
        // weekday: 1=Sun,2=Mon,...,7=Sat  → convert to our 1=Mon,...,7=Sun
        let systemWeekday = cal.component(.weekday, from: date) // 1=Sun
        let todayDow = systemWeekday == 1 ? 7 : systemWeekday - 1 // 1=Mon

        var results: [WidgetLessonEntry] = []

        // Look ahead up to 14 days
        for offsetDay in 0..<14 {
            let targetDow = ((todayDow - 1 + offsetDay) % 7) + 1  // 1…7

            for course in courses {
                for sched in course.schedule where sched.dayOfWeek == targetDow {
                    // If today, check that the lesson hasn't already ended
                    if offsetDay == 0 {
                        let nowTime = timeComponents(from: date)
                        let endComps = parseTime(sched.endTime)
                        if nowTime >= endComps { continue }
                    }
                    results.append(WidgetLessonEntry(
                        id: sched.id.uuidString,
                        courseName: course.name,
                        courseColorHex: course.colorHex,
                        dayOfWeek: targetDow,
                        startTime: sched.startTime,
                        endTime: sched.endTime,
                        room: sched.room.isEmpty ? course.room : sched.room
                    ))
                    if results.count >= limit { return results }
                }
            }
        }
        return results
    }

    private func timeComponents(from date: Date) -> (Int, Int) {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0, c.minute ?? 0)
    }

    private func parseTime(_ s: String) -> (Int, Int) {
        let parts = s.split(separator: ":").map { Int($0) ?? 0 }
        return (parts.first ?? 0, parts.dropFirst().first ?? 0)
    }
}
