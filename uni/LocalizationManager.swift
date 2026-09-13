//
//  LocalizationManager.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
//

import SwiftUI
import Combine

public enum AppLanguage: String, CaseIterable, Identifiable {
    case italian = "it"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .italian: return "Italiano"
        case .english: return "English"
        }
    }
    
    public var flag: String {
        switch self {
        case .italian: return "🇮🇹"
        case .english: return "🇬🇧"
        }
    }
}

public class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    private static let storageKey = "uni_app_language"
    
    @Published public var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: Self.storageKey)
        }
    }
    
    public init() {
        let saved = UserDefaults.standard.string(forKey: Self.storageKey) ?? "it"
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .italian
    }
    
    public func t(_ key: LocalizedKey) -> String {
        key.string(for: currentLanguage)
    }
    
    /// Helper rapido per testi dinamici bilingue IT / EN
    public func text(it: String, en: String) -> String {
        currentLanguage == .english ? en : it
    }
}

// MARK: - Localized Keys
public enum LocalizedKey {
    // Navigazione
    case navGeneral
    case navOverview
    case navCalendar
    case navCoursesSection
    case navCourses
    case navActivitiesSection
    case navDeadlines
    case navExams
    case navAssignments
    case navSettings
    
    // Quotes / Motivazione
    case quoteTitle
    case newQuoteAction
    
    // Overview / Dashboard
    case overviewTitle
    case newDeadlineAction
    case welcomeTitle
    case welcomeSubtitle
    case welcomeDesc
    case addCourseAction
    case linkCalendarAction
    case createDeadlineAction
    case weightedAverage
    case baseGraduationGrade
    case waitingGrades
    case registeredCredits
    case pendingExams
    case upToDate
    case todayLectures
    case upcomingDeadlines
    case viewAll
    case noLecturesToday
    case noPendingDeadlines
    case activeDeadlines
    case nextExam
    case todayAtUni
    case activeCourses
    case assignmentsAndFiles
    case noEventsToday
    case noEventsTodayDesc
    case noDeadlinesDesc
    case allCount(Int)
    
    // Courses
    case coursesTitle
    case coursesSubtitle
    case newCourseAction
    case selectCoursePlaceholder
    case selectCourseDesc
    case searchCoursesPlaceholder
    case noCoursesEmptyTitle
    case noCoursesEmptyDesc
    case addCourseButton
    case courseCfu(Int)
    case semester(Int)
    case notionSection
    case openInNotion
    case externalLinksSection
    case addLinkAction
    case weeklyScheduleSection
    case addScheduleAction
    
    // Deadlines
    case deadlinesTitle
    case deadlinesSubtitle(Int)
    case filterAll
    case filterPending
    case filterUrgent
    case filterCompleted
    case noDeadlinesEmptyTitle
    case noDeadlinesEmptyDesc
    case noMatchingDeadlines
    
    // Exams
    case examsTitle
    case examsSubtitle
    case planExamAction
    case cfuProgress
    case startGrade(Int)
    case awaitingExams
    case registerGradeAction
    case noExamsEmptyTitle
    case noExamsEmptyDesc
    
    // Assignments
    case assignmentsTitle
    case assignmentsSubtitle(Int, Int)
    case newAssignmentAction
    case inProgress
    case completed
    case noAssignmentsEmptyTitle
    case noAssignmentsEmptyDesc
    case allAssignmentsCompleted
    
    // Settings
    case settingsTitle
    case settingsSubtitle
    case themeModeSection
    case themeModeSubtitle
    case themeLight
    case themeDark
    case themeSystem
    case languageSection
    case languageSubtitle
    case appearanceSection
    case accentColorTitle
    case accentColorSubtitle
    case presetsTitle
    case customQuotesSection
    case customQuotesSubtitle
    case addQuotePlaceholder
    case addQuoteButton
    case activeQuotesTitle
    case typographySection
    case typographyTitle
    case typographySubtitle
    case dataManagementSection
    case dataManagementTitle
    case dataManagementSubtitle
    case exportBackup
    case restoreBackup
    case clearAllData
    case clearConfirmTitle
    case clearConfirmMessage
    case cancel
    case delete
    
    // Calendar
    case schoolCalendar
    case today
    case feedTitle
    case feedLastUpdate(String)
    case feedNone
    case syncButton
    case syncExportApple
    case pasteFeedURL
    case saveAndSync
    case chooseICSFile
    case orUploadICS
    case dayAgenda
    case noEventsThisDay
    
    // Update checker
    case updateBannerLabel
    case updateChangelog
    case updateInstall
    case updateInstalling
    case updateDismiss
    
    // Dashboard / portal
    case universityPortal
    case portalLink
    case portalAccess
    case openPortal
    case configureLink
    case editLink
    case noCourse
    case urgencyHigh(Int)
    case noUrgency
    
    // Sidebar footer
    case currentGPA
    case totalCredits
    
    // Timer
    case focusCompleted
    case breakEnded
    case greatWork(String)
    case readyToFocus
    
    // Menu commands
    case syncCalendarCmd
    case exportCalendarCmd
    case calendarSynced
    case eventsUpdated(Int)
    case calendarExported
    case calendarExportedMsg
    
    // Content notifications
    case deadlineCreated
    case examScheduled
    case assignmentCreated
    case courseAdded(String, Int)
    case portalUpdated
    case portalSaved(String)
    case portalRemoved
    
    // Helper translation string
    public func string(for lang: AppLanguage) -> String {
        switch lang {
        case .italian:
            switch self {
            case .navGeneral: return "GENERALE"
            case .navOverview: return "Panoramica"
            case .navCalendar: return "Calendario"
            case .navCoursesSection: return "DIDATTICA"
            case .navCourses: return "Materie"
            case .navActivitiesSection: return "ATTIVITÀ & SCADENZE"
            case .navDeadlines: return "Scadenze"
            case .navExams: return "Esami"
            case .navAssignments: return "Assignments"
            case .navSettings: return "Impostazioni"
                
            case .quoteTitle: return "MOTIVAZIONE DI OGGI"
            case .newQuoteAction: return "Nuova Frase"
                
            case .overviewTitle: return "Panoramica"
            case .newDeadlineAction: return "Nuova Scadenza"
            case .welcomeTitle: return "BENVENUTO IN UNI"
            case .welcomeSubtitle: return "Inizia ad organizzare il tuo percorso accademico."
            case .welcomeDesc: return "Aggiungi le tue materie, pianifica gli appelli d'esame, tieni traccia delle scadenze o collega il link del calendario del tuo corso di studi."
            case .addCourseAction: return "Aggiungi Materia"
            case .linkCalendarAction: return "Collega Calendario (.ics)"
            case .createDeadlineAction: return "Crea Scadenza"
            case .weightedAverage: return "Media Ponderata"
            case .baseGraduationGrade: return "Base laurea"
            case .waitingGrades: return "In attesa di verbalizzazioni"
            case .registeredCredits: return "CFU Acquisiti"
            case .pendingExams: return "Esami Rimanenti"
            case .upToDate: return "Tutto in regola"
            case .todayLectures: return "Lezioni di Oggi"
            case .upcomingDeadlines: return "Prossime Scadenze"
            case .viewAll: return "Vedi tutte"
            case .noLecturesToday: return "Nessuna lezione in programma oggi"
            case .noPendingDeadlines: return "Nessuna scadenza imminente"
            case .activeDeadlines: return "Scadenze Attive"
            case .nextExam: return "Prossimo Esame"
            case .todayAtUni: return "OGGI IN FACOLTÀ"
            case .activeCourses: return "MATERIE ATTIVE"
            case .assignmentsAndFiles: return "ASSIGNMENTS & FILE MAC"
            case .noEventsToday: return "Nessun impegno oggi"
            case .noEventsTodayDesc: return "Le lezioni e gli appelli previsti per oggi compariranno qui."
            case .noDeadlinesDesc: return "Non ci sono scadenze in sospeso."
            case .allCount(let count): return "Tutte (\(count))"
                
            case .coursesTitle: return "Materie"
            case .coursesSubtitle: return "Piano di studi & Risorse"
            case .newCourseAction: return "Nuova Materia"
            case .selectCoursePlaceholder: return "Seleziona una materia"
            case .selectCourseDesc: return "Orari, collegamenti Notion, risorse esterne, esami e note."
            case .searchCoursesPlaceholder: return "Cerca materia..."
            case .noCoursesEmptyTitle: return "Nessuna materia registrata"
            case .noCoursesEmptyDesc: return "Inserisci i tuoi corsi di studio per tracciare crediti formativi, orari e note."
            case .addCourseButton: return "Aggiungi Materia"
            case .courseCfu(let cfu): return "\(cfu) CFU"
            case .semester(let sem): return "Semestre \(sem)"
            case .notionSection: return "NOTION DESKTOP"
            case .openInNotion: return "Apri in Notion"
            case .externalLinksSection: return "RISORSE & LINK ESTERNI"
            case .addLinkAction: return "Aggiungi Link"
            case .weeklyScheduleSection: return "ORARIO SETTIMANALE"
            case .addScheduleAction: return "Aggiungi Slot"
                
            case .deadlinesTitle: return "Scadenze"
            case .deadlinesSubtitle(let pending): return "\(pending) da completare"
            case .filterAll: return "Tutte"
            case .filterPending: return "In sospeso"
            case .filterUrgent: return "Urgenti"
            case .filterCompleted: return "Completate"
            case .noDeadlinesEmptyTitle: return "Nessuna scadenza"
            case .noDeadlinesEmptyDesc: return "Aggiungi promemoria per scadenze amministrative, iscrizioni o consegne."
            case .noMatchingDeadlines: return "Nessuna scadenza trovata"
                
            case .examsTitle: return "Esami"
            case .examsSubtitle: return "Libretto & Sessioni d'Appello"
            case .planExamAction: return "Pianifica Esame"
            case .cfuProgress: return "PROGRESSO CFU"
            case .startGrade(let grade): return "Voto di partenza: ~\(grade)/110"
            case .awaitingExams: return "In attesa di esami registrati"
            case .registerGradeAction: return "Registra Voto"
            case .noExamsEmptyTitle: return "Nessun esame registrato"
            case .noExamsEmptyDesc: return "Aggiungi le sessioni d'esame per calcolare la tua media ponderata e il voto di laurea."
                
            case .assignmentsTitle: return "Assignments"
            case .assignmentsSubtitle(let inProg, let done): return "\(inProg) in corso • \(done) completati"
            case .newAssignmentAction: return "Nuovo Assignment"
            case .inProgress: return "In Corso"
            case .completed: return "Completati"
            case .noAssignmentsEmptyTitle: return "Nessun assignment registrato"
            case .noAssignmentsEmptyDesc: return "Aggiungi progetti, tesine o relazioni ed associa i file memorizzati sul tuo computer."
            case .allAssignmentsCompleted: return "Tutti gli assignment completati"
                
            case .settingsTitle: return "Impostazioni"
            case .settingsSubtitle: return "Personalizzazione, Aspetto, Lingua & Dati"
            case .themeModeSection: return "TEMA DI SISTEMA"
            case .themeModeSubtitle: return "Scegli l'aspetto dell'interfaccia: tema chiaro, tema scuro o sincronizzazione automatica con macOS."
            case .themeLight: return "Chiaro"
            case .themeDark: return "Scuro"
            case .themeSystem: return "Automatico (Sistema)"
            case .languageSection: return "LINGUA / LANGUAGE"
            case .languageSubtitle: return "Seleziona la lingua dell'interfaccia dell'applicazione."
            case .appearanceSection: return "PALETTE A 2 COLORI & ACCENTO"
            case .accentColorTitle: return "Colore d'Accento Primario"
            case .accentColorSubtitle: return "Personalizza il colore guida di tutta l'app: bottoni, badge, indicatori del calendario e grafici."
            case .presetsTitle: return "Preset Selezionati"
            case .customQuotesSection: return "FRASI MOTIVAZIONALI HOME"
            case .customQuotesSubtitle: return "Aggiungi le tue frasi motivazionali preferite da mostrare in cima alla dashboard."
            case .addQuotePlaceholder: return "Scrivi una nuova frase motivazionale..."
            case .addQuoteButton: return "Aggiungi Frase"
            case .activeQuotesTitle: return "Frasi Attive"
            case .typographySection: return "TIPOGRAFIA"
            case .typographyTitle: return "SF Pro (Apple System Style)"
            case .typographySubtitle: return "Tipografia nativa di sistema con rendering pulito, proporzioni geometriche e leggibilità eccellente su macOS."
            case .dataManagementSection: return "GESTIONE DATI & BACKUP"
            case .dataManagementTitle: return "Persistenza Locale e Salvataggio Sicuro"
            case .dataManagementSubtitle: return "Tutti i dati sono salvati in locale sul Mac in formato JSON. Puoi esportare o ripristinare una copia di sicurezza in qualsiasi momento."
            case .exportBackup: return "Esporta Backup JSON"
            case .restoreBackup: return "Ripristina da Backup"
            case .clearAllData: return "Cancella Tutti i Dati"
            case .clearConfirmTitle: return "Cancellare tutti i dati?"
            case .clearConfirmMessage: return "Questa azione cancellerà tutti i corsi, le scadenze, gli esami e gli assignment memorizzati. L'app tornerà allo stato iniziale pulito."
            case .cancel: return "Annulla"
            case .delete: return "Cancella Tutto"
                
            case .schoolCalendar: return "CALENDARIO SCOLASTICO"
            case .today: return "Oggi"
            case .feedTitle: return "Feed Calendario (.ics / webcal)"
            case .feedLastUpdate(let date): return "Ultimo aggiornamento: \(date)"
            case .feedNone: return "Nessun feed collegato"
            case .syncButton: return "Sincronizza"
            case .syncExportApple: return "Esporta in Apple Calendar (.ics)"
            case .pasteFeedURL: return "Incolla l'URL del calendario fornito dal tuo ateneo:"
            case .saveAndSync: return "Salva e Sincronizza"
            case .chooseICSFile: return "Scegli file .ics..."
            case .orUploadICS: return "Oppure carica un file scaricato (.ics):"
            case .dayAgenda: return "AGENDA DEL GIORNO"
            case .noEventsThisDay: return "Nessun evento per questo giorno"
            
            // Update
            case .updateBannerLabel: return "Aggiornamento"
            case .updateChangelog: return "Novità:"
            case .updateInstall: return "Installa ora"
            case .updateInstalling: return "Installazione..."
            case .updateDismiss: return "Ignora"
            
            // Dashboard / portal
            case .universityPortal: return "Portale Universitario"
            case .portalLink: return "Collega il sito del tuo ateneo (Esse3, orari, pagina corsi) per aprirlo con 1 clic"
            case .portalAccess: return "Accesso rapido ai servizi studenti e alla pagina d'Ateneo"
            case .openPortal: return "Apri Portale"
            case .configureLink: return "Configura Link"
            case .editLink: return "Modifica"
            case .noCourse: return "Nessuna materia"
            case .urgencyHigh(let n): return "\(n) priorità alta"
            case .noUrgency: return "Nessuna urgenza"
            
            // Sidebar footer
            case .currentGPA: return "MEDIA ATTUALE"
            case .totalCredits: return "CFU TOTALI"
            
            // Timer
            case .focusCompleted: return "Sessione completata! 🎉"
            case .breakEnded: return "Pausa terminata! ☕️"
            case .greatWork(let name): return "Ottimo lavoro su \(name). Prenditi una pausa."
            case .readyToFocus: return "Pronto a ricominciare con la massima concentrazione?"
            
            // Menu commands
            case .syncCalendarCmd: return "Sincronizza Calendario Orario"
            case .exportCalendarCmd: return "Esporta in Apple Calendar"
            case .calendarSynced: return "Calendario sincronizzato"
            case .eventsUpdated(let n): return "\(n) lezioni ed eventi aggiornati."
            case .calendarExported: return "Calendario esportato"
            case .calendarExportedMsg: return "File .ics aperto in Apple Calendar"
            
            // Content notifications
            case .deadlineCreated: return "Scadenza creata"
            case .examScheduled: return "Appello programmato"
            case .assignmentCreated: return "Assignment creato"
            case .courseAdded(let name, let cfu): return "\(name) (\(cfu) CFU)"
            case .portalUpdated: return "Portale Ateneo aggiornato! 🎓"
            case .portalSaved(let name): return name.isEmpty ? "Link salvato con successo" : name
            case .portalRemoved: return "Link ateneo rimosso"
            }
            
        case .english:
            switch self {
            case .navGeneral: return "GENERAL"
            case .navOverview: return "Overview"
            case .navCalendar: return "Calendar"
            case .navCoursesSection: return "COURSES"
            case .navCourses: return "Courses"
            case .navActivitiesSection: return "ACTIVITIES & DEADLINES"
            case .navDeadlines: return "Deadlines"
            case .navExams: return "Exams"
            case .navAssignments: return "Assignments"
            case .navSettings: return "Settings"
                
            case .quoteTitle: return "DAILY MOTIVATION"
            case .newQuoteAction: return "Next Quote"
                
            case .overviewTitle: return "Overview"
            case .newDeadlineAction: return "New Deadline"
            case .welcomeTitle: return "WELCOME TO UNI"
            case .welcomeSubtitle: return "Start organizing your university journey."
            case .welcomeDesc: return "Add your courses, schedule exams, keep track of deadlines or link your university course calendar feed."
            case .addCourseAction: return "Add Course"
            case .linkCalendarAction: return "Link Calendar (.ics)"
            case .createDeadlineAction: return "Create Deadline"
            case .weightedAverage: return "Weighted GPA"
            case .baseGraduationGrade: return "Graduation estimate"
            case .waitingGrades: return "Awaiting recorded grades"
            case .registeredCredits: return "Earned Credits (CFU)"
            case .pendingExams: return "Remaining Exams"
            case .upToDate: return "All caught up"
            case .todayLectures: return "Today's Lectures"
            case .upcomingDeadlines: return "Upcoming Deadlines"
            case .viewAll: return "View all"
            case .noLecturesToday: return "No lectures scheduled today"
            case .noPendingDeadlines: return "No pending deadlines"
            case .activeDeadlines: return "Active Deadlines"
            case .nextExam: return "Next Exam"
            case .todayAtUni: return "TODAY AT CAMPUS"
            case .activeCourses: return "ACTIVE COURSES"
            case .assignmentsAndFiles: return "ASSIGNMENTS & MAC FILES"
            case .noEventsToday: return "No events today"
            case .noEventsTodayDesc: return "Classes and exam sessions for today will show up here."
            case .noDeadlinesDesc: return "No pending deadlines."
            case .allCount(let count): return "All (\(count))"
                
            case .coursesTitle: return "Courses"
            case .coursesSubtitle: return "Study Plan & Resources"
            case .newCourseAction: return "New Course"
            case .selectCoursePlaceholder: return "Select a course"
            case .selectCourseDesc: return "Class schedules, Notion links, resources, exams and notes."
            case .searchCoursesPlaceholder: return "Search course..."
            case .noCoursesEmptyTitle: return "No courses recorded"
            case .noCoursesEmptyDesc: return "Add your university courses to track university credits, class schedules and notes."
            case .addCourseButton: return "Add Course"
            case .courseCfu(let cfu): return "\(cfu) CFU"
            case .semester(let sem): return "Semester \(sem)"
            case .notionSection: return "NOTION DESKTOP"
            case .openInNotion: return "Open in Notion"
            case .externalLinksSection: return "RESOURCES & EXTERNAL LINKS"
            case .addLinkAction: return "Add Link"
            case .weeklyScheduleSection: return "WEEKLY SCHEDULE"
            case .addScheduleAction: return "Add Time Slot"
                
            case .deadlinesTitle: return "Deadlines"
            case .deadlinesSubtitle(let pending): return "\(pending) pending"
            case .filterAll: return "All"
            case .filterPending: return "Pending"
            case .filterUrgent: return "Urgent"
            case .filterCompleted: return "Completed"
            case .noDeadlinesEmptyTitle: return "No deadlines"
            case .noDeadlinesEmptyDesc: return "Add reminders for coursework, administrative tasks or project submissions."
            case .noMatchingDeadlines: return "No matching deadlines"
                
            case .examsTitle: return "Exams"
            case .examsSubtitle: return "Grade Book & Exam Sessions"
            case .planExamAction: return "Plan Exam"
            case .cfuProgress: return "CFU PROGRESS"
            case .startGrade(let grade): return "Starting grade: ~\(grade)/110"
            case .awaitingExams: return "Awaiting recorded exams"
            case .registerGradeAction: return "Record Grade"
            case .noExamsEmptyTitle: return "No exams recorded"
            case .noExamsEmptyDesc: return "Add exam sessions to compute your weighted GPA and graduation grade forecast."
                
            case .assignmentsTitle: return "Assignments"
            case .assignmentsSubtitle(let inProg, let done): return "\(inProg) in progress • \(done) completed"
            case .newAssignmentAction: return "New Assignment"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .noAssignmentsEmptyTitle: return "No assignments recorded"
            case .noAssignmentsEmptyDesc: return "Add projects, papers or essays and link local files stored on your Mac."
            case .allAssignmentsCompleted: return "All assignments completed"
                
            case .settingsTitle: return "Settings"
            case .settingsSubtitle: return "Customization, Appearance, Language & Data"
            case .themeModeSection: return "SYSTEM THEME"
            case .themeModeSubtitle: return "Choose interface appearance: light theme, dark theme, or automatic sync with macOS."
            case .themeLight: return "Light"
            case .themeDark: return "Dark"
            case .themeSystem: return "Automatic (System)"
            case .languageSection: return "LANGUAGE / LINGUA"
            case .languageSubtitle: return "Choose your preferred interface language."
            case .appearanceSection: return "2-COLOR PALETTE & ACCENT"
            case .accentColorTitle: return "Primary Accent Color"
            case .accentColorSubtitle: return "Customizes the primary accent color across the app: buttons, badges, calendar markers and charts."
            case .presetsTitle: return "Curated Presets"
            case .customQuotesSection: return "HOME MOTIVATIONAL QUOTES"
            case .customQuotesSubtitle: return "Add your own motivational phrases to appear at the top of the dashboard."
            case .addQuotePlaceholder: return "Type a new inspirational quote..."
            case .addQuoteButton: return "Add Quote"
            case .activeQuotesTitle: return "Active Quotes"
            case .typographySection: return "TYPOGRAPHY"
            case .typographyTitle: return "SF Pro (Apple System Style)"
            case .typographySubtitle: return "Native system typography with clean rendering, geometric proportions and high legibility on macOS."
            case .dataManagementSection: return "DATA MANAGEMENT & BACKUP"
            case .dataManagementTitle: return "Local Persistence & Safe Storage"
            case .dataManagementSubtitle: return "All data is securely saved locally on your Mac in JSON format. You can export or restore a backup anytime."
            case .exportBackup: return "Export JSON Backup"
            case .restoreBackup: return "Restore from Backup"
            case .clearAllData: return "Clear All Data"
            case .clearConfirmTitle: return "Delete all data?"
            case .clearConfirmMessage: return "This action will permanently delete all courses, deadlines, exams and assignments. The app will return to a clean state."
            case .cancel: return "Cancel"
            case .delete: return "Delete All"
                
            case .schoolCalendar: return "ACADEMIC CALENDAR"
            case .today: return "Today"
            case .feedTitle: return "Calendar Feed (.ics / webcal)"
            case .feedLastUpdate(let date): return "Last updated: \(date)"
            case .feedNone: return "No feed linked"
            case .syncButton: return "Sync"
            case .syncExportApple: return "Export to Apple Calendar (.ics)"
            case .pasteFeedURL: return "Paste your university calendar feed URL:"
            case .saveAndSync: return "Save & Sync"
            case .chooseICSFile: return "Choose .ics file..."
            case .orUploadICS: return "Or import a downloaded file (.ics):"
            case .dayAgenda: return "DAY AGENDA"
            case .noEventsThisDay: return "No events scheduled for this day"
            
            // Update
            case .updateBannerLabel: return "Update"
            case .updateChangelog: return "What's new:"
            case .updateInstall: return "Install now"
            case .updateInstalling: return "Installing..."
            case .updateDismiss: return "Dismiss"
            
            // Dashboard / portal
            case .universityPortal: return "University Portal"
            case .portalLink: return "Link your university website (portal, schedule, course page) to open it in one click"
            case .portalAccess: return "Quick access to student services and university page"
            case .openPortal: return "Open Portal"
            case .configureLink: return "Configure Link"
            case .editLink: return "Edit"
            case .noCourse: return "No courses"
            case .urgencyHigh(let n): return "\(n) high priority"
            case .noUrgency: return "No urgency"
            
            // Sidebar footer
            case .currentGPA: return "CURRENT GPA"
            case .totalCredits: return "TOTAL CREDITS"
            
            // Timer
            case .focusCompleted: return "Session completed! 🎉"
            case .breakEnded: return "Break ended! ☕️"
            case .greatWork(let name): return "Great work on \(name). Take a well-deserved break."
            case .readyToFocus: return "Ready to get back and study with full focus?"
            
            // Menu commands
            case .syncCalendarCmd: return "Sync Academic Calendar"
            case .exportCalendarCmd: return "Export to Apple Calendar"
            case .calendarSynced: return "Calendar synced"
            case .eventsUpdated(let n): return "\(n) events updated."
            case .calendarExported: return "Calendar exported"
            case .calendarExportedMsg: return ".ics file opened in Apple Calendar"
            
            // Content notifications
            case .deadlineCreated: return "Deadline created"
            case .examScheduled: return "Exam scheduled"
            case .assignmentCreated: return "Assignment created"
            case .courseAdded(let name, let cfu): return "\(name) (\(cfu) CFU)"
            case .portalUpdated: return "University portal updated! 🎓"
            case .portalSaved(let name): return name.isEmpty ? "Link saved successfully" : name
            case .portalRemoved: return "University link removed"
            }
        }
    }
}
