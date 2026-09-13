//
//  uniApp.swift
//  uni
//
//  Created by Francesco Zanchetta on 10/09/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

@main
struct uniApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var quoteManager = QuoteManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var outlookManager = OutlookManager.shared
    @StateObject private var updateManager = UpdateManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
                .environmentObject(quoteManager)
                .environmentObject(notificationManager)
                .environmentObject(outlookManager)
                .environmentObject(updateManager)
                .accentColor(themeManager.accentColor)
                .preferredColorScheme(themeManager.themeMode.colorScheme)
                .frame(minWidth: 960, minHeight: 640)
                .onAppear {
                    themeManager.applyAppearance()
                    #if os(macOS)
                    if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png"),
                       let img = NSImage(contentsOf: iconURL) {
                        NSApplication.shared.applicationIconImage = img
                    } else if let assetIcon = NSImage(named: "AppIcon") {
                        NSApplication.shared.applicationIconImage = assetIcon
                    }
                    #endif
                    notificationManager.requestAuthorization()
                    notificationManager.scheduleAllReminders(
                        deadlines: dataManager.deadlines,
                        exams: dataManager.exams,
                        courses: dataManager.courses,
                        assignments: dataManager.assignments
                    )
                    // Check for updates in the background (once per day)
                    Task { await updateManager.checkForUpdates() }
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                Button(localizationManager.t(.syncCalendarCmd)) {
                    Task {
                        await dataManager.syncCalendarFeed()
                        NotificationManager.shared.notify(
                            title: localizationManager.t(.calendarSynced),
                            message: localizationManager.t(.eventsUpdated(dataManager.syncedEvents.count)),
                            type: .success,
                            icon: "calendar.badge.clock"
                        )
                    }
                }
                .keyboardShortcut("r", modifiers: [.command])
                
                Button(localizationManager.t(.exportCalendarCmd)) {
                    dataManager.exportToAppleCalendar()
                    NotificationManager.shared.notify(
                        title: localizationManager.t(.calendarExported),
                        message: localizationManager.t(.calendarExportedMsg),
                        type: .info,
                        icon: "calendar"
                    )
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }
        
        // MenuBar Extra per macOS (Stato rapido nella barra dei menu)
        MenuBarExtra("uni", systemImage: "graduationcap") {
            MenuBarQuickView()
                .environmentObject(dataManager)
                .environmentObject(themeManager)
        }
        .menuBarExtraStyle(.menu)
    }
}

// MARK: - Menu Bar Quick Glance Menu
struct MenuBarQuickView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var lm = LocalizationManager.shared
    
    var body: some View {
        VStack {
            Text("uni • " + lm.text(it: "Statistiche Studente", en: "Student Stats"))
            
            if dataManager.weightedAverage > 0 {
                Text(lm.text(it: "Media", en: "GPA") + ": \(String(format: "%.2f", dataManager.weightedAverage)) • CFU: \(dataManager.totalCfuAcquired)/\(dataManager.totalCfuTarget)")
            }
            
            Divider()
            
            let pending = dataManager.deadlines.filter { !$0.isCompleted }.prefix(4)
            if pending.isEmpty {
                Text(lm.t(.noPendingDeadlines))
            } else {
                Text(lm.t(.upcomingDeadlines) + ":")
                ForEach(Array(pending)) { d in
                    Text("• \(d.title)")
                }
            }
            
            Divider()
            
            Button(lm.text(it: "Apri uni", en: "Open uni")) {
                #if canImport(AppKit)
                NSApp.activate(ignoringOtherApps: true)
                for window in NSApp.windows where !(window is NSPanel) {
                    window.makeKeyAndOrderFront(nil)
                }
                #endif
            }
            
            Button(lm.t(.syncCalendarCmd)) {
                Task {
                    await dataManager.syncCalendarFeed()
                }
            }
            
            Divider()
            
            Button(lm.text(it: "Esci da uni", en: "Quit uni")) {
                #if canImport(AppKit)
                NSApp.terminate(nil)
                #endif
            }
        }
    }
}
