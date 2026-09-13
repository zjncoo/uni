//
//  Models.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
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
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.courseId = courseId
        self.dueDate = dueDate
        self.priority = priority
        self.isCompleted = isCompleted
        self.notes = notes
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

// MARK: - Assignment (Compito con collegamento a file locale)
public struct Assignment: Identifiable, Codable, Hashable {
    public var id: UUID
    public var title: String
    public var courseId: UUID
    public var dueDate: Date
    public var details: String
    public var weightPercent: Int // es. 20% del voto finale
    public var isCompleted: Bool
    
    // Riferimento al file locale su Mac
    public var localFilePath: String? // Percorso su disco, es. /Users/nome/.../report.pdf
    public var localFileName: String? // "Relazione_Progetto.pdf"
    public var localFileSize: String? // "3.4 MB"
    
    public init(
        id: UUID = UUID(),
        title: String,
        courseId: UUID,
        dueDate: Date = Date().addingTimeInterval(86400 * 7),
        details: String = "",
        weightPercent: Int = 0,
        isCompleted: Bool = false,
        localFilePath: String? = nil,
        localFileName: String? = nil,
        localFileSize: String? = nil
    ) {
        self.id = id
        self.title = title
        self.courseId = courseId
        self.dueDate = dueDate
        self.details = details
        self.weightPercent = weightPercent
        self.isCompleted = isCompleted
        self.localFilePath = localFilePath
        self.localFileName = localFileName
        self.localFileSize = localFileSize
    }
}

// MARK: - Calendar Feed Event (Eventi da .ics o generati)
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
    
    public enum EventCategory: String, Codable {
        case lecture = "Lezione"
        case exam = "Esame"
        case deadline = "Scadenza"
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
        courseId: UUID? = nil
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
        case .other: return isEn ? "Event" : "Altro"
        }
    }
}

