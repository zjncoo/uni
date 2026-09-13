//
//  UniWidgetModels.swift
//  uniWidget
//
//  Created by Francesco Zanchetta on 12/09/2026.
//

import Foundation
import SwiftUI

// MARK: - App Group ID (must match uni main app)
let uniWidgetAppGroupID = "group.zinco.cc.uni"

// MARK: - Lightweight data models (mirrored from WidgetDataProvider.swift)

struct WidgetDeadlineEntry: Codable, Identifiable {
    var id: String
    var title: String
    var dueDateISO: String
    var priorityRaw: String
    var courseColorHex: String
    var courseName: String

    var dueDate: Date {
        ISO8601DateFormatter().date(from: dueDateISO) ?? Date()
    }

    var priority: WidgetPriority {
        WidgetPriority(rawValue: priorityRaw) ?? .medium
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }
}

struct WidgetLessonEntry: Codable, Identifiable {
    var id: String
    var courseName: String
    var courseColorHex: String
    var dayOfWeek: Int
    var startTime: String
    var endTime: String
    var room: String

    var dayName: String {
        let names = ["", "Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"]
        return names[safe: dayOfWeek] ?? ""
    }
}

struct WidgetExamEntry: Codable, Identifiable {
    var id: String
    var title: String
    var courseName: String
    var courseColorHex: String
    var examDateISO: String
    var typeRaw: String

    var examDate: Date {
        ISO8601DateFormatter().date(from: examDateISO) ?? Date()
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
    }
}

struct WidgetSnapshot: Codable {
    var deadlines: [WidgetDeadlineEntry]
    var lessons: [WidgetLessonEntry]
    var exams: [WidgetExamEntry]
    var studentName: String
    var updatedAt: String
}

enum WidgetPriority: String, Codable {
    case low = "Bassa"
    case medium = "Media"
    case high = "Alta"

    var label: String {
        switch self {
        case .low: return "Bassa"
        case .medium: return "Media"
        case .high: return "Urgente"
        }
    }

    var color: Color {
        switch self {
        case .low: return Color(.systemGray)
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Shared UserDefaults key
extension UserDefaults {
    static var widgetShared: UserDefaults? {
        UserDefaults(suiteName: uniWidgetAppGroupID)
    }

    func loadWidgetSnapshot() -> WidgetSnapshot? {
        guard let data = data(forKey: "uniWidgetSnapshot") else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}

// MARK: - Color from hex
extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8)  & 0xFF) / 255.0
        let b = Double(rgb         & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Safe subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Shared font style (Helvetica Neue / Neue Haas Grotesk)
struct UniWidgetFont {
    /// Title — Helvetica Neue Bold 15
    static func title(_ size: CGFloat = 15) -> Font {
        .custom("HelveticaNeue-Bold", size: size)
    }
    /// Headline — Helvetica Neue Medium 13
    static func headline(_ size: CGFloat = 13) -> Font {
        .custom("HelveticaNeue-Medium", size: size)
    }
    /// Body — Helvetica Neue 12
    static func body(_ size: CGFloat = 12) -> Font {
        .custom("HelveticaNeue", size: size)
    }
    /// Caption — Helvetica Neue Light 10
    static func caption(_ size: CGFloat = 10) -> Font {
        .custom("HelveticaNeue-Light", size: size)
    }
    /// Numeric mono — Helvetica Neue CondensedBold 20
    static func largeNumber(_ size: CGFloat = 22) -> Font {
        .custom("HelveticaNeue-CondensedBold", size: size)
    }
}
