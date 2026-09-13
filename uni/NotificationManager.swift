//
//  NotificationManager.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
//

import SwiftUI
import Combine
import UserNotifications
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Toast Item Model
public struct ToastItem: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let message: String?
    public let type: ToastType
    public let icon: String
    public let timestamp: Date
    
    public enum ToastType: Equatable {
        case info
        case success
        case warning
        case alert
        case custom(Color)
        
        public var color: Color {
            switch self {
            case .info: return Color.blue
            case .success: return Color.green
            case .warning: return Color.orange
            case .alert: return Color.red
            case .custom(let color): return color
            }
        }
        
        public var defaultIcon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .alert: return "xmark.octagon.fill"
            case .custom: return "bell.badge.fill"
            }
        }
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        message: String? = nil,
        type: ToastType = .info,
        icon: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.icon = icon ?? type.defaultIcon
        self.timestamp = timestamp
    }
}

// MARK: - Notification Manager
public class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    // In-App Toast HUD State
    @Published public var currentToast: ToastItem? = nil
    private var toastDismissTask: Task<Void, Never>? = nil
    
    // Preferences (Stored in UserDefaults)
    @Published public var systemNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(systemNotificationsEnabled, forKey: "uni_system_notifs_enabled")
            if systemNotificationsEnabled {
                requestAuthorization()
            }
        }
    }
    
    @Published public var inAppToastsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(inAppToastsEnabled, forKey: "uni_inapp_toasts_enabled")
        }
    }
    
    @Published public var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "uni_notif_sound_enabled")
        }
    }
    
    @Published public var notify24hBefore: Bool {
        didSet {
            UserDefaults.standard.set(notify24hBefore, forKey: "uni_notif_24h_before")
        }
    }
    
    @Published public var notify1hBefore: Bool {
        didSet {
            UserDefaults.standard.set(notify1hBefore, forKey: "uni_notif_1h_before")
        }
    }
    
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private override init() {
        self.systemNotificationsEnabled = UserDefaults.standard.object(forKey: "uni_system_notifs_enabled") as? Bool ?? true
        self.inAppToastsEnabled = UserDefaults.standard.object(forKey: "uni_inapp_toasts_enabled") as? Bool ?? true
        self.soundEnabled = UserDefaults.standard.object(forKey: "uni_notif_sound_enabled") as? Bool ?? true
        self.notify24hBefore = UserDefaults.standard.object(forKey: "uni_notif_24h_before") as? Bool ?? true
        self.notify1hBefore = UserDefaults.standard.object(forKey: "uni_notif_1h_before") as? Bool ?? true
        
        super.init()
        
        UNUserNotificationCenter.current().delegate = self
        checkAuthorization()
    }
    
    // MARK: - Authorization
    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.checkAuthorization()
                if let error = error {
                    print("Errore autorizzazione notifiche macOS: \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // UNUserNotificationCenterDelegate: Permette di mostrare la notifica di sistema anche con l'app in primo piano
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: - Trigger Notifications (Both In-App & System)
    
    /// Mostra notifica carina sia in-app (Toast HUD) che nel Centro Notifiche di macOS
    public func notify(
        title: String,
        message: String? = nil,
        type: ToastItem.ToastType = .info,
        icon: String? = nil,
        postToSystem: Bool = true
    ) {
        // 1. In-App Toast HUD
        if inAppToastsEnabled {
            showToast(title: title, message: message, type: type, icon: icon)
        }
        
        // 2. macOS System Notification
        if postToSystem && systemNotificationsEnabled {
            postSystemNotification(
                title: title,
                body: message ?? "",
                sound: soundEnabled
            )
        }
    }
    
    // MARK: - In-App Toast Display
    public func showToast(
        title: String,
        message: String? = nil,
        type: ToastItem.ToastType = .info,
        icon: String? = nil,
        duration: Double = 3.5
    ) {
        DispatchQueue.main.async {
            self.toastDismissTask?.cancel()
            
            SoundManager.shared.play(.notification)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                self.currentToast = ToastItem(
                    title: title,
                    message: message,
                    type: type,
                    icon: icon
                )
            }
            
            // Auto dismiss timer
            self.toastDismissTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                if !Task.isCancelled {
                    withAnimation(.easeOut(duration: 0.25)) {
                        self.currentToast = nil
                    }
                }
            }
        }
    }
    
    public func dismissToast() {
        toastDismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            currentToast = nil
        }
    }
    
    // MARK: - macOS Native System Notification Center
    public func postSystemNotification(
        title: String,
        subtitle: String? = nil,
        body: String,
        sound: Bool = true,
        identifier: String = UUID().uuidString
    ) {
        guard systemNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        if let sub = subtitle, !sub.isEmpty {
            content.subtitle = sub
        }
        content.body = body
        if sound && soundEnabled {
            content.sound = .default
        }
        
        // Trigger immediato (dopo 0.1s per non bloccare il runloop)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore invio notifica di sistema macOS: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Automatic Deadline & Assignment Reminders Scheduler
    public func scheduleAllReminders(
        deadlines: [Deadline],
        exams: [Exam],
        courses: [Course],
        assignments: [Assignment] = []
    ) {
        guard systemNotificationsEnabled else { return }
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let now = Date()
        let courseDict = Dictionary(uniqueKeysWithValues: courses.map { ($0.id, $0.name) })
        
        // 1. Programma notifiche per Scadenze
        for deadline in deadlines where !deadline.isCompleted {
            let courseName = deadline.courseId.flatMap { courseDict[$0] } ?? "Materia"
            
            // 24 Ore Prima
            if notify24hBefore {
                let triggerDate24h = deadline.dueDate.addingTimeInterval(-86400)
                if triggerDate24h > now {
                    scheduleSingleReminder(
                        id: "deadline-24h-\(deadline.id.uuidString)",
                        title: "Scadenza domani: \(deadline.title)",
                        body: "Corso: \(courseName) • Ricordati di completare l'attività.",
                        date: triggerDate24h
                    )
                }
            }
            
            // 1 Ora Prima
            if notify1hBefore {
                let triggerDate1h = deadline.dueDate.addingTimeInterval(-3600)
                if triggerDate1h > now {
                    scheduleSingleReminder(
                        id: "deadline-1h-\(deadline.id.uuidString)",
                        title: "Scadenza imminente (1 ora): \(deadline.title)",
                        body: "Corso: \(courseName) • Scade alle \(DateFormatter.timeOnly.string(from: deadline.dueDate))",
                        date: triggerDate1h
                    )
                }
            }
            
            // All'ora esatta della scadenza
            if deadline.dueDate > now {
                scheduleSingleReminder(
                    id: "deadline-exact-\(deadline.id.uuidString)",
                    title: "Scadenza ORA: \(deadline.title)",
                    body: "Corso: \(courseName) • Termine scaduto alle \(DateFormatter.timeOnly.string(from: deadline.dueDate))",
                    date: deadline.dueDate
                )
            }
        }
        
        // 2. Programma notifiche per Assignments (Compiti / Consegne)
        for assignment in assignments where !assignment.isCompleted {
            let courseName = courseDict[assignment.courseId] ?? "Materia"
            
            // 24 Ore Prima
            if notify24hBefore {
                let triggerDate24h = assignment.dueDate.addingTimeInterval(-86400)
                if triggerDate24h > now {
                    scheduleSingleReminder(
                        id: "assignment-24h-\(assignment.id.uuidString)",
                        title: "Consegna domani: \(assignment.title)",
                        body: "Corso: \(courseName) • Verifica di aver caricato tutti i file.",
                        date: triggerDate24h
                    )
                }
            }
            
            // 1 Ora Prima
            if notify1hBefore {
                let triggerDate1h = assignment.dueDate.addingTimeInterval(-3600)
                if triggerDate1h > now {
                    scheduleSingleReminder(
                        id: "assignment-1h-\(assignment.id.uuidString)",
                        title: "Consegna tra 1 ora: \(assignment.title)",
                        body: "Corso: \(courseName) • Scadenza alle \(DateFormatter.timeOnly.string(from: assignment.dueDate))",
                        date: triggerDate1h
                    )
                }
            }
            
            if assignment.dueDate > now {
                scheduleSingleReminder(
                    id: "assignment-exact-\(assignment.id.uuidString)",
                    title: "Termine consegna: \(assignment.title)",
                    body: "Corso: \(courseName) • Ultimi minuti per la consegna!",
                    date: assignment.dueDate
                )
            }
        }
        
        // 3. Programma notifiche per Esami
        for exam in exams where exam.status != .passed {
            let courseName = courseDict[exam.courseId] ?? "Esame"
            
            // 2 Giorni Prima dell'esame
            let triggerDate2d = exam.examDate.addingTimeInterval(-172800)
            if triggerDate2d > now {
                scheduleSingleReminder(
                    id: "exam-2d-\(exam.id.uuidString)",
                    title: "Esame tra 2 giorni: \(exam.title)",
                    body: "\(courseName) • Ultimo ripasso prima dell'appello!",
                    date: triggerDate2d
                )
            }
            
            // Mattina dell'esame (ore 07:30)
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: exam.examDate)
            components.hour = 7
            components.minute = 30
            if let morningDate = calendar.date(from: components), morningDate > now && morningDate <= exam.examDate {
                scheduleSingleReminder(
                    id: "exam-morning-\(exam.id.uuidString)",
                    title: "Oggi c'è l'esame di \(courseName)! 🎓",
                    body: "\(exam.title) alle ore \(DateFormatter.timeOnly.string(from: exam.examDate)) in aula \(exam.room.isEmpty ? "assegnata" : exam.room). In bocca al lupo!",
                    date: morningDate
                )
            }
        }
    }
    
    private func scheduleSingleReminder(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if soundEnabled {
            content.sound = .default
        }
        
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore programmazione promemoria: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - DateFormatter Helper
private extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.timeZone = TimeZone(identifier: "Europe/Rome") ?? TimeZone.current
        f.dateFormat = "HH:mm"
        return f
    }()
}


// MARK: - Floating In-App Toast View HUD (Pill-shaped Dynamic Island style with 100% opaque solid background)
public struct ToastHUDView: View {
    let toast: ToastItem
    var onDismiss: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovering = false
    
    public var body: some View {
        HStack(spacing: 12) {
            // Icona Badge Circolare
            ZStack {
                Circle()
                    .fill(toast.type.color.opacity(0.18))
                    .frame(width: 30, height: 30)
                
                Image(systemName: toast.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(toast.type.color)
            }
            
            // Testo Notifica
            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(UniFont.headline())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                if let message = toast.message, !message.isEmpty {
                    Text(message)
                        .font(UniFont.subheadline())
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer(minLength: 10)
            
            // Tasto Chiudi
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(Color.primary.opacity(isHovering ? 0.12 : 0.05))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Chiudi notifica")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(solidOpaqueBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.38 : 0.14), radius: 16, x: 0, y: 7)
                .shadow(color: toast.type.color.opacity(0.18), radius: 5, x: 0, y: 1)
        )
        .overlay(
            Capsule()
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .clipShape(Capsule())
        .frame(maxWidth: 440)
        .padding(.top, 14)
        .onHover { isHovering = $0 }
    }
    
    private var solidOpaqueBackground: Color {
        #if canImport(AppKit)
        if colorScheme == .dark {
            return Color(red: 0.13, green: 0.13, blue: 0.15) // Sfondo 100% opaco solido dark
        } else {
            return Color.white // Sfondo 100% opaco solido bianco
        }
        #else
        return colorScheme == .dark ? Color(red: 0.13, green: 0.13, blue: 0.15) : Color.white
        #endif
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.08)
    }
}

// MARK: - Toast View Modifier
public struct ToastModifier: ViewModifier {
    @ObservedObject var notificationManager = NotificationManager.shared
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if let toast = notificationManager.currentToast {
                ToastHUDView(toast: toast) {
                    notificationManager.dismissToast()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 0.9))
                ))
                .zIndex(9999)
            }
        }
    }
}

public extension View {
    func toastHUD() -> some View {
        self.modifier(ToastModifier())
    }
}
