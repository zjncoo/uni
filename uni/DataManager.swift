//
//  DataManager.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import Foundation
import SwiftUI
import Combine
import WidgetKit
import EventKit
#if canImport(AppKit)
import AppKit
#endif

// MARK: - App Data Container for Persistence
public struct AppDataPayload: nonisolated Codable, Sendable {
    public var courses: [Course]
    public var deadlines: [Deadline]
    public var exams: [Exam]
    public var assignments: [Assignment]
    public var syncedEvents: [CalendarEventItem]
    public var calendarFeedURL: String
    public var lastSyncDate: Date? = nil
    public var studentName: String? = nil
    public var universityName: String? = nil
    public var universityPortalURL: String? = nil
    public var hasCompletedOnboarding: Bool? = nil
    public var quickShortcuts: [QuickShortcutLink]? = nil
    public var navbarQuickActionType: String? = nil
    public var navbarQuickActionCustomId: UUID? = nil
    public var dashboardSectionsOrder: [String]? = nil
    public var navbarShortcutItems: [NavbarShortcutItem]? = nil
    public var calendarSources: [CalendarSource]? = nil
}

// MARK: - University Data Manager
public class DataManager: ObservableObject {
    public static let shared = DataManager()
    
    @Published public var courses: [Course] = []
    @Published public var deadlines: [Deadline] = []
    @Published public var exams: [Exam] = []
    @Published public var assignments: [Assignment] = []
    @Published public var syncedEvents: [CalendarEventItem] = []
    @Published public var calendarSources: [CalendarSource] = []
    @Published public var calendarFeedURL: String = ""
    @Published public var lastSyncDate: Date? = nil
    
    // Profilo Studente & Link Portale Ateneo
    @Published public var studentName: String = ""
    @Published public var universityName: String = ""
    @Published public var universityPortalURL: String = ""
    @Published public var hasCompletedOnboarding: Bool = false
    
    // Scorciatoie Home & Scelta Azione Rapida Barra di Navigazione
    @Published public var quickShortcuts: [QuickShortcutLink] = []
    @Published public var navbarQuickActionType: String = NavbarQuickActionOption.outlook.rawValue
    @Published public var navbarQuickActionCustomId: UUID? = nil
    
    // Scorciatoie barra inferiore (fino a 3)
    @Published public var navbarShortcutItems: [NavbarShortcutItem] = []
    
    public var activeNavbarShortcuts: [NavbarShortcutItem] {
        if !navbarShortcutItems.isEmpty {
            return Array(navbarShortcutItems.prefix(3))
        }
        return [NavbarShortcutItem(actionType: navbarQuickActionType, customShortcutId: navbarQuickActionCustomId)]
    }
    
    // Ordine personalizzato degli elementi della pagina Overview
    @Published public var dashboardSectionsOrder: [String] = []
    
    @Published public var isSyncingCalendar: Bool = false
    @Published public var syncErrorMessage: String? = nil
    @Published public var syncSuccessMessage: String? = nil
    
    // Navigation selection states for cross-view navigation & search
    @Published public var selectedCourseId: UUID? = nil
    @Published public var selectedDeadlineId: UUID? = nil
    @Published public var selectedExamId: UUID? = nil
    @Published public var selectedAssignmentId: UUID? = nil
    
    private let storageFileName = "uni_database.json"
    
    public init() {
        loadData()
    }
    
    // MARK: - File URLs
    private var fileURL: URL {
        let fileManager = FileManager.default
        let appSupportDirs = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let baseDir = appSupportDirs.first ?? fileManager.temporaryDirectory
        let uniFolder = baseDir.appendingPathComponent("uni", isDirectory: true)
        
        if !fileManager.fileExists(atPath: uniFolder.path) {
            try? fileManager.createDirectory(at: uniFolder, withIntermediateDirectories: true)
        }
        
        return uniFolder.appendingPathComponent(storageFileName)
    }
    
    // MARK: - Persistence (Save / Load)
    public func saveData() {
        let payload = AppDataPayload(
            courses: courses,
            deadlines: deadlines,
            exams: exams,
            assignments: assignments,
            syncedEvents: syncedEvents,
            calendarFeedURL: calendarFeedURL,
            lastSyncDate: lastSyncDate,
            studentName: studentName,
            universityName: universityName,
            universityPortalURL: universityPortalURL,
            hasCompletedOnboarding: hasCompletedOnboarding,
            quickShortcuts: quickShortcuts,
            navbarQuickActionType: navbarShortcutItems.first?.actionType ?? navbarQuickActionType,
            navbarQuickActionCustomId: navbarShortcutItems.first?.customShortcutId ?? navbarQuickActionCustomId,
            dashboardSectionsOrder: dashboardSectionsOrder,
            navbarShortcutItems: navbarShortcutItems,
            calendarSources: calendarSources
        )
        
        let targetURL = self.fileURL
        DispatchQueue.global(qos: .utility).async {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(payload)
                try data.write(to: targetURL, options: .atomic)
            } catch {
                print("Errore durante il salvataggio dei dati: \(error.localizedDescription)")
            }
        }
        // Push lightweight snapshot to shared App Group for WidgetKit
        WidgetDataProvider.shared.sync(from: self)
    }
    
    public func loadData() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let payload = try decoder.decode(AppDataPayload.self, from: data)
                
                self.courses = payload.courses
                self.deadlines = payload.deadlines
                self.exams = payload.exams
                self.assignments = payload.assignments
                self.syncedEvents = payload.syncedEvents
                self.calendarFeedURL = payload.calendarFeedURL
                self.lastSyncDate = payload.lastSyncDate
                self.studentName = payload.studentName ?? ""
                self.universityName = payload.universityName ?? ""
                self.universityPortalURL = payload.universityPortalURL ?? ""
                self.hasCompletedOnboarding = payload.hasCompletedOnboarding ?? false
                self.quickShortcuts = payload.quickShortcuts ?? []
                self.navbarQuickActionType = payload.navbarQuickActionType ?? NavbarQuickActionOption.outlook.rawValue
                self.navbarQuickActionCustomId = payload.navbarQuickActionCustomId
                self.dashboardSectionsOrder = payload.dashboardSectionsOrder ?? []
                
                if let savedShortcuts = payload.navbarShortcutItems, !savedShortcuts.isEmpty {
                    self.navbarShortcutItems = Array(savedShortcuts.prefix(3))
                } else {
                    let legacyType = payload.navbarQuickActionType ?? NavbarQuickActionOption.outlook.rawValue
                    self.navbarShortcutItems = [NavbarShortcutItem(actionType: legacyType, customShortcutId: payload.navbarQuickActionCustomId)]
                }
                
                // Caricamento e migrazione sorgenti multiple calendari
                if let sources = payload.calendarSources, !sources.isEmpty {
                    self.calendarSources = sources
                } else if !payload.calendarFeedURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let defaultSource = CalendarSource(
                        id: UUID(),
                        title: "Feed Universitario",
                        url: payload.calendarFeedURL,
                        colorHex: "#4F46E5",
                        isAcademic: true,
                        isEnabled: true,
                        sourceType: .webcal,
                        lastSyncDate: payload.lastSyncDate,
                        eventCount: payload.syncedEvents.count
                    )
                    self.calendarSources = [defaultSource]
                } else {
                    self.calendarSources = []
                }
                
                self.ensureDefaultShortcutsExist()
                self.repairSyncedEventTimeZonesIfNeeded()
                // Sync widget data after load
                WidgetDataProvider.shared.sync(from: self)
                return
            } catch {
                print("Errore durante il caricamento del database uni: \(error.localizedDescription)")
            }
        }
        
        // Inizializzazione pulita senza dati di esempio
        self.courses = []
        self.deadlines = []
        self.exams = []
        self.assignments = []
        self.syncedEvents = []
        self.calendarSources = []
        self.calendarFeedURL = ""
        self.lastSyncDate = nil
        self.studentName = ""
        self.universityName = ""
        self.universityPortalURL = ""
        self.hasCompletedOnboarding = false
        self.quickShortcuts = []
        self.navbarQuickActionType = NavbarQuickActionOption.outlook.rawValue
        self.navbarQuickActionCustomId = nil
        self.dashboardSectionsOrder = []
        self.ensureDefaultShortcutsExist()
        saveData()
    }
    
    /// Restituisce l'ordine corrente delle sezioni della dashboard
    public func getDashboardSections() -> [DashboardSection] {
        let allDefaults: [DashboardSection] = [
            .bentoGrid,
            .assignments,
            .upcomingDeadlines,
            .motivationalQuote,
            .todayLectures,
            .activeCourses
        ]
        
        if dashboardSectionsOrder.isEmpty {
            return allDefaults
        }
        
        var result: [DashboardSection] = []
        for raw in dashboardSectionsOrder {
            if let section = DashboardSection(rawValue: raw), !result.contains(section) {
                result.append(section)
            }
        }
        return result.isEmpty ? allDefaults : result
    }
    
    /// Restituisce tutti gli impegni (lezioni, esami, scadenze, compiti, eventi) per la data di oggi
    public func getTodayCommitments() -> [CalendarCommitmentItem] {
        var items: [CalendarCommitmentItem] = []
        let cal = Calendar.current
        let enabledSources = Set(calendarSources.filter { $0.isEnabled }.map { $0.id })
        
        // 1. Eventi sincronizzati dal calendario
        let validEvents = syncedEvents.filter { event in
            if let sId = event.sourceId, !calendarSources.isEmpty && !enabledSources.contains(sId) {
                return false
            }
            return true
        }
        
        for ev in validEvents {
            if cal.isDateInToday(ev.startDate) {
                let type: CalendarCommitmentItem.CommitmentType = {
                    switch ev.category {
                    case .exam: return .exam
                    case .deadline: return .deadline
                    case .lecture: return .lecture
                    case .personal, .other: return ev.isAcademic ? .lecture : .other
                    }
                }()
                
                items.append(CalendarCommitmentItem(
                    id: "event-\(ev.id)-\(Int(ev.startDate.timeIntervalSince1970))",
                    title: ev.title,
                    date: ev.startDate,
                    endDate: ev.endDate,
                    isAllDay: ev.startDate == ev.endDate || (cal.component(.hour, from: ev.startDate) == 0 && cal.component(.minute, from: ev.startDate) == 0 && cal.component(.hour, from: ev.endDate) == 0),
                    type: type,
                    categoryName: ev.category.rawValue,
                    colorHex: ev.calendarColorHex,
                    isCompleted: false,
                    courseName: ev.details.isEmpty ? nil : ev.details
                ))
            }
        }
        
        // 2. Scadenze odierne
        for dl in deadlines where cal.isDateInToday(dl.dueDate) {
            let course = courses.first(where: { $0.id == dl.courseId })?.name
            items.append(CalendarCommitmentItem(
                id: "deadline-\(dl.id)",
                title: dl.title,
                date: dl.dueDate,
                endDate: nil,
                isAllDay: false,
                type: .deadline,
                categoryName: "Deadline",
                colorHex: nil,
                isCompleted: dl.isCompleted,
                courseName: course
            ))
        }
        
        // 3. Esami odierni
        for ex in exams where cal.isDateInToday(ex.examDate) {
            let course = courses.first(where: { $0.id == ex.courseId })?.name
            items.append(CalendarCommitmentItem(
                id: "exam-\(ex.id)",
                title: ex.title,
                date: ex.examDate,
                endDate: nil,
                isAllDay: false,
                type: .exam,
                categoryName: "Exam",
                colorHex: nil,
                isCompleted: ex.status == .passed,
                courseName: course
            ))
        }
        
        // 4. Assignments odierni
        for asg in assignments where cal.isDateInToday(asg.dueDate) {
            let course = courses.first(where: { $0.id == asg.courseId })?.name
            items.append(CalendarCommitmentItem(
                id: "asg-\(asg.id)",
                title: asg.title,
                date: asg.dueDate,
                endDate: nil,
                isAllDay: false,
                type: .assignment,
                categoryName: "Assignment",
                colorHex: nil,
                isCompleted: asg.isCompleted,
                courseName: course
            ))
        }
        
        return items.sorted(by: { $0.date < $1.date })
    }
    
    /// Restituisce tutti gli impegni per l'orizzonte futuro (es. 3, 7, 20 giorni)
    public func getUpcomingCommitments(forDays days: Int) -> [CalendarCommitmentItem] {
        var items: [CalendarCommitmentItem] = []
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let tomorrow = cal.date(byAdding: .day, value: 1, to: today),
              let horizonEnd = cal.date(byAdding: .day, value: days + 1, to: today) else {
            return []
        }
        
        let range = tomorrow..<horizonEnd
        let enabledSources = Set(calendarSources.filter { $0.isEnabled }.map { $0.id })
        
        let validEvents = syncedEvents.filter { event in
            if let sId = event.sourceId, !calendarSources.isEmpty && !enabledSources.contains(sId) {
                return false
            }
            return true
        }
        
        for ev in validEvents {
            if range.contains(ev.startDate) {
                let type: CalendarCommitmentItem.CommitmentType = {
                    switch ev.category {
                    case .exam: return .exam
                    case .deadline: return .deadline
                    case .lecture: return .lecture
                    case .personal, .other: return ev.isAcademic ? .lecture : .other
                    }
                }()
                
                items.append(CalendarCommitmentItem(
                    id: "up-ev-\(ev.id)-\(Int(ev.startDate.timeIntervalSince1970))",
                    title: ev.title,
                    date: ev.startDate,
                    endDate: ev.endDate,
                    isAllDay: ev.startDate == ev.endDate,
                    type: type,
                    categoryName: ev.category.rawValue,
                    colorHex: ev.calendarColorHex,
                    isCompleted: false,
                    courseName: ev.details.isEmpty ? nil : ev.details
                ))
            }
        }
        
        for dl in deadlines where range.contains(dl.dueDate) {
            let course = courses.first(where: { $0.id == dl.courseId })?.name
            items.append(CalendarCommitmentItem(
                id: "up-dl-\(dl.id)",
                title: dl.title,
                date: dl.dueDate,
                endDate: nil,
                isAllDay: false,
                type: .deadline,
                categoryName: "Deadline",
                colorHex: nil,
                isCompleted: dl.isCompleted,
                courseName: course
            ))
        }
        
        for ex in exams where range.contains(ex.examDate) {
            let course = courses.first(where: { $0.id == ex.courseId })?.name
            items.append(CalendarCommitmentItem(
                id: "up-ex-\(ex.id)",
                title: ex.title,
                date: ex.examDate,
                endDate: nil,
                isAllDay: false,
                type: .exam,
                categoryName: "Exam",
                colorHex: nil,
                isCompleted: ex.status == .passed,
                courseName: course
            ))
        }
        
        for asg in assignments where range.contains(asg.dueDate) {
            let course = courses.first(where: { $0.id == asg.courseId })?.name
            items.append(CalendarCommitmentItem(
                id: "up-asg-\(asg.id)",
                title: asg.title,
                date: asg.dueDate,
                endDate: nil,
                isAllDay: false,
                type: .assignment,
                categoryName: "Assignment",
                colorHex: nil,
                isCompleted: asg.isCompleted,
                courseName: course
            ))
        }
        
        return items.sorted(by: { $0.date < $1.date })
    }
    
    // Inizializza le scorciatoie di default se la lista è vuota
    public func ensureDefaultShortcutsExist() {
        if quickShortcuts.isEmpty {
            var defaults: [QuickShortcutLink] = []
            if !universityPortalURL.isEmpty {
                defaults.append(QuickShortcutLink(title: universityName.isEmpty ? "Portale Ateneo" : universityName, url: universityPortalURL, iconName: "globe"))
            } else {
                defaults.append(QuickShortcutLink(title: "Portale Ateneo", url: "https://", iconName: "globe"))
            }
            defaults.append(QuickShortcutLink(title: "Moodle / Piattaforma", url: "https://", iconName: "graduationcap.fill"))
            defaults.append(QuickShortcutLink(title: "Microsoft Teams", url: "https://teams.microsoft.com", iconName: "video.fill"))
            self.quickShortcuts = defaults
        }
    }
    
    // MARK: - Shortcut CRUD Operations
    public func addQuickShortcut(title: String, url: String, iconName: String) {
        var cleanUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanUrl.isEmpty && !cleanUrl.contains("://") {
            cleanUrl = "https://" + cleanUrl
        }
        let item = QuickShortcutLink(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            url: cleanUrl,
            iconName: iconName
        )
        self.quickShortcuts.append(item)
        saveData()
    }
    
    public func updateQuickShortcut(id: UUID, title: String, url: String, iconName: String) {
        guard let idx = self.quickShortcuts.firstIndex(where: { $0.id == id }) else { return }
        var cleanUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanUrl.isEmpty && !cleanUrl.contains("://") {
            cleanUrl = "https://" + cleanUrl
        }
        self.quickShortcuts[idx].title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.quickShortcuts[idx].url = cleanUrl
        self.quickShortcuts[idx].iconName = iconName
        saveData()
    }
    
    public func deleteQuickShortcut(id: UUID) {
        self.quickShortcuts.removeAll { $0.id == id }
        if navbarQuickActionCustomId == id {
            self.navbarQuickActionCustomId = nil
            self.navbarQuickActionType = NavbarQuickActionOption.outlook.rawValue
        }
        navbarShortcutItems.removeAll { $0.actionType == NavbarQuickActionOption.customShortcut.rawValue && $0.customShortcutId == id }
        if navbarShortcutItems.isEmpty {
            navbarShortcutItems = [NavbarShortcutItem(actionType: NavbarQuickActionOption.outlook.rawValue)]
        }
        saveData()
    }
    
    public func setNavbarQuickAction(option: NavbarQuickActionOption, customId: UUID? = nil) {
        self.navbarQuickActionType = option.rawValue
        self.navbarQuickActionCustomId = customId
        if !navbarShortcutItems.isEmpty {
            navbarShortcutItems[0].actionType = option.rawValue
            navbarShortcutItems[0].customShortcutId = customId
        } else {
            navbarShortcutItems = [NavbarShortcutItem(actionType: option.rawValue, customShortcutId: customId)]
        }
        saveData()
    }
    
    public func addNavbarShortcut(option: NavbarQuickActionOption, customId: UUID? = nil) {
        guard navbarShortcutItems.count < 3 else { return }
        let newItem = NavbarShortcutItem(actionType: option.rawValue, customShortcutId: customId)
        navbarShortcutItems.append(newItem)
        if let first = navbarShortcutItems.first {
            self.navbarQuickActionType = first.actionType
            self.navbarQuickActionCustomId = first.customShortcutId
        }
        saveData()
    }
    
    public func removeNavbarShortcut(id: UUID) {
        navbarShortcutItems.removeAll { $0.id == id }
        if navbarShortcutItems.isEmpty {
            navbarShortcutItems = [NavbarShortcutItem(actionType: NavbarQuickActionOption.outlook.rawValue)]
        }
        if let first = navbarShortcutItems.first {
            self.navbarQuickActionType = first.actionType
            self.navbarQuickActionCustomId = first.customShortcutId
        }
        saveData()
    }
    
    public func updateNavbarShortcut(id: UUID, option: NavbarQuickActionOption, customId: UUID? = nil) {
        if let idx = navbarShortcutItems.firstIndex(where: { $0.id == id }) {
            navbarShortcutItems[idx].actionType = option.rawValue
            navbarShortcutItems[idx].customShortcutId = customId
            if idx == 0 {
                self.navbarQuickActionType = option.rawValue
                self.navbarQuickActionCustomId = customId
            }
            saveData()
        }
    }

    
    // MARK: - Timezone Fix for Synced Feeds
    private func repairSyncedEventTimeZonesIfNeeded() {
        let migrationKey = "hasRepairedICSFeedTimezoneV3"
        if UserDefaults.standard.bool(forKey: migrationKey) {
            return
        }
        
        var calendarUTC = Calendar(identifier: .gregorian)
        guard let utcZone = TimeZone(secondsFromGMT: 0) else { return }
        calendarUTC.timeZone = utcZone
        
        var calendarRome = Calendar(identifier: .gregorian)
        calendarRome.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        
        var modified = false
        var updatedEvents = self.syncedEvents
        
        for i in 0..<updatedEvents.count {
            guard updatedEvents[i].isFromCourseFeed else { continue }
            
            // Estrai i componenti anno/mese/giorno/ora/minuto interpretati all'epoca in UTC
            let startComp = calendarUTC.dateComponents([.year, .month, .day, .hour, .minute, .second], from: updatedEvents[i].startDate)
            let endComp = calendarUTC.dateComponents([.year, .month, .day, .hour, .minute, .second], from: updatedEvents[i].endDate)
            
            if let newStart = calendarRome.date(from: startComp),
               let newEnd = calendarRome.date(from: endComp) {
                updatedEvents[i].startDate = newStart
                updatedEvents[i].endDate = newEnd
                modified = true
            }
        }
        
        if modified {
            self.syncedEvents = updatedEvents
            self.saveData()
        }
        
        UserDefaults.standard.set(true, forKey: migrationKey)
    }
    
    // MARK: - Computed University Statistics
    public var totalCfuAcquired: Int {
        var total = 0
        for exam in exams where exam.status == .passed {
            if let course = courses.first(where: { $0.id == exam.courseId }) {
                total += course.cfu
            }
        }
        return total
    }
    
    public var totalCfuTarget: Int {
        courses.reduce(0) { $0 + $1.cfu }
    }
    
    public var weightedAverage: Double {
        var totalPoints = 0
        var totalCfu = 0
        
        for exam in exams where exam.status == .passed {
            if let grade = exam.grade, let course = courses.first(where: { $0.id == exam.courseId }) {
                totalPoints += grade * course.cfu
                totalCfu += course.cfu
            }
        }
        
        guard totalCfu > 0 else { return 0.0 }
        return Double(totalPoints) / Double(totalCfu)
    }
    
    public var estimatedGraduationGrade: Double {
        let avg = weightedAverage
        guard avg > 0 else { return 0.0 }
        return (avg / 30.0) * 110.0
    }
    
    // MARK: - Calendar Feed & Multi-Calendar Sync
    @MainActor
    public func syncCalendarFeed() async {
        await syncAllCalendars()
    }
    
    @MainActor
    public func syncAllCalendars() async {
        // Se non ci sono sorgenti ma c'è un calendarFeedURL legacy, inizializza la prima sorgente
        let trimmedURL = calendarFeedURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if calendarSources.isEmpty && !trimmedURL.isEmpty {
            let initialSource = CalendarSource(
                id: UUID(),
                title: "Feed Universitario",
                url: trimmedURL,
                colorHex: "#4F46E5",
                isAcademic: true,
                isEnabled: true,
                sourceType: .webcal
            )
            calendarSources.append(initialSource)
        }
        
        guard !calendarSources.isEmpty else {
            syncErrorMessage = "Nessun calendario collegato da sincronizzare"
            return
        }
        
        isSyncingCalendar = true
        syncErrorMessage = nil
        syncSuccessMessage = nil
        
        var allEvents: [CalendarEventItem] = []
        var syncErrors: [String] = []
        var syncedCount = 0
        
        for idx in 0..<calendarSources.count {
            guard calendarSources[idx].isEnabled else { continue }
            let source = calendarSources[idx]
            
            switch source.sourceType {
            case .webcal:
                do {
                    let events = try await fetchWebcalEvents(source: source)
                    allEvents.append(contentsOf: events)
                    calendarSources[idx].lastSyncDate = Date()
                    calendarSources[idx].eventCount = events.count
                    syncedCount += 1
                } catch {
                    syncErrors.append("\(source.title): \(error.localizedDescription)")
                }
                
            case .appleCalendar:
                if let identifier = source.appleCalendarIdentifier {
                    if AppleCalendarManager.shared.authorizationStatus != .fullAccess {
                        let ok = await AppleCalendarManager.shared.requestAccess()
                        if !ok {
                            syncErrors.append("\(source.title): " + (LocalizationManager.shared.text(it: "Accesso non autorizzato a Calendario PC", en: "Unauthorized access to PC Calendar")))
                            continue
                        }
                    }
                    
                    let now = Date()
                    let start = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
                    let end = Calendar.current.date(byAdding: .month, value: 12, to: now) ?? now
                    
                    let events = await AppleCalendarManager.shared.fetchEvents(
                        fromCalendarIdentifiers: [identifier],
                        startDate: start,
                        endDate: end,
                        sourceId: source.id,
                        sourceTitle: source.title,
                        sourceColorHex: source.colorHex,
                        isAcademic: source.isAcademic
                    )
                    allEvents.append(contentsOf: events)
                    calendarSources[idx].lastSyncDate = Date()
                    calendarSources[idx].eventCount = events.count
                    syncedCount += 1
                }
                
            case .localFile:
                if !source.url.isEmpty {
                    let fileURL = URL(fileURLWithPath: source.url)
                    if let stringData = try? String(contentsOf: fileURL, encoding: .utf8) {
                        let parsed = parseICS(content: stringData, source: source)
                        allEvents.append(contentsOf: parsed)
                        calendarSources[idx].lastSyncDate = Date()
                        calendarSources[idx].eventCount = parsed.count
                        syncedCount += 1
                    }
                }
            }
        }
        
        // Estrai e sincronizza i corsi universitari unicamente dagli eventi accademici
        let academicEvents = allEvents.filter { $0.isAcademic }
        let syncedAcademic = self.extractAndSyncCourses(from: academicEvents)
        
        var finalEvents: [CalendarEventItem] = syncedAcademic
        for ev in allEvents where !ev.isAcademic {
            finalEvents.append(ev)
        }
        
        self.syncedEvents = finalEvents
        self.lastSyncDate = Date()
        
        if syncErrors.isEmpty {
            self.syncSuccessMessage = "\(finalEvents.count) eventi sincronizzati da \(syncedCount) calendari"
        } else {
            self.syncErrorMessage = syncErrors.joined(separator: " • ")
            if !finalEvents.isEmpty {
                self.syncSuccessMessage = "\(finalEvents.count) eventi sincronizzati (\(syncErrors.count) avvisi)"
            }
        }
        
        self.saveData()
        NotificationManager.shared.scheduleAllReminders(
            deadlines: self.deadlines,
            exams: self.exams,
            courses: self.courses,
            assignments: self.assignments
        )
        self.isSyncingCalendar = false
    }
    
    private func fetchWebcalEvents(source: CalendarSource) async throws -> [CalendarEventItem] {
        var cleanURLStr = source.url.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanURLStr.starts(with: "webcal://") {
            cleanURLStr = "https://" + cleanURLStr.dropFirst("webcal://".count)
        } else if !cleanURLStr.hasPrefix("http://") && !cleanURLStr.hasPrefix("https://") {
            cleanURLStr = "https://" + cleanURLStr
        }
        
        guard let url = URL(string: cleanURLStr) else {
            throw NSError(domain: "uni", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL non valido"])
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)", forHTTPHeaderField: "User-Agent")
        request.setValue("text/calendar, text/plain, */*", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NSError(domain: "uni", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Errore server (\(httpResponse.statusCode))"])
        }
        
        guard let icsString = String(data: data, encoding: .utf8) ??
                              String(data: data, encoding: .isoLatin1) ??
                              String(data: data, encoding: .windowsCP1252) else {
            throw NSError(domain: "uni", code: 422, userInfo: [NSLocalizedDescriptionKey: "Formato testo .ics non riconosciuto"])
        }
        
        return parseICS(content: icsString, source: source)
    }
    
    // MARK: - Calendar Sources Management
    public func addCalendarSource(
        title: String,
        url: String = "",
        colorHex: String = "#4F46E5",
        isAcademic: Bool = true,
        sourceType: CalendarSource.SourceType = .webcal,
        appleCalendarIdentifier: String? = nil
    ) {
        let newSource = CalendarSource(
            id: UUID(),
            title: title.isEmpty ? (sourceType == .appleCalendar ? (LocalizationManager.shared.text(it: "Calendario PC", en: "PC Calendar")) : (LocalizationManager.shared.text(it: "Nuovo Calendario", en: "New Calendar"))) : title,
            url: url,
            colorHex: colorHex,
            isAcademic: isAcademic,
            isEnabled: true,
            sourceType: sourceType,
            appleCalendarIdentifier: appleCalendarIdentifier
        )
        calendarSources.append(newSource)
        if sourceType == .webcal && calendarFeedURL.isEmpty {
            calendarFeedURL = url
        }
        saveData()
    }
    
    public func removeCalendarSource(id: UUID) {
        calendarSources.removeAll { $0.id == id }
        syncedEvents.removeAll { $0.sourceId == id }
        saveData()
    }
    
    public func toggleCalendarSource(id: UUID) {
        if let idx = calendarSources.firstIndex(where: { $0.id == id }) {
            calendarSources[idx].isEnabled.toggle()
            saveData()
        }
    }
    
    public func toggleSourceAcademic(id: UUID) {
        if let idx = calendarSources.firstIndex(where: { $0.id == id }) {
            calendarSources[idx].isAcademic.toggle()
            let newIsAcademic = calendarSources[idx].isAcademic
            for i in 0..<syncedEvents.count {
                if syncedEvents[i].sourceId == id {
                    syncedEvents[i].isAcademic = newIsAcademic
                    syncedEvents[i].isFromCourseFeed = newIsAcademic
                }
            }
            saveData()
        }
    }
    
    @MainActor
    public func importAllMacCalendars() async -> Int {
        let granted = await AppleCalendarManager.shared.requestAccess()
        guard granted else {
            self.syncErrorMessage = LocalizationManager.shared.text(it: "Permesso di accesso ai calendari del PC non concesso", en: "Access permission to PC calendars not granted")
            return 0
        }
        
        let macCals = AppleCalendarManager.shared.getAvailableMacCalendars()
        var addedCount = 0
        
        for macCal in macCals {
            if let existingIdx = calendarSources.firstIndex(where: { $0.appleCalendarIdentifier == macCal.id }) {
                calendarSources[existingIdx].title = macCal.title
                calendarSources[existingIdx].colorHex = macCal.colorHex
            } else {
                let newSource = CalendarSource(
                    id: UUID(),
                    title: "\(macCal.title) (\(macCal.sourceTitle))",
                    url: "",
                    colorHex: macCal.colorHex,
                    isAcademic: macCal.isAcademic,
                    isEnabled: true,
                    sourceType: .appleCalendar,
                    appleCalendarIdentifier: macCal.id
                )
                calendarSources.append(newSource)
                addedCount += 1
            }
        }
        
        await syncAllCalendars()
        return addedCount
    }
    
    // MARK: - Import Local ICS File
    @MainActor
    public func importICSFromFile(url: URL) {
        syncErrorMessage = nil
        syncSuccessMessage = nil
        
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let icsString = String(data: data, encoding: .utf8) ??
                                  String(data: data, encoding: .isoLatin1) ??
                                  String(data: data, encoding: .windowsCP1252) else {
                syncErrorMessage = "Formato del file .ics non supportato"
                return
            }
            
            let fileName = url.deletingPathExtension().lastPathComponent
            let sourceId = UUID()
            let source = CalendarSource(
                id: sourceId,
                title: fileName.isEmpty ? "File .ics" : fileName,
                url: url.path,
                colorHex: "#10B981",
                isAcademic: true,
                isEnabled: true,
                sourceType: .localFile
            )
            
            let parsedEvents = parseICS(content: icsString, source: source)
            if parsedEvents.isEmpty {
                syncErrorMessage = "Nessun evento trovato nel file .ics selezionato"
            } else {
                var updatedSource = source
                updatedSource.eventCount = parsedEvents.count
                updatedSource.lastSyncDate = Date()
                self.calendarSources.append(updatedSource)
                
                let academicEvents = parsedEvents.filter { $0.isAcademic }
                let updatedAcademic = self.extractAndSyncCourses(from: academicEvents)
                
                var final = self.syncedEvents
                final.append(contentsOf: updatedAcademic)
                for ev in parsedEvents where !ev.isAcademic {
                    final.append(ev)
                }
                
                self.syncedEvents = final
                self.lastSyncDate = Date()
                self.syncSuccessMessage = "\(parsedEvents.count) lezioni importate e corsi aggiornati"
                self.saveData()
                NotificationManager.shared.scheduleAllReminders(
                    deadlines: self.deadlines,
                    exams: self.exams,
                    courses: self.courses,
                    assignments: self.assignments
                )
            }
        } catch {
            syncErrorMessage = "Errore durante la lettura del file: \(error.localizedDescription)"
        }
    }

    
    // MARK: - RFC 5545 iCalendar Parser with RRULE & Unfolding
    private func parseICS(content: String, source: CalendarSource? = nil) -> [CalendarEventItem] {
        var items: [CalendarEventItem] = []
        let isAcademic = source?.isAcademic ?? true
        let sourceColor = source?.colorHex
        let sourceTitle = source?.title
        let sourceId = source?.id
        
        // 1. Unfolding RFC 5545: rimuovi CRLF / LF seguiti da spazio o tab
        let unfoldedContent = content
            .replacingOccurrences(of: "\r\n ", with: "")
            .replacingOccurrences(of: "\r\n\t", with: "")
            .replacingOccurrences(of: "\n ", with: "")
            .replacingOccurrences(of: "\n\t", with: "")
        
        let lines = unfoldedContent.components(separatedBy: .newlines)
        
        var inEvent = false
        var summary = ""
        var location = ""
        var description = ""
        var dtStart: Date? = nil
        var dtEnd: Date? = nil
        var uid = ""
        var rrule: String? = nil
        
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }
            
            if line.uppercased() == "BEGIN:VEVENT" {
                inEvent = true
                summary = ""
                location = ""
                description = ""
                dtStart = nil
                dtEnd = nil
                uid = UUID().uuidString
                rrule = nil
                continue
            }
            
            if line.uppercased() == "END:VEVENT" && inEvent {
                inEvent = false
                if let start = dtStart {
                    let duration = dtEnd?.timeIntervalSince(start) ?? (3600 * 2) // default 2h
                    let category: CalendarEventItem.EventCategory
                    if isAcademic {
                        category = (summary.localizedCaseInsensitiveContains("esame") || summary.localizedCaseInsensitiveContains("appello")) ? .exam : .lecture
                    } else {
                        category = .personal
                    }
                    
                    let cleanTitle = summary.isEmpty ? (isAcademic ? "Lezione" : "Impegno") : summary
                    
                    // Se c'è un RRULE (ricorrenza settimanale/giornaliera tipica dei corsi universitari), espandila
                    if let rule = rrule {
                        let occurrences = expandRRULE(rule: rule, start: start, duration: duration)
                        for (idx, occStart) in occurrences.enumerated() {
                            let occEnd = occStart.addingTimeInterval(duration)
                            let item = CalendarEventItem(
                                id: "\(uid)_\(idx)",
                                title: cleanTitle,
                                details: description,
                                location: location,
                                startDate: occStart,
                                endDate: occEnd,
                                isFromCourseFeed: isAcademic,
                                category: category,
                                sourceId: sourceId,
                                calendarTitle: sourceTitle,
                                calendarColorHex: sourceColor,
                                isAcademic: isAcademic
                            )
                            items.append(item)
                        }
                    } else {
                        let end = dtEnd ?? start.addingTimeInterval(duration)
                        let item = CalendarEventItem(
                            id: uid,
                            title: cleanTitle,
                            details: description,
                            location: location,
                            startDate: start,
                            endDate: end,
                            isFromCourseFeed: isAcademic,
                            category: category,
                            sourceId: sourceId,
                            calendarTitle: sourceTitle,
                            calendarColorHex: sourceColor,
                            isAcademic: isAcademic
                        )
                        items.append(item)
                    }
                }
                continue
            }
            
            guard inEvent else { continue }
            
            if line.hasPrefix("SUMMARY:") || line.hasPrefix("SUMMARY;") {
                summary = extractValueFromICSProp(line)
            } else if line.hasPrefix("LOCATION:") || line.hasPrefix("LOCATION;") {
                location = extractValueFromICSProp(line)
            } else if line.hasPrefix("DESCRIPTION:") || line.hasPrefix("DESCRIPTION;") {
                description = extractValueFromICSProp(line)
                    .replacingOccurrences(of: "\\n", with: "\n")
            } else if line.hasPrefix("UID:") {
                uid = String(line.dropFirst("UID:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            } else if line.contains("DTSTART") {
                if let date = extractDateFromICSLine(line) {
                    dtStart = date
                }
            } else if line.contains("DTEND") {
                if let date = extractDateFromICSLine(line) {
                    dtEnd = date
                }
            } else if line.hasPrefix("RRULE:") {
                rrule = String(line.dropFirst("RRULE:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return items
    }
    
    private func extractValueFromICSProp(_ line: String) -> String {
        guard let colonIndex = line.firstIndex(of: ":") else { return "" }
        let raw = String(line[line.index(after: colonIndex)...])
        return raw
            .replacingOccurrences(of: "\\,", with: ",")
            .replacingOccurrences(of: "\\;", with: ";")
            .replacingOccurrences(of: "\\\\", with: "\\")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func resolveTimeZone(from tzString: String) -> TimeZone {
        let clean = tzString.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if let lastSlash = clean.lastIndex(of: "/") {
            let sub = String(clean[clean.index(after: lastSlash)...])
            if let tz = TimeZone(identifier: sub) {
                return tz
            }
        }
        if let tz = TimeZone(identifier: clean) {
            return tz
        }
        
        let lower = clean.lowercased()
        if lower.contains("w. europe") || lower.contains("romance") || lower.contains("central europe") || lower.contains("rome") || lower.contains("berlin") || lower.contains("paris") {
            return TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        }
        if lower.contains("utc") || lower.contains("gmt") || lower.contains("zulu") {
            return TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        }
        
        return TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
    }
    
    // MARK: - Pre-allocated High Performance ICS Formatters
    private static let icsRomeTimeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
    private static let icsPosixLocale = Locale(identifier: "en_US_POSIX")
    
    private static let icsDatePatterns: [(String, Bool)] = [
        ("yyyyMMdd'T'HHmmss'Z'", true),
        ("yyyyMMdd'T'HHmmss", false),
        ("yyyyMMdd'T'HHmm'Z'", true),
        ("yyyyMMdd'T'HHmm", false),
        ("yyyyMMdd", false)
    ]
    
    private static let icsDefaultFormatters: [String: DateFormatter] = {
        var dict: [String: DateFormatter] = [:]
        for (format, _) in icsDatePatterns {
            let f = DateFormatter()
            f.dateFormat = format.replacingOccurrences(of: "'Z'", with: "")
            f.locale = icsPosixLocale
            f.timeZone = icsRomeTimeZone
            dict[format] = f
        }
        return dict
    }()
    
    private func extractDateFromICSLine(_ line: String) -> Date? {
        guard let colonIndex = line.firstIndex(of: ":") else { return nil }
        let header = String(line[..<colonIndex])
        var dateString = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
        if let semicolonIndex = dateString.firstIndex(of: ";") {
            dateString = String(dateString[..<semicolonIndex])
        }
        
        // Estrai eventuale fuso orario esplicito (es. TZID=Europe/Rome o TZID="W. Europe Standard Time")
        var specifiedTimeZone: TimeZone? = nil
        if header.localizedCaseInsensitiveContains("TZID=") {
            let parts = header.components(separatedBy: "TZID=")
            if parts.count > 1 {
                let rawTz = parts[1].components(separatedBy: ";")[0].replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                specifiedTimeZone = resolveTimeZone(from: rawTz)
            }
        }
        
        let hasZ = dateString.hasSuffix("Z")
        let cleanDateString = hasZ ? String(dateString.dropLast()) : dateString
        
        // Se non c'è TZID esplicito (caso comune nel 99% dei feed), usa i formatters pre-allocati
        if specifiedTimeZone == nil {
            for (format, isUTCFormat) in Self.icsDatePatterns {
                if let formatter = Self.icsDefaultFormatters[format] {
                    let targetStr = (hasZ || isUTCFormat) ? cleanDateString : dateString
                    if let d = formatter.date(from: targetStr) {
                        return d
                    }
                }
            }
            return nil
        }
        
        if let tz = specifiedTimeZone {
            for (format, _) in Self.icsDatePatterns {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Self.icsPosixLocale
                formatter.timeZone = tz
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
        }
        return nil
    }
    
    // MARK: - Intelligent Automatic Course & Schedule Extraction
    public func extractAndSyncCourses(from events: [CalendarEventItem]) -> [CalendarEventItem] {
        var updatedEvents = events
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "it_IT")
        calendar.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "it_IT")
        timeFormatter.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        timeFormatter.dateFormat = "HH:mm"
        
        let palette = [
            "#0D5BFF", "#10B981", "#8B5CF6", "#F59E0B",
            "#EF4444", "#06B6D4", "#EC4899", "#6366F1",
            "#14B8A6", "#F97316"
        ]
        
        var groupedEvents: [String: [CalendarEventItem]] = [:]
        for event in events {
            let cleanTitle = cleanCourseName(from: event.title)
            guard !cleanTitle.isEmpty else { continue }
            groupedEvents[cleanTitle, default: []].append(event)
        }
        
        for (courseName, courseEvents) in groupedEvents {
            var targetCourse: Course
            let existingIndex = self.courses.firstIndex {
                $0.name.localizedCaseInsensitiveCompare(courseName) == .orderedSame ||
                $0.name.localizedCaseInsensitiveContains(courseName) ||
                courseName.localizedCaseInsensitiveContains($0.name)
            }
            
            var detectedProf = ""
            var detectedRoom = ""
            for ev in courseEvents {
                if detectedProf.isEmpty {
                    detectedProf = extractProfessor(from: ev.details.isEmpty ? ev.title : "\(ev.title) \(ev.details)")
                }
                if detectedRoom.isEmpty && !ev.location.isEmpty {
                    detectedRoom = ev.location
                }
            }
            
            var detectedSchedules: [CourseSchedule] = []
            
            for ev in courseEvents {
                let weekday = calendar.component(.weekday, from: ev.startDate)
                let dayOfWeek = weekday == 1 ? 7 : (weekday - 1)
                let startStr = timeFormatter.string(from: ev.startDate)
                let endStr = timeFormatter.string(from: ev.endDate)
                let room = ev.location.isEmpty ? detectedRoom : ev.location
                
                let alreadyHasSchedule = detectedSchedules.contains {
                    $0.dayOfWeek == dayOfWeek && $0.startTime == startStr && $0.endTime == endStr
                }
                if !alreadyHasSchedule {
                    detectedSchedules.append(CourseSchedule(
                        dayOfWeek: dayOfWeek,
                        startTime: startStr,
                        endTime: endStr,
                        room: room
                    ))
                }
            }
            
            // Ordina gli orari per giorno della settimana e ora d'inizio
            detectedSchedules.sort {
                if $0.dayOfWeek != $1.dayOfWeek { return $0.dayOfWeek < $1.dayOfWeek }
                return $0.startTime < $1.startTime
            }
            
            if let idx = existingIndex {
                targetCourse = self.courses[idx]
                // Sostituisce gli orari con quelli appena estratti per eliminare orari vecchi o errati
                if !detectedSchedules.isEmpty {
                    targetCourse.schedule = detectedSchedules
                }
                if targetCourse.professor.isEmpty && !detectedProf.isEmpty {
                    targetCourse.professor = detectedProf
                }
                if targetCourse.room.isEmpty && !detectedRoom.isEmpty {
                    targetCourse.room = detectedRoom
                }
                self.courses[idx] = targetCourse
            } else {
                let color = palette[self.courses.count % palette.count]
                targetCourse = Course(
                    name: courseName,
                    professor: detectedProf,
                    room: detectedRoom,
                    schedule: detectedSchedules,
                    colorHex: color
                )
                self.courses.append(targetCourse)
            }
            
            for i in 0..<updatedEvents.count {
                if cleanCourseName(from: updatedEvents[i].title) == courseName {
                    updatedEvents[i].courseId = targetCourse.id
                }
            }
            
            for ev in courseEvents where ev.category == .exam {
                let alreadyHasExam = self.exams.contains {
                    $0.courseId == targetCourse.id && calendar.isDate($0.examDate, inSameDayAs: ev.startDate)
                }
                if !alreadyHasExam {
                    let newExam = Exam(
                        courseId: targetCourse.id,
                        title: ev.title,
                        examDate: ev.startDate,
                        room: ev.location.isEmpty ? detectedRoom : ev.location
                    )
                    self.exams.append(newExam)
                }
            }
        }
        
        return updatedEvents
    }
    
    @MainActor
    public func resyncAllCourseSchedules() {
        guard !syncedEvents.isEmpty else { return }
        let updated = self.extractAndSyncCourses(from: self.syncedEvents)
        self.syncedEvents = updated
        self.saveData()
        NotificationManager.shared.scheduleAllReminders(
            deadlines: self.deadlines,
            exams: self.exams,
            courses: self.courses,
            assignments: self.assignments
        )
    }
    
    private func cleanCourseName(from title: String) -> String {
        var clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let prefixesToRemove = [
            "Lezione di ", "Lezione d'", "Lezione: ", "Lezione ",
            "Esercitazioni di ", "Esercitazione di ", "Esercitazioni ", "Esercitazione ",
            "Laboratorio di ", "Laboratorio ", "Lab di ", "Lab ",
            "Corso di ", "Insegnamento di ", "Lecture: ", "Lecture "
        ]
        for p in prefixesToRemove {
            if clean.lowercased().hasPrefix(p.lowercased()) {
                clean = String(clean.dropFirst(p.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        let suffixesToRemove = [
            " - Lezione", " - Esercitazione", " - Laboratorio", " - Teoria", " - Pratica",
            " - Canale 1", " - Canale 2", " - Canale A", " - Canale B", " - Canale A-L", " - Canale M-Z"
        ]
        for s in suffixesToRemove {
            if clean.lowercased().hasSuffix(s.lowercased()) {
                clean = String(clean.dropLast(s.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        if let startParen = clean.range(of: "("), let endParen = clean.range(of: ")", range: startParen.upperBound..<clean.endIndex) {
            let inside = String(clean[startParen.upperBound..<endParen.lowerBound])
            if inside.localizedCaseInsensitiveContains("prof") || inside.localizedCaseInsensitiveContains("docente") || inside.localizedCaseInsensitiveContains("aula") {
                clean.removeSubrange(startParen.lowerBound...endParen.upperBound)
            }
        }
        
        if let startBracket = clean.range(of: "["), let endBracket = clean.range(of: "]", range: startBracket.upperBound..<clean.endIndex) {
            let inside = String(clean[startBracket.upperBound..<endBracket.lowerBound])
            if inside.localizedCaseInsensitiveContains("aula") || inside.localizedCaseInsensitiveContains("lab") {
                clean.removeSubrange(startBracket.lowerBound...endBracket.upperBound)
            }
        }
        
        clean = clean.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? title : clean
    }
    
    private func extractProfessor(from text: String) -> String {
        let patterns = [
            "Prof(?:\\.|essore|essoressa)?\\s+([A-ZÀ-Ú][a-zà-ú]+(?:\\s+[A-ZÀ-Ú][a-zà-ú]+)+)",
            "Docente:\\s*([A-ZÀ-Ú][a-zà-ú]+(?:\\s+[A-ZÀ-Ú][a-zà-ú]+)+)",
            "Teacher:\\s*([A-ZÀ-Ú][a-zà-ú]+(?:\\s+[A-ZÀ-Ú][a-zà-ú]+)+)"
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                if let range = Range(match.range(at: 1), in: text) {
                    return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return ""
    }

    
    // Espansione di base di RRULE per lezioni universitarie (frequenza settimanale o giornaliera)
    private func expandRRULE(rule: String, start: Date, duration: TimeInterval) -> [Date] {
        var occurrences: [Date] = [start]
        let calendar = Calendar.current
        
        let parts = rule.components(separatedBy: ";")
        var freq: String? = nil
        var interval = 1
        var count: Int? = nil
        var untilDate: Date? = nil
        
        for part in parts {
            let kv = part.components(separatedBy: "=")
            guard kv.count == 2 else { continue }
            let key = kv[0].uppercased()
            let val = kv[1]
            
            if key == "FREQ" {
                freq = val.uppercased()
            } else if key == "INTERVAL", let inv = Int(val) {
                interval = max(1, inv)
            } else if key == "COUNT", let c = Int(val) {
                count = c
            } else if key == "UNTIL" {
                untilDate = extractDateFromICSLine("DTSTART:" + val)
            }
        }
        
        // Limite di espansione per non sovraccaricare la memoria (es. un semestre: 120 giorni)
        let maxLimit = min(count ?? 60, 60)
        let cutoffDate = untilDate ?? calendar.date(byAdding: .day, value: 120, to: start) ?? start.addingTimeInterval(86400 * 120)
        
        var currentDate = start
        var generated = 1
        
        while generated < maxLimit {
            let nextDate: Date?
            if freq == "WEEKLY" {
                nextDate = calendar.date(byAdding: .weekOfYear, value: interval, to: currentDate)
            } else if freq == "DAILY" {
                nextDate = calendar.date(byAdding: .day, value: interval, to: currentDate)
            } else {
                break
            }
            
            guard let next = nextDate, next <= cutoffDate else { break }
            occurrences.append(next)
            currentDate = next
            generated += 1
        }
        
        return occurrences
    }
    
    // MARK: - Export to Apple Calendar (.ics)
    public func exportToAppleCalendar() {
        var ics = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//uni//Organizzazione Universitaria//IT
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        
        """
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Aggiungi Scadenze
        for deadline in deadlines {
            let startStr = dateFormatter.string(from: deadline.dueDate)
            let endStr = dateFormatter.string(from: deadline.dueDate.addingTimeInterval(1800))
            let courseName = courses.first(where: { $0.id == deadline.courseId })?.name ?? "Materia"
            
            ics += """
            BEGIN:VEVENT
            UID:deadline-\(deadline.id.uuidString)@uni
            DTSTAMP:\(startStr)
            DTSTART:\(startStr)
            DTEND:\(endStr)
            SUMMARY:[Scadenza] \(deadline.title) (\(courseName))
            DESCRIPTION:\(deadline.notes)
            STATUS:CONFIRMED
            END:VEVENT
            
            """
        }
        
        // Aggiungi Esami
        for exam in exams {
            let startStr = dateFormatter.string(from: exam.examDate)
            let endStr = dateFormatter.string(from: exam.examDate.addingTimeInterval(7200))
            let courseName = courses.first(where: { $0.id == exam.courseId })?.name ?? "Esame"
            
            ics += """
            BEGIN:VEVENT
            UID:exam-\(exam.id.uuidString)@uni
            DTSTAMP:\(startStr)
            DTSTART:\(startStr)
            DTEND:\(endStr)
            SUMMARY:[Esame] \(exam.title) - \(courseName)
            LOCATION:\(exam.room)
            DESCRIPTION:Tipologia: \(exam.type.rawValue) - Voto Obiettivo: \(exam.targetGrade ?? 30)
            STATUS:CONFIRMED
            END:VEVENT
            
            """
        }
        
        ics += "END:VCALENDAR"
        
        // Scrive su file temporaneo e apre con Apple Calendar
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("uni_calendario.ics")
        do {
            try ics.write(to: tempFile, atomically: true, encoding: .utf8)
            #if canImport(AppKit)
            NSWorkspace.shared.open(tempFile)
            #endif
        } catch {
            print("Errore esportazione iCal: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Clear All Data (Reset Completo come Nuova)
    public func clearAllData() {
        self.courses = []
        self.deadlines = []
        self.exams = []
        self.assignments = []
        self.syncedEvents = []
        self.calendarFeedURL = ""
        self.lastSyncDate = nil
        self.studentName = ""
        self.universityName = ""
        self.universityPortalURL = ""
        self.hasCompletedOnboarding = false
        
        // Pulisce la cache delle email di Outlook e le impostazioni
        OutlookManager.shared.clearCache()
        
        // Rimuove fisicamente il database JSON per ripartire da zero assoluto
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            try? fileManager.removeItem(at: fileURL)
        }
        
        saveData()
    }
}
