//
//  OutlookManager.swift
//  uni
//
//  Created by zinco.cc on 12/09/2026.
//

import SwiftUI
import Combine
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Outlook Manager
public class OutlookManager: ObservableObject {
    public static let shared = OutlookManager()
    
    @Published public var latestEmails: [OutlookMailItem] = []
    @Published public var isSyncing: Bool = false
    @Published public var statusMessage: String? = nil
    @Published public var isOutlookInstalled: Bool = false
    @Published public var lastFetchDate: Date? = nil
    
    private let storageKey = "uni_real_outlook_emails_cache_v1"
    private let lastFetchKey = "uni_real_outlook_last_fetch_date"
    
    private init() {
        checkOutlookStatus()
        loadPersistedRealEmails()
    }
    
    public func checkOutlookStatus() {
        #if canImport(AppKit)
        let isInstalled = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.microsoft.Outlook") != nil
        self.isOutlookInstalled = isInstalled
        #else
        self.isOutlookInstalled = false
        #endif
    }
    
    public var isOutlookRunning: Bool {
        #if canImport(AppKit)
        return !NSRunningApplication.runningApplications(withBundleIdentifier: "com.microsoft.Outlook").isEmpty
        #else
        return false
        #endif
    }
    
    /// Sincronizza le email reali da Microsoft Outlook per Mac tramite AppleScript
    @MainActor
    public func fetchLatestEmails(courses: [Course] = []) async {
        isSyncing = true
        statusMessage = nil
        checkOutlookStatus()
        
        #if canImport(AppKit)
        guard isOutlookInstalled else {
            self.statusMessage = "Microsoft Outlook non è installato nella cartella Applicazioni"
            self.isSyncing = false
            return
        }
        
        guard isOutlookRunning else {
            self.statusMessage = "Microsoft Outlook non è aperto. Fai clic su 'Apri Outlook' per sincronizzare le tue email reali."
            self.isSyncing = false
            return
        }
        
        let scriptSource = """
        tell application "Microsoft Outlook"
            set resList to {}
            try
                set inb to inbox
                set totalCount to count of messages of inb
                set fetchCount to 12
                if totalCount < fetchCount then set fetchCount to totalCount
                
                repeat with i from 1 to fetchCount
                    try
                        set aMsg to message i of inb
                        set msgSub to subject of aMsg
                        set msgSender to ""
                        set msgAddress to ""
                        try
                            set snd to sender of aMsg
                            set msgSender to name of snd
                            set msgAddress to address of snd
                        on error
                            try
                                set msgSender to (sender of aMsg) as string
                            end try
                        end try
                        
                        set msgDate to ""
                        try
                            set msgDate to (time received of aMsg) as «class isot» as string
                        on error
                            try
                                set msgDate to (time sent of aMsg) as «class isot» as string
                            end try
                        end try
                        
                        set msgRead to false
                        try
                            set msgRead to is read of aMsg
                        end try
                        
                        set msgSnippet to ""
                        try
                            set msgSnippet to plain text content of aMsg
                            if length of msgSnippet > 160 then
                                set msgSnippet to text 1 thru 160 of msgSnippet
                            end if
                        end try
                        
                        set end of resList to (msgSub & "|||" & msgSender & "|||" & msgAddress & "|||" & msgDate & "|||" & (msgRead as string) & "|||" & msgSnippet)
                    end try
                end repeat
                
                set AppleScript's text item delimiters to "###"
                return resList as string
            on error errMsg
                return "ERROR:" & errMsg
            end try
        end tell
        """
        
        let script = NSAppleScript(source: scriptSource)
        var errorDict: NSDictionary? = nil
        let output = script?.executeAndReturnError(&errorDict)
        
        if let error = errorDict {
            let errorDesc = (error[NSAppleScript.errorMessage] as? String) ?? "\(error)"
            handleScriptError(errorDesc)
        } else if let stringOutput = output?.stringValue {
            if stringOutput.hasPrefix("ERROR:") {
                let errMsg = String(stringOutput.dropFirst("ERROR:".count))
                handleScriptError(errMsg)
            } else if !stringOutput.isEmpty {
                let parsed = parseAppleScriptResult(stringOutput, courses: courses)
                if !parsed.isEmpty {
                    self.latestEmails = parsed
                    self.lastFetchDate = Date()
                    self.statusMessage = "\(parsed.count) email sincronizzate da Outlook"
                    savePersistedRealEmails()
                } else {
                    self.statusMessage = "Nessuna email trovata nella Posta in arrivo di Outlook"
                }
            } else {
                self.statusMessage = "La Posta in arrivo di Outlook è vuota"
            }
        } else {
            self.statusMessage = "Impossibile comunicare con Microsoft Outlook"
        }
        #else
        self.statusMessage = "Integrazione Outlook disponibile solo su macOS"
        #endif
        
        isSyncing = false
    }
    
    private func handleScriptError(_ errorMsg: String) {
        let lower = errorMsg.lowercased()
        if lower.contains("not supported in the new outlook") || lower.contains("nuovo outlook") {
            self.statusMessage = "Outlook è in modalità 'Nuovo Outlook'. Per leggere le email reali in uni, torna a Outlook Classico (Menu Guida > 'Torna alla versione precedente di Outlook')."
        } else if lower.contains("-1743") || lower.contains("not authorized") || lower.contains("non autorizzato") {
            self.statusMessage = "Autorizzazione richiesta: consenti a 'uni' di controllare Outlook in Impostazioni di Sistema > Privacy e Sicurezza > Automazione."
        } else if lower.contains("non è in esecuzione") || lower.contains("-600") {
            self.statusMessage = "Microsoft Outlook non è aperto. Aprilo per sincronizzare le email reali."
        } else {
            self.statusMessage = "Avviso Outlook: \(errorMsg.trimmingCharacters(in: .whitespacesAndNewlines))"
        }
    }
    
    private func parseAppleScriptResult(_ raw: String, courses: [Course]) -> [OutlookMailItem] {
        var items: [OutlookMailItem] = []
        let records = raw.components(separatedBy: "###")
        let isoFormatter = ISO8601DateFormatter()
        
        for record in records {
            let fields = record.components(separatedBy: "|||")
            guard fields.count >= 4 else { continue }
            
            let subject = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let senderName = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let senderEmail = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let dateStr = fields[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let isRead = fields.count > 4 ? (fields[4].lowercased() == "true") : true
            let snippet = fields.count > 5 ? fields[5].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            
            let receivedDate = isoFormatter.date(from: dateStr) ?? Date()
            
            var matchedCourseId: UUID? = nil
            for c in courses {
                if (!c.professor.isEmpty && (senderName.localizedCaseInsensitiveContains(c.professor) || subject.localizedCaseInsensitiveContains(c.professor))) ||
                   subject.localizedCaseInsensitiveContains(c.name) {
                    matchedCourseId = c.id
                    break
                }
            }
            
            items.append(OutlookMailItem(
                subject: subject.isEmpty ? "Nessun oggetto" : subject,
                senderName: senderName.isEmpty ? (senderEmail.isEmpty ? "Mittente sconosciuto" : senderEmail) : senderName,
                senderEmail: senderEmail,
                dateReceived: receivedDate,
                preview: snippet.replacingOccurrences(of: "\n", with: " "),
                isUnread: !isRead,
                courseId: matchedCourseId
            ))
        }
        
        return items
    }
    
    // MARK: - Persistence of Real Emails Only
    private func savePersistedRealEmails() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.latestEmails)
            UserDefaults.standard.set(data, forKey: storageKey)
            if let date = lastFetchDate {
                UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastFetchKey)
            }
        } catch {
            print("Errore salvataggio cache email reali: \(error)")
        }
    }
    
    private func loadPersistedRealEmails() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            self.latestEmails = []
            return
        }
        do {
            let decoder = JSONDecoder()
            let items = try decoder.decode([OutlookMailItem].self, from: data)
            self.latestEmails = items
            let ts = UserDefaults.standard.double(forKey: lastFetchKey)
            if ts > 0 {
                self.lastFetchDate = Date(timeIntervalSince1970: ts)
            }
        } catch {
            self.latestEmails = []
        }
    }
    
    // MARK: - Clear Cache
    public func clearCache() {
        self.latestEmails = []
        self.lastFetchDate = nil
        self.statusMessage = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: lastFetchKey)
    }
    
    public func openOutlook() {
        #if canImport(AppKit)
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.microsoft.Outlook") {
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        } else if let webURL = URL(string: "https://outlook.office.com") {
            NSWorkspace.shared.open(webURL)
        }
        #endif
    }
    
    public func composeEmail(to recipient: String, subject: String = "") {
        #if canImport(AppKit)
        var comp = URLComponents()
        comp.scheme = "mailto"
        comp.path = recipient
        if !subject.isEmpty {
            comp.queryItems = [URLQueryItem(name: "subject", value: "Re: \(subject)")]
        }
        if let url = comp.url {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}
