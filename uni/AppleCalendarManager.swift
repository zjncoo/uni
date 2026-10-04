//
//  AppleCalendarManager.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import Foundation
import SwiftUI
import EventKit
import Combine

// MARK: - Apple Calendar Manager (EventKit)
@MainActor
public class AppleCalendarManager: ObservableObject {
    public static let shared = AppleCalendarManager()
    
    private var store = EKEventStore()
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published public var syncEnabled: Bool {
        didSet { UserDefaults.standard.set(syncEnabled, forKey: "appleCalendarSyncEnabled") }
    }
    
    public var hasFullAccess: Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(macOS 14.0, *) {
            return status == .fullAccess
        } else {
            return status == .authorized
        }
    }
    
    private var eventMap: [String: String] = [:]
    private let calendarTitle = "uni 📚"
    
    private init() {
        if UserDefaults.standard.object(forKey: "appleCalendarSyncEnabled") == nil {
            self.syncEnabled = true
        } else {
            self.syncEnabled = UserDefaults.standard.bool(forKey: "appleCalendarSyncEnabled")
        }
        self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if let saved = UserDefaults.standard.dictionary(forKey: "appleCalendarEventMap") as? [String: String] {
            self.eventMap = saved
        }
        
        NotificationCenter.default.publisher(for: .EKEventStoreChanged)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.refreshStatus()
                self.store.reset()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Permission
    public func requestAccess() async -> Bool {
        do {
            let granted: Bool
            if #available(macOS 14.0, *) {
                granted = try await store.requestFullAccessToEvents()
            } else {
                granted = try await store.requestAccess(to: .event)
            }
            self.refreshStatus()
            if granted {
                self.store.reset()
                if !self.syncEnabled { self.syncEnabled = true }
            }
            return granted
        } catch {
            print("[AppleCalendarManager] requestAccess error: \(error.localizedDescription)")
            self.refreshStatus()
            return false
        }
    }
    
    public func refreshStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - Dedicated Calendar
    private func uniCalendar() -> EKCalendar? {
        if let existing = store.calendars(for: .event).first(where: { $0.title == calendarTitle }) {
            return existing
        }
        let cal = EKCalendar(for: .event, eventStore: store)
        cal.title = calendarTitle
        if let src = store.sources.first(where: { $0.sourceType == .calDAV && $0.title.lowercased().contains("icloud") })
            ?? store.defaultCalendarForNewEvents?.source
            ?? store.sources.first(where: { $0.sourceType == .calDAV })
            ?? store.sources.first(where: { $0.sourceType == .local })
            ?? store.sources.first {
            cal.source = src
        } else { return nil }
        do { try store.saveCalendar(cal, commit: true); return cal }
        catch { print("[AppleCalendarManager] Calendar creation failed: \(error)"); return nil }
    }
    
    private func saveEventMap() {
        UserDefaults.standard.set(eventMap, forKey: "appleCalendarEventMap")
    }
    
    // MARK: - Sync Deadline
    public func sync(deadline: Deadline, courseName: String?) async {
        guard syncEnabled else { return }
        if !hasFullAccess {
            let granted = await requestAccess()
            guard granted else { return }
        }
        let key = "deadline-\(deadline.id.uuidString)"
        let ev = existingEvent(forKey: key) ?? EKEvent(eventStore: store)
        let prefix = deadline.isCompleted ? "✅ " : "📌 "
        ev.title = "\(prefix)\(deadline.title)"
        var notes: [String] = []
        if let cn = courseName { notes.append("📚 \(cn)") }
        if !deadline.notes.isEmpty { notes.append(deadline.notes) }
        notes.append("Priorità: \(deadline.priority.rawValue)")
        if deadline.isCompleted { notes.append("Stato: Completata") }
        ev.notes = notes.joined(separator: "\n")
        ev.startDate = deadline.dueDate
        ev.endDate = deadline.dueDate.addingTimeInterval(3600)
        ev.isAllDay = false
        ev.alarms = [EKAlarm(relativeOffset: -86400)]
        await saveEvent(ev, key: key)
    }
    
    // MARK: - Sync Exam
    public func sync(exam: Exam, courseName: String?) async {
        guard syncEnabled else { return }
        if !hasFullAccess {
            let granted = await requestAccess()
            guard granted else { return }
        }
        let key = "exam-\(exam.id.uuidString)"
        let ev = existingEvent(forKey: key) ?? EKEvent(eventStore: store)
        let prefix = exam.status == .passed ? "✅ 🎓 " : "🎓 "
        ev.title = "\(prefix)\(exam.title)"
        var notes: [String] = []
        if let cn = courseName { notes.append("📚 \(cn)") }
        if !exam.room.isEmpty { notes.append("📍 \(exam.room)") }
        notes.append("Tipo: \(exam.type.rawValue)")
        if let g = exam.grade { notes.append("Voto: \(g)/30\(exam.honors ? " e Lode" : "")") }
        else if let tg = exam.targetGrade { notes.append("Obiettivo: \(tg)/30") }
        if !exam.notes.isEmpty { notes.append(exam.notes) }
        ev.notes = notes.joined(separator: "\n")
        ev.location = exam.room
        ev.startDate = exam.examDate
        ev.endDate = exam.examDate.addingTimeInterval(7200)
        ev.isAllDay = false
        ev.alarms = [EKAlarm(relativeOffset: -86400), EKAlarm(relativeOffset: -3600)]
        await saveEvent(ev, key: key)
    }
    
    // MARK: - Sync Assignment
    public func sync(assignment: Assignment, courseName: String?) async {
        guard syncEnabled else { return }
        if !hasFullAccess {
            let granted = await requestAccess()
            guard granted else { return }
        }
        let key = "assignment-\(assignment.id.uuidString)"
        let ev = existingEvent(forKey: key) ?? EKEvent(eventStore: store)
        let prefix = assignment.isCompleted ? "✅ 📝 " : "📝 "
        ev.title = "\(prefix)\(assignment.title)"
        var notes: [String] = []
        if let cn = courseName { notes.append("📚 \(cn)") }
        if assignment.weightPercent > 0 { notes.append("Peso: \(assignment.weightPercent)% del voto finale") }
        notes.append("Stato: \(assignment.status.localized(with: LocalizationManager.shared))")
        if !assignment.details.isEmpty { notes.append(assignment.details) }
        ev.notes = notes.joined(separator: "\n")
        ev.startDate = assignment.dueDate
        ev.endDate = assignment.dueDate.addingTimeInterval(3600)
        ev.isAllDay = false
        ev.alarms = [EKAlarm(relativeOffset: -86400)]
        await saveEvent(ev, key: key)
    }
    
    // MARK: - Remove
    public func remove(deadlineId: UUID) async  { await removeEvent(key: "deadline-\(deadlineId.uuidString)") }
    public func remove(examId: UUID) async      { await removeEvent(key: "exam-\(examId.uuidString)") }
    public func remove(assignmentId: UUID) async { await removeEvent(key: "assignment-\(assignmentId.uuidString)") }
    
    // MARK: - Bulk Sync
    public func syncAll(deadlines: [Deadline], exams: [Exam], assignments: [Assignment], courses: [Course]) async {
        guard syncEnabled else { return }
        if !hasFullAccess {
            let granted = await requestAccess()
            guard granted else { return }
        }
        for d in deadlines { await sync(deadline: d, courseName: courses.first(where: { $0.id == d.courseId })?.name) }
        for e in exams     { await sync(exam: e, courseName: courses.first(where: { $0.id == e.courseId })?.name) }
        for a in assignments { await sync(assignment: a, courseName: courses.first(where: { $0.id == a.courseId })?.name) }
    }
    
    // MARK: - Helpers
    private func existingEvent(forKey key: String) -> EKEvent? {
        guard let id = eventMap[key] else { return nil }
        return store.event(withIdentifier: id)
    }
    
    private func saveEvent(_ event: EKEvent, key: String) async {
        guard let cal = uniCalendar() else { return }
        if event.calendar == nil { event.calendar = cal }
        do {
            try store.save(event, span: .thisEvent, commit: true)
            eventMap[key] = event.eventIdentifier
            saveEventMap()
        } catch { print("[AppleCalendarManager] Save error: \(error)") }
    }
    
    private func removeEvent(key: String) async {
        guard let id = eventMap[key], let ev = store.event(withIdentifier: id) else { return }
        do {
            try store.remove(ev, span: .thisEvent, commit: true)
            eventMap.removeValue(forKey: key)
            saveEventMap()
        } catch { print("[AppleCalendarManager] Remove error: \(error)") }
    }
    
    // MARK: - Mac System Calendars Discovery (EventKit Read & Replica)
    public struct MacCalendarInfo: Identifiable, Hashable {
        public var id: String // calendarIdentifier
        public var title: String
        public var sourceTitle: String
        public var colorHex: String
        public var isAcademic: Bool
        public var isSelected: Bool
        
        public init(
            id: String,
            title: String,
            sourceTitle: String,
            colorHex: String,
            isAcademic: Bool,
            isSelected: Bool = true
        ) {
            self.id = id
            self.title = title
            self.sourceTitle = sourceTitle
            self.colorHex = colorHex
            self.isAcademic = isAcademic
            self.isSelected = isSelected
        }
    }
    
    public func getAvailableMacCalendars() -> [MacCalendarInfo] {
        refreshStatus()
        guard hasFullAccess else {
            print("[AppleCalendarManager] getAvailableMacCalendars skipped: not authorized (status: \(authorizationStatus.rawValue))")
            return []
        }
        
        store.reset()
        let allCalendars = store.calendars(for: .event)
        var list: [MacCalendarInfo] = []
        
        for cal in allCalendars {
            // Escludi il calendario dedicato "uni 📚" esportato dall'app per evitare duplicazioni
            if cal.title == calendarTitle { continue }
            
            let hex = hexFromCGColor(cal.cgColor)
            let lower = cal.title.lowercased()
            let isAcademic = lower.contains("uni") ||
                             lower.contains("lezion") ||
                             lower.contains("corso") ||
                             lower.contains("esami") ||
                             lower.contains("studio") ||
                             lower.contains("scuola") ||
                             lower.contains("didattica") ||
                             lower.contains("politecnico")
            
            let info = MacCalendarInfo(
                id: cal.calendarIdentifier,
                title: cal.title,
                sourceTitle: cal.source?.title ?? "Mac",
                colorHex: hex,
                isAcademic: isAcademic,
                isSelected: true
            )
            list.append(info)
        }
        
        return list.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
    
    public func fetchEvents(
        fromCalendarIdentifiers identifiers: [String],
        startDate: Date,
        endDate: Date,
        sourceId: UUID? = nil,
        sourceTitle: String? = nil,
        sourceColorHex: String? = nil,
        isAcademic: Bool = true
    ) async -> [CalendarEventItem] {
        refreshStatus()
        guard hasFullAccess else {
            print("[AppleCalendarManager] fetchEvents skipped: authorizationStatus is \(authorizationStatus.rawValue)")
            return []
        }
        
        store.reset()
        let allCals = store.calendars(for: .event)
        var targetCals = allCals.filter { identifiers.contains($0.calendarIdentifier) }
        
        // Fallback: se l'ID interno CalDAV è cambiato o non corrisponde, cerca per titolo
        if targetCals.isEmpty, let title = sourceTitle {
            targetCals = allCals.filter { $0.title == title || "\($0.title) (\($0.source?.title ?? "Mac"))" == title }
        }
        
        guard !targetCals.isEmpty else {
            print("[AppleCalendarManager] No target calendars found for IDs: \(identifiers)")
            return []
        }
        
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: targetCals)
        let ekEvents = store.events(matching: predicate)
        
        var results: [CalendarEventItem] = []
        for ev in ekEvents {
            let cleanTitle = ev.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !cleanTitle.isEmpty else { continue }
            
            let calColor = sourceColorHex ?? hexFromCGColor(ev.calendar.cgColor)
            let calTitle = sourceTitle ?? ev.calendar.title
            
            let category: CalendarEventItem.EventCategory
            if isAcademic {
                if cleanTitle.localizedCaseInsensitiveContains("esame") || cleanTitle.localizedCaseInsensitiveContains("appello") {
                    category = .exam
                } else {
                    category = .lecture
                }
            } else {
                category = .personal
            }
            
            let item = CalendarEventItem(
                id: "mac-\(ev.calendarItemIdentifier)-\(Int(ev.startDate.timeIntervalSince1970))",
                title: cleanTitle,
                details: ev.notes ?? "",
                location: ev.location ?? "",
                startDate: ev.startDate,
                endDate: ev.endDate,
                isFromCourseFeed: isAcademic,
                category: category,
                courseId: nil,
                sourceId: sourceId,
                calendarTitle: calTitle,
                calendarColorHex: calColor,
                isAcademic: isAcademic
            )
            results.append(item)
        }
        return results
    }
    
    public func hexFromCGColor(_ cgColor: CGColor?) -> String {
        guard let cgColor = cgColor, let components = cgColor.components, components.count >= 3 else {
            return "#4F46E5"
        }
        let r = Int(round(components[0] * 255.0))
        let g = Int(round(components[1] * 255.0))
        let b = Int(round(components[2] * 255.0))
        return String(format: "#%02X%02X%02X", max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)))
    }
}
