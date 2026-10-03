//
//  Models.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import Foundation
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Course (Materia)
// MARK: - Course Linked File / Folder (File o cartella locale collegata via percorso, senza duplicazione)
public struct CourseLinkedFile: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var filePath: String
    public var fileSize: String
    public var dateAdded: Date
    public var fileTypeExtension: String
    public var isDirectory: Bool
    public var title: String { name }
    
    enum CodingKeys: String, CodingKey {
        case id, name, filePath, fileSize, dateAdded, fileTypeExtension, isDirectory
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        filePath: String,
        fileSize: String = "",
        dateAdded: Date = Date(),
        fileTypeExtension: String = "",
        isDirectory: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.filePath = filePath
        self.fileSize = fileSize
        self.dateAdded = dateAdded
        self.fileTypeExtension = fileTypeExtension.isEmpty ? (URL(fileURLWithPath: filePath).pathExtension.lowercased()) : fileTypeExtension
        
        if let explicit = isDirectory {
            self.isDirectory = explicit
        } else {
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
            self.isDirectory = isDir.boolValue
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        filePath = try container.decode(String.self, forKey: .filePath)
        fileSize = try container.decodeIfPresent(String.self, forKey: .fileSize) ?? ""
        dateAdded = try container.decodeIfPresent(Date.self, forKey: .dateAdded) ?? Date()
        fileTypeExtension = try container.decodeIfPresent(String.self, forKey: .fileTypeExtension) ?? ""
        
        if let dir = try container.decodeIfPresent(Bool.self, forKey: .isDirectory) {
            isDirectory = dir
        } else {
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: filePath, isDirectory: &isDir)
            isDirectory = isDir.boolValue
        }
    }
}

public struct Course: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var code: String
    public var cfu: Int
    public var professor: String
    public var professorEmail: String
    public var room: String
    public var semester: Int // 1 o 2
    public var notionURL: String // Link alla pagina / workspace Notion
    public var links: [CourseLink]
    public var schedule: [CourseSchedule]
    public var colorHex: String
    public var notes: String
    public var linkedFiles: [CourseLinkedFile]
    
    public init(
        id: UUID = UUID(),
        name: String,
        code: String = "",
        cfu: Int = 6,
        professor: String = "",
        professorEmail: String = "",
        room: String = "",
        semester: Int = 1,
        notionURL: String = "",
        links: [CourseLink] = [],
        schedule: [CourseSchedule] = [],
        colorHex: String = "#007AFF",
        notes: String = "",
        linkedFiles: [CourseLinkedFile] = []
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.cfu = cfu
        self.professor = professor
        self.professorEmail = professorEmail
        self.room = room
        self.semester = semester
        self.notionURL = notionURL
        self.links = links
        self.schedule = schedule
        self.colorHex = colorHex
        self.notes = notes
        self.linkedFiles = linkedFiles
    }
    
    // Decodifica tollerante per retrocompatibilità con i dati salvati
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
        cfu = try container.decodeIfPresent(Int.self, forKey: .cfu) ?? 6
        professor = try container.decodeIfPresent(String.self, forKey: .professor) ?? ""
        professorEmail = try container.decodeIfPresent(String.self, forKey: .professorEmail) ?? ""
        room = try container.decodeIfPresent(String.self, forKey: .room) ?? ""
        semester = try container.decodeIfPresent(Int.self, forKey: .semester) ?? 1
        notionURL = try container.decodeIfPresent(String.self, forKey: .notionURL) ?? ""
        links = try container.decodeIfPresent([CourseLink].self, forKey: .links) ?? []
        schedule = try container.decodeIfPresent([CourseSchedule].self, forKey: .schedule) ?? []
        colorHex = try container.decodeIfPresent(String.self, forKey: .colorHex) ?? "#007AFF"
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        linkedFiles = try container.decodeIfPresent([CourseLinkedFile].self, forKey: .linkedFiles) ?? []
    }
}

// MARK: - Course External Links
public struct CourseLink: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var url: String
    public var type: LinkType
    
    public enum LinkType: String, Codable, CaseIterable {
        case moodle = "Moodle / Portale"
        case teams = "Teams / Zoom"
        case drive = "Drive / Cloud"
        case slides = "Slide / Materiale"
        case syllabus = "Syllabus"
        case general = "Sito Web"
        
        public var iconName: String {
            switch self {
            case .moodle: return "graduationcap.fill"
            case .teams: return "video.fill"
            case .drive: return "externaldrive.fill"
            case .slides: return "doc.text.fill"
            case .syllabus: return "list.bullet.rectangle"
            case .general: return "link"
            }
        }
    }
    
    public init(id: UUID = UUID(), title: String, url: String, type: LinkType = .general) {
        self.id = id
        self.title = title
        self.url = url
        self.type = type
    }
}

// MARK: - Course Schedule (Orario Lezioni)
public struct CourseSchedule: Identifiable, Codable, Hashable {
    public var id: UUID
    public var dayOfWeek: Int // 1 = Lunedì, ..., 5 = Venerdì
    public var startTime: String // "09:00"
    public var endTime: String // "11:00"
    public var room: String
    
    public var dayName: String {
        let isEn = LocalizationManager.shared.currentLanguage == .english
        switch dayOfWeek {
        case 1: return isEn ? "Monday" : "Lunedì"
        case 2: return isEn ? "Tuesday" : "Martedì"
        case 3: return isEn ? "Wednesday" : "Mercoledì"
        case 4: return isEn ? "Thursday" : "Giovedì"
        case 5: return isEn ? "Friday" : "Venerdì"
        case 6: return isEn ? "Saturday" : "Sabato"
        default: return isEn ? "Sunday" : "Domenica"
        }
    }
    
    public init(id: UUID = UUID(), dayOfWeek: Int, startTime: String, endTime: String, room: String = "") {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.startTime = startTime
        self.endTime = endTime
        self.room = room
    }
}

// MARK: - Deadline (Scadenza)
public struct Deadline: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var courseId: UUID?
    public var dueDate: Date
    public var priority: Priority
    public var isCompleted: Bool
    public var notes: String
    public var linkURL: String?
    public var linkURLs: [String] = []
    public var localFilePath: String?
    public var localFileName: String?
    
    public var allLinks: [String] {
        var result = linkURLs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        if let single = linkURL?.trimmingCharacters(in: .whitespacesAndNewlines), !single.isEmpty {
            if !result.contains(single) {
                result.insert(single, at: 0)
            }
        }
        return result
    }
    
    public enum Priority: String, Codable, CaseIterable {
        case low = "Bassa"
        case medium = "Media"
        case high = "Alta"
        
        public var color: Color {
            switch self {
            case .low: return .secondary
            case .medium: return .orange
            case .high: return .red
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        courseId: UUID? = nil,
        dueDate: Date = Date(),
        priority: Priority = .medium,
        isCompleted: Bool = false,
        notes: String = "",
        linkURL: String? = nil,
        linkURLs: [String] = [],
        localFilePath: String? = nil,
        localFileName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.courseId = courseId
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
        self.notes = notes
        self.localFilePath = localFilePath
        self.localFileName = localFileName
        let cleaned = linkURLs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let singleClean = linkURL?.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleaned.isEmpty {
            self.linkURLs = cleaned
            self.linkURL = cleaned.first
        } else if let s = singleClean, !s.isEmpty {
            self.linkURLs = [s]
            self.linkURL = s
        } else {
            self.linkURLs = []
            self.linkURL = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, courseId, dueDate, priority, isCompleted, notes, linkURL, linkURLs, localFilePath, localFileName
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        courseId = try container.decodeIfPresent(UUID.self, forKey: .courseId)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate) ?? Date()
        priority = try container.decodeIfPresent(Priority.self, forKey: .priority) ?? .medium
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        linkURL = try container.decodeIfPresent(String.self, forKey: .linkURL)
        localFilePath = try container.decodeIfPresent(String.self, forKey: .localFilePath)
        localFileName = try container.decodeIfPresent(String.self, forKey: .localFileName)
        let decodedURLs = try container.decodeIfPresent([String].self, forKey: .linkURLs) ?? []
        if !decodedURLs.isEmpty {
            linkURLs = decodedURLs
        } else if let linkURL = linkURL, !linkURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            linkURLs = [linkURL]
        } else {
            linkURLs = []
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(courseId, forKey: .courseId)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(priority, forKey: .priority)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(linkURLs.first ?? linkURL, forKey: .linkURL)
        try container.encode(linkURLs, forKey: .linkURLs)
        try container.encodeIfPresent(localFilePath, forKey: .localFilePath)
        try container.encodeIfPresent(localFileName, forKey: .localFileName)
    }
}

// MARK: - Exam (Esame Universitario)
public struct Exam: Identifiable, Codable, Hashable {
    public var id: UUID
    public var courseId: UUID
    public var title: String
    public var examDate: Date
    public var type: ExamType
    public var room: String
    public var status: ExamStatus
    public var grade: Int? // 18...30
    public var honors: Bool // Lode
    public var targetGrade: Int?
    public var notes: String
    
    public enum ExamType: String, Codable, CaseIterable {
        case written = "Scritto"
        case oral = "Orale"
        case project = "Progetto"
        case writtenOral = "Scritto + Orale"
    }
    
    public enum ExamStatus: String, Codable, CaseIterable {
        case planned = "In programma"
        case studying = "In preparazione"
        case passed = "Superato"
        case rejected = "Da ripetere"
        
        public var badgeColor: Color {
            switch self {
            case .planned: return .secondary
            case .studying: return .orange
            case .passed: return .green
            case .rejected: return .red
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        courseId: UUID,
        title: String,
        examDate: Date = Date().addingTimeInterval(86400 * 14),
        type: ExamType = .writtenOral,
        room: String = "",
        status: ExamStatus = .planned,
        grade: Int? = nil,
        honors: Bool = false,
        targetGrade: Int? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.courseId = courseId
        self.title = title
        self.examDate = examDate
        self.type = type
        self.room = room
        self.status = status
        self.grade = grade
        self.honors = honors
        self.targetGrade = targetGrade
        self.notes = notes
    }
}

// MARK: - Assignment Status
public enum AssignmentStatus: String, Codable, CaseIterable {
    case notStarted = "notStarted"
    case inProgress = "inProgress"
    case completed = "completed"
    
    public func localized(with lm: LocalizationManager) -> String {
        switch self {
        case .notStarted:
            return lm.text(it: "Non ancora iniziato", en: "Not Started")
        case .inProgress:
            return lm.text(it: "In corso", en: "In Progress")
        case .completed:
            return lm.text(it: "Completato", en: "Completed")
        }
    }
    
    public var iconName: String {
        switch self {
        case .notStarted: return "circle.dashed"
        case .inProgress: return "hourglass"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .notStarted: return .secondary
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

// MARK: - Assignment (Compito con collegamento a file locale o link esterno)
public struct Assignment: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var courseId: UUID
    public var dueDate: Date
    public var details: String
    public var weightPercent: Int // es. 20% del voto finale
    public var isCompleted: Bool
    public var status: AssignmentStatus
    
    // Riferimento al file locale su Mac
    public var localFilePath: String? // Percorso su disco, es. /Users/nome/.../report.pdf
    public var localFileName: String? // "Relazione_Progetto.pdf"
    public var localFileSize: String? // "3.4 MB"
    public var linkURL: String? // Link web opzionale per la consegna / specifiche
    public var linkURLs: [String] = []
    
    public var allLinks: [String] {
        var result = linkURLs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        if let single = linkURL?.trimmingCharacters(in: .whitespacesAndNewlines), !single.isEmpty {
            if !result.contains(single) {
                result.insert(single, at: 0)
            }
        }
        return result
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        courseId: UUID,
        dueDate: Date = Date().addingTimeInterval(86400 * 7),
        details: String = "",
        weightPercent: Int = 0,
        isCompleted: Bool = false,
        status: AssignmentStatus? = nil,
        localFilePath: String? = nil,
        localFileName: String? = nil,
        localFileSize: String? = nil,
        linkURL: String? = nil,
        linkURLs: [String] = []
    ) {
        self.id = id
        self.title = title
        self.courseId = courseId
        self.dueDate = dueDate
        self.details = details
        self.weightPercent = weightPercent
        self.isCompleted = isCompleted
        self.status = status ?? (isCompleted ? .completed : .notStarted)
        self.localFilePath = localFilePath
        self.localFileName = localFileName
        self.localFileSize = localFileSize
        let cleaned = linkURLs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let singleClean = linkURL?.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleaned.isEmpty {
            self.linkURLs = cleaned
            self.linkURL = cleaned.first
        } else if let s = singleClean, !s.isEmpty {
            self.linkURLs = [s]
            self.linkURL = s
        } else {
            self.linkURLs = []
            self.linkURL = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, courseId, dueDate, details, weightPercent, isCompleted, status
        case localFilePath, localFileName, localFileSize, linkURL, linkURLs
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        courseId = try container.decodeIfPresent(UUID.self, forKey: .courseId) ?? UUID()
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate) ?? Date()
        details = try container.decodeIfPresent(String.self, forKey: .details) ?? ""
        weightPercent = try container.decodeIfPresent(Int.self, forKey: .weightPercent) ?? 0
        let completed = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        isCompleted = completed
        localFilePath = try container.decodeIfPresent(String.self, forKey: .localFilePath)
        localFileName = try container.decodeIfPresent(String.self, forKey: .localFileName)
        localFileSize = try container.decodeIfPresent(String.self, forKey: .localFileSize)
        linkURL = try container.decodeIfPresent(String.self, forKey: .linkURL)
        let decodedURLs = try container.decodeIfPresent([String].self, forKey: .linkURLs) ?? []
        if !decodedURLs.isEmpty {
            linkURLs = decodedURLs
        } else if let linkURL = linkURL, !linkURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            linkURLs = [linkURL]
        } else {
            linkURLs = []
        }
        if let s = try container.decodeIfPresent(AssignmentStatus.self, forKey: .status) {
            status = s
        } else {
            status = completed ? .completed : .notStarted
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(courseId, forKey: .courseId)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(details, forKey: .details)
        try container.encode(weightPercent, forKey: .weightPercent)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(localFilePath, forKey: .localFilePath)
        try container.encodeIfPresent(localFileName, forKey: .localFileName)
        try container.encodeIfPresent(localFileSize, forKey: .localFileSize)
        try container.encodeIfPresent(linkURLs.first ?? linkURL, forKey: .linkURL)
        try container.encode(linkURLs, forKey: .linkURLs)
    }
}

// MARK: - Dashboard Section for Overview Reordering
public enum DashboardSection: String, CaseIterable, Identifiable, Codable {
    case bentoGrid = "bentoGrid"
    case motivationalQuote = "motivationalQuote"
    case todayLectures = "todayLectures"
    case upcomingDeadlines = "upcomingDeadlines"
    case activeCourses = "activeCourses"
    case assignments = "assignments"
    
    public var id: String { rawValue }
    
    public func localizedTitle(with lm: LocalizationManager) -> String {
        switch self {
        case .bentoGrid:
            return lm.text(it: "Panoramica di Controllo (Bento 2x2)", en: "Control Overview (Bento 2x2)")
        case .motivationalQuote:
            return lm.text(it: "Frase Motivazionale", en: "Motivational Quote")
        case .todayLectures:
            return lm.text(it: "Lezioni di Oggi al Campus", en: "Today at Campus (Lectures)")
        case .activeCourses:
            return lm.text(it: "Materie & Corsi Attivi", en: "Active Courses & Subjects")
        case .upcomingDeadlines:
            return lm.text(it: "Scadenze & Consegne Imminenti", en: "Upcoming Deadlines")
        case .assignments:
            return lm.text(it: "Assignments & File di Progetto", en: "Assignments & Project Files")
        }
    }
    
    public func localizedSubtitle(with lm: LocalizationManager) -> String {
        switch self {
        case .bentoGrid:
            return lm.text(it: "Card riassuntive su scadenza, appello, lezione e portale", en: "Summary cards for next deadline, exam, lecture, and portal")
        case .motivationalQuote:
            return lm.text(it: "Citazione ispirazionale accademica e di crescita", en: "Academic inspiration and growth quote")
        case .todayLectures:
            return lm.text(it: "Orari e aule delle lezioni previste nella giornata", en: "Class schedules and classrooms for today")
        case .activeCourses:
            return lm.text(it: "Accesso rapido ai corsi del semestre e a Notion", en: "Quick access to semester courses and Notion")
        case .upcomingDeadlines:
            return lm.text(it: "Prossimi compiti, promemoria ed adempimenti universitari", en: "Upcoming tasks, reminders, and deadlines")
        case .assignments:
            return lm.text(it: "Progetti, relazioni e link ai file locali o esterni", en: "Projects, papers, and links to local/external files")
        }
    }
    
    public var icon: String {
        switch self {
        case .bentoGrid: return "square.grid.2x2"
        case .motivationalQuote: return "sparkles"
        case .todayLectures: return "calendar.badge.clock"
        case .activeCourses: return "book.closed"
        case .upcomingDeadlines: return "clock"
        case .assignments: return "doc.text"
        }
    }
}

// MARK: - Calendar Commitment Item (A colpo d'occhio per Oggi e Prossimi Giorni)
public struct CalendarCommitmentItem: Identifiable {
    public let id: String
    public let title: String
    public let date: Date
    public let endDate: Date?
    public let isAllDay: Bool
    public let type: CommitmentType
    public let categoryName: String?
    public let colorHex: String?
    public let isCompleted: Bool
    public let courseName: String?
    
    public init(
        id: String,
        title: String,
        date: Date,
        endDate: Date? = nil,
        isAllDay: Bool = false,
        type: CommitmentType,
        categoryName: String? = nil,
        colorHex: String? = nil,
        isCompleted: Bool = false,
        courseName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.type = type
        self.categoryName = categoryName
        self.colorHex = colorHex
        self.isCompleted = isCompleted
        self.courseName = courseName
    }
    
    public enum CommitmentType {
        case lecture
        case exam
        case deadline
        case assignment
        case other
        
        public func localizedName(using lm: LocalizationManager) -> String {
            switch self {
            case .lecture: return lm.text(it: "Lezione", en: "Lecture")
            case .exam: return lm.text(it: "Esame", en: "Exam")
            case .deadline: return lm.text(it: "Scadenza", en: "Deadline")
            case .assignment: return lm.text(it: "Compito", en: "Assignment")
            case .other: return lm.text(it: "Evento", en: "Event")
            }
        }
        
        public var icon: String {
            switch self {
            case .lecture: return "book.closed"
            case .exam: return "graduationcap"
            case .deadline: return "clock"
            case .assignment: return "doc.text"
            case .other: return "calendar"
            }
        }
        
        public func color(theme: ThemeManager) -> Color {
            switch self {
            case .lecture: return theme.accentColor
            case .exam: return .red
            case .deadline: return .orange
            case .assignment: return .purple
            case .other: return .blue
            }
        }
    }
}

// MARK: - Calendar Source (Feed iCal, File Locale o Calendario Mac)
public struct CalendarSource: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var url: String
    public var colorHex: String
    public var isAcademic: Bool
    public var isEnabled: Bool
    public var sourceType: SourceType
    public var appleCalendarIdentifier: String?
    public var lastSyncDate: Date?
    public var eventCount: Int
    
    public enum SourceType: String, Codable, CaseIterable {
        case webcal = "webcal"
        case localFile = "file"
        case appleCalendar = "appleCalendar"
        
        public var icon: String {
            switch self {
            case .webcal: return "link"
            case .localFile: return "doc.text"
            case .appleCalendar: return "calendar.badge.clock"
            }
        }
        
        public func localizedTitle(using lm: LocalizationManager) -> String {
            switch self {
            case .webcal: return lm.text(it: "Feed iCal / Webcal", en: "iCal / Webcal Feed")
            case .localFile: return lm.text(it: "File .ics Locale", en: "Local .ics File")
            case .appleCalendar: return lm.text(it: "Calendario PC", en: "PC Calendar")
            }
        }
        
        public var title: String {
            switch self {
            case .webcal: return "Feed iCal / Webcal"
            case .localFile: return "File .ics Locale"
            case .appleCalendar: return "Calendario PC"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        url: String = "",
        colorHex: String = "#4F46E5",
        isAcademic: Bool = true,
        isEnabled: Bool = true,
        sourceType: SourceType = .webcal,
        appleCalendarIdentifier: String? = nil,
        lastSyncDate: Date? = nil,
        eventCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.colorHex = colorHex
        self.isAcademic = isAcademic
        self.isEnabled = isEnabled
        self.sourceType = sourceType
        self.appleCalendarIdentifier = appleCalendarIdentifier
        self.lastSyncDate = lastSyncDate
        self.eventCount = eventCount
    }
}

// MARK: - Scope Filter for Calendar View
public enum CalendarScopeFilter: Hashable, Equatable {
    case all
    case academicOnly
    case nonAcademicOnly
    case source(UUID)
    
    public var id: String {
        switch self {
        case .all: return "all"
        case .academicOnly: return "academic"
        case .nonAcademicOnly: return "nonAcademic"
        case .source(let uuid): return uuid.uuidString
        }
    }
}

// MARK: - Calendar Feed Event (Eventi da .ics, Calendario Mac o generati)
public struct CalendarEventItem: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var details: String
    public var location: String
    public var startDate: Date
    public var endDate: Date
    public var isFromCourseFeed: Bool
    public var category: EventCategory
    public var courseId: UUID?
    public var sourceId: UUID?
    public var calendarTitle: String?
    public var calendarColorHex: String?
    public var isAcademic: Bool
    
    public var isAllDay: Bool {
        let cal = Calendar.current
        let sH = cal.component(.hour, from: startDate)
        let sM = cal.component(.minute, from: startDate)
        let eH = cal.component(.hour, from: endDate)
        let eM = cal.component(.minute, from: endDate)
        let durationMinutes = Int(endDate.timeIntervalSince(startDate) / 60)
        
        if durationMinutes >= 20 * 60 { return true }
        if sH == 0 && sM == 0 && ((eH == 23 && eM >= 50) || (eH == 0 && durationMinutes >= 12 * 60)) { return true }
        if !cal.isDate(startDate, inSameDayAs: endDate) && durationMinutes >= 12 * 60 { return true }
        return false
    }
    
    public enum EventCategory: String, Codable {
        case lecture = "Lezione"
        case exam = "Esame"
        case deadline = "Scadenza"
        case personal = "Personale"
        case other = "Evento"
    }
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        details: String = "",
        location: String = "",
        startDate: Date,
        endDate: Date,
        isFromCourseFeed: Bool = false,
        category: EventCategory = .other,
        courseId: UUID? = nil,
        sourceId: UUID? = nil,
        calendarTitle: String? = nil,
        calendarColorHex: String? = nil,
        isAcademic: Bool = true
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.isFromCourseFeed = isFromCourseFeed
        self.category = category
        self.courseId = courseId
        self.sourceId = sourceId
        self.calendarTitle = calendarTitle
        self.calendarColorHex = calendarColorHex
        self.isAcademic = isAcademic
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        details = try container.decodeIfPresent(String.self, forKey: .details) ?? ""
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        isFromCourseFeed = try container.decodeIfPresent(Bool.self, forKey: .isFromCourseFeed) ?? false
        category = try container.decodeIfPresent(EventCategory.self, forKey: .category) ?? .other
        courseId = try container.decodeIfPresent(UUID.self, forKey: .courseId)
        sourceId = try container.decodeIfPresent(UUID.self, forKey: .sourceId)
        calendarTitle = try container.decodeIfPresent(String.self, forKey: .calendarTitle)
        calendarColorHex = try container.decodeIfPresent(String.self, forKey: .calendarColorHex)
        if let ac = try container.decodeIfPresent(Bool.self, forKey: .isAcademic) {
            isAcademic = ac
        } else {
            isAcademic = isFromCourseFeed || category == .lecture || category == .exam
        }
    }
}

// MARK: - System & App Integration Helpers
public enum AppSystemHelper {
    
    /// Apre direttamente la pagina o database in Notion Desktop (se presente) oppure nel browser
    public static func openNotionPage(urlString: String) {
        guard !urlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Se è già un URI nativo notion://...
        if trimmed.starts(with: "notion://") {
            if let url = URL(string: trimmed) {
                #if canImport(AppKit)
                NSWorkspace.shared.open(url)
                #endif
            }
            return
        }
        
        // Se è un URL https://www.notion.so/... o https://notion.so/...
        if trimmed.contains("notion.so") || trimmed.contains("notion.site") {
            // Conversione a deep-link per l'app desktop nativa macOS:
            let desktopLink = trimmed
                .replacingOccurrences(of: "https://www.notion.so", with: "notion://www.notion.so")
                .replacingOccurrences(of: "https://notion.so", with: "notion://notion.so")
                .replacingOccurrences(of: "http://www.notion.so", with: "notion://www.notion.so")
                .replacingOccurrences(of: "http://notion.so", with: "notion://notion.so")
            
            if let desktopURL = URL(string: desktopLink) {
                #if canImport(AppKit)
                if NSWorkspace.shared.open(desktopURL) {
                    return
                }
                #endif
            }
        }
        
        // Fallback su browser standard
        if let fallbackURL = URL(string: trimmed.hasPrefix("http") ? trimmed : "https://\(trimmed)") {
            #if canImport(AppKit)
            NSWorkspace.shared.open(fallbackURL)
            #endif
        }
    }
    
    /// Apre qualsiasi file o cartella locale sul Mac con l'applicazione di default di sistema
    public static func openLocalFile(path: String) {
        guard !path.isEmpty else { return }
        let url = URL(fileURLWithPath: path)
        #if canImport(AppKit)
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.open(url)
        } else {
            // Se il file non esiste al percorso specifico, tenta di mostrare in Finder la cartella genitore
            let parent = url.deletingLastPathComponent()
            if FileManager.default.fileExists(atPath: parent.path) {
                NSWorkspace.shared.open(parent)
            }
        }
        #endif
    }
    
    /// Mostra il file in Finder selezionandolo
    public static func revealInFinder(path: String) {
        guard !path.isEmpty else { return }
        let url = URL(fileURLWithPath: path)
        #if canImport(AppKit)
        NSWorkspace.shared.activateFileViewerSelecting([url])
        #endif
    }
    
    /// Apre un generico URL web
    public static func openWebURL(urlString: String) {
        var str = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !str.hasPrefix("http://") && !str.hasPrefix("https://") {
            str = "https://" + str
        }
        if let url = URL(string: str) {
            #if canImport(AppKit)
            NSWorkspace.shared.open(url)
            #endif
        }
    }
    
    /// Formatta la dimensione del file in bytes o il numero di elementi per le cartelle
    public static func formatFileSize(atPath path: String) -> String {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: path)
                    let nonHidden = contents.filter { !$0.hasPrefix(".") }
                    let isEn = LocalizationManager.shared.currentLanguage == .english
                    if isEn {
                        return "\(nonHidden.count) \(nonHidden.count == 1 ? "item" : "items")"
                    } else {
                        return "\(nonHidden.count) \(nonHidden.count == 1 ? "elemento" : "elementi")"
                    }
                } catch {
                    return LocalizationManager.shared.currentLanguage == .english ? "Folder" : "Cartella"
                }
            } else {
                do {
                    let attrs = try FileManager.default.attributesOfItem(atPath: path)
                    if let size = attrs[.size] as? Int64 {
                        let formatter = ByteCountFormatter()
                        formatter.allowedUnits = [.useAll]
                        formatter.countStyle = .file
                        return formatter.string(fromByteCount: size)
                    }
                } catch { }
            }
        }
        return ""
    }
}

// MARK: - Outlook Mail Item (Lettura e integrazione Microsoft Outlook per Mac)
public struct OutlookMailItem: Identifiable, Codable, Hashable {
    public var id: String
    public var subject: String
    public var senderName: String
    public var senderEmail: String
    public var dateReceived: Date
    public var preview: String
    public var isUnread: Bool
    public var courseId: UUID?
    
    public init(
        id: String = UUID().uuidString,
        subject: String,
        senderName: String,
        senderEmail: String = "",
        dateReceived: Date = Date(),
        preview: String = "",
        isUnread: Bool = false,
        courseId: UUID? = nil
    ) {
        self.id = id
        self.subject = subject
        self.senderName = senderName
        self.senderEmail = senderEmail
        self.dateReceived = dateReceived
        self.preview = preview
        self.isUnread = isUnread
        self.courseId = courseId
    }
}

// MARK: - Localized Display Names
extension Exam.ExamType {
    public var localizedName: String {
        let isEn = LocalizationManager.shared.currentLanguage == .english
        switch self {
        case .written: return isEn ? "Written" : "Scritto"
        case .oral: return isEn ? "Oral" : "Orale"
        case .project: return isEn ? "Project" : "Progetto"
        case .writtenOral: return isEn ? "Written + Oral" : "Scritto + Orale"
        }
    }
}

extension Exam.ExamStatus {
    public var localizedName: String {
        let isEn = LocalizationManager.shared.currentLanguage == .english
        switch self {
        case .planned: return isEn ? "Scheduled" : "In programma"
        case .studying: return isEn ? "Preparing" : "In preparazione"
        case .passed: return isEn ? "Passed" : "Superato"
        case .rejected: return isEn ? "To Retake" : "Da ripetere"
        }
    }
}

extension Deadline.Priority {
    public var localizedName: String {
        let isEn = LocalizationManager.shared.currentLanguage == .english
        switch self {
        case .low: return isEn ? "Low" : "Bassa"
        case .medium: return isEn ? "Medium" : "Media"
        case .high: return isEn ? "Urgent" : "Urgente"
        }
    }
}

extension CourseLink.LinkType {
    public var localizedName: String {
        let isEn = LocalizationManager.shared.currentLanguage == .english
        switch self {
        case .moodle: return isEn ? "Moodle / Portal" : "Moodle / Portale"
        case .teams: return "Teams / Zoom"
        case .drive: return "Drive / Cloud"
        case .slides: return isEn ? "Slides / Handouts" : "Slide / Materiale"
        case .syllabus: return "Syllabus"
        case .general: return isEn ? "Website" : "Sito Web"
        }
    }
}

extension CalendarEventItem.EventCategory {
    public var localizedName: String {
        let isEn = LocalizationManager.shared.currentLanguage == .english
        switch self {
        case .lecture: return isEn ? "Lecture" : "Lezione"
        case .exam: return isEn ? "Exam" : "Esame"
        case .deadline: return isEn ? "Deadline" : "Scadenza"
        case .personal: return isEn ? "Personal" : "Personale"
        case .other: return isEn ? "Event" : "Altro"
        }
    }
}

// MARK: - Quick Shortcut Link (Scorciatoie Home & Accesso Rapido)
public struct QuickShortcutLink: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var url: String
    public var iconName: String
    public var dateAdded: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        url: String,
        iconName: String = "link",
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.iconName = iconName
        self.dateAdded = dateAdded
    }
}

// MARK: - Navbar Quick Action Option (Scelta del Bottone Rapido nella Navbar)
public enum NavbarQuickActionOption: String, Codable, CaseIterable, Identifiable {
    case outlook = "outlook"
    case portal = "portal"
    case focusTimer = "focusTimer"
    case quickSearch = "quickSearch"
    case newEntry = "newEntry"
    case customShortcut = "customShortcut"
    
    public var id: String { rawValue }
    
    public var defaultIcon: String {
        switch self {
        case .outlook: return "envelope.fill"
        case .portal: return "globe"
        case .focusTimer: return "timer"
        case .quickSearch: return "magnifyingglass"
        case .newEntry: return "plus"
        case .customShortcut: return "link"
        }
    }
    
    public func displayName(isItalian: Bool = true) -> String {
        switch self {
        case .outlook:
            return isItalian ? "Microsoft Outlook / Posta" : "Microsoft Outlook / Mail"
        case .portal:
            return isItalian ? "Portale Ateneo" : "University Portal"
        case .focusTimer:
            return isItalian ? "Focus Timer (⌘T)" : "Focus Timer (⌘T)"
        case .quickSearch:
            return isItalian ? "Ricerca Globale (⌘F)" : "Global Search (⌘F)"
        case .newEntry:
            return isItalian ? "Nuovo Elemento (⌘N)" : "New Item (⌘N)"
        case .customShortcut:
            return isItalian ? "Scorciatoia Personalizzata" : "Custom Shortcut"
        }
    }
}

// MARK: - Navbar Shortcut Item (Fino a 3 scorciatoie in basso nella barra laterale)
public struct NavbarShortcutItem: Codable, Identifiable, Hashable {
    public var id: UUID
    public var actionType: String // NavbarQuickActionOption rawValue
    public var customShortcutId: UUID?
    
    public init(id: UUID = UUID(), actionType: String, customShortcutId: UUID? = nil) {
        self.id = id
        self.actionType = actionType
        self.customShortcutId = customShortcutId
    }
}

