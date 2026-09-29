//
//  CalendarManagerModalView.swift
//  uni
//
//  Created by zinco.cc on 28/09/2026.
//

import SwiftUI
import UniformTypeIdentifiers
import EventKit
#if canImport(AppKit)
import AppKit
#endif

public struct CalendarManagerModalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    // Tab 0 = Replica dal PC (default), Tab 1 = Nuovo Feed iCal, Tab 2 = Calendari Connessi
    @State private var selectedTab: Int = 0
    
    // Nuovo Feed Form
    @State private var newFeedTitle: String = ""
    @State private var newFeedURL: String = ""
    @State private var newFeedIsAcademic: Bool = true
    @State private var newFeedColorHex: String = "#4F46E5"
    @State private var isAddingFeed: Bool = false
    
    // Calendari PC rilevati
    @State private var availablePCCalendars: [AppleCalendarManager.MacCalendarInfo] = []
    @State private var isReplicatingPC: Bool = false
    @State private var pcAuthStatus: String = ""
    
    private let colorPalette: [String] = [
        "#4F46E5", // Indigo
        "#2563EB", // Blue
        "#0D9488", // Teal
        "#10B981", // Emerald
        "#F59E0B", // Amber
        "#EF4444", // Red
        "#8B5CF6", // Purple
        "#EC4899"  // Pink
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header del Modal
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(localizationManager.text(it: "Gestione Calendari & Sincronizzazione", en: "Calendar Management & Sync"))
                        .font(UniFont.title())
                        .fontWeight(.bold)
                    
                    Text(localizationManager.text(
                        it: "Collega molteplici feed iCal (.ics, webcal://) o replica i calendari del tuo PC.",
                        en: "Connect multiple iCal feeds (.ics, webcal://) or replicate your PC's calendars."
                    ))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .padding(.bottom, 16)
            
            // Picker Tab Superiore (Senza Emojis e con Replica dal PC come prima tab)
            Picker("", selection: $selectedTab) {
                Text(localizationManager.text(
                    it: "Replica dal PC",
                    en: "Replicate from PC"
                )).tag(0)
                
                Text(localizationManager.text(
                    it: "Aggiungi Feed iCal",
                    en: "Add iCal Feed"
                )).tag(1)
                
                Text(localizationManager.text(
                    it: "Calendari Connessi (\(dataManager.calendarSources.count))",
                    en: "Connected Calendars (\(dataManager.calendarSources.count))"
                )).tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
            
            Divider()
            
            // Contenuto Tabs
            ScrollView {
                VStack(spacing: 18) {
                    if selectedTab == 0 {
                        pcReplicateTab
                    } else if selectedTab == 1 {
                        newFeedTab
                    } else {
                        connectedCalendarsTab
                    }
                }
                .padding(24)
            }
            
            Divider()
            
            // Footer con stato sync e pulsante chiudi
            HStack(spacing: 12) {
                if dataManager.isSyncingCalendar {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(localizationManager.text(it: "Sincronizzazione calendari in corso...", en: "Syncing calendars..."))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                } else if let success = dataManager.syncSuccessMessage {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(success)
                        .font(UniFont.caption())
                        .foregroundStyle(.green)
                        .lineLimit(1)
                } else if let err = dataManager.syncErrorMessage {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(err)
                        .font(UniFont.caption())
                        .foregroundStyle(.red)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(localizationManager.text(it: "Chiudi", en: "Close")) {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.primary.opacity(0.02))
        }
        .frame(minWidth: 640, maxWidth: 740, minHeight: 480, maxHeight: 600)
        .onAppear {
            refreshPCCalendarsList()
        }
    }
    
    // MARK: - Tab 0: Replica dal PC
    private var pcReplicateTab: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Hero Card Replica Totale con 1 Click
            UniCard(padding: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "desktopcomputer.and.arrow.down")
                            .font(.system(size: 28))
                            .foregroundStyle(themeManager.accentColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(localizationManager.text(it: "Replica Tutti i Calendari del PC", en: "Replicate All PC Calendars"))
                                .font(UniFont.headline())
                            
                            Text(localizationManager.text(
                                it: "Sincronizza in un istante tutti i calendari e account configurati su questo PC (iCloud, Google, Exchange, Personale, Lavoro).",
                                en: "Instantly replicate all calendars configured on this PC (iCloud, Google, Exchange, Personal, Work)."
                            ))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            replicateAllPC()
                        } label: {
                            HStack(spacing: 6) {
                                if isReplicatingPC {
                                    ProgressView().scaleEffect(0.7)
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                }
                                Text(localizationManager.text(it: "Replica Tutti con 1 Click", en: "Replicate All with 1-Click"))
                            }
                            .padding(.horizontal, 6)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isReplicatingPC)
                    }
                }
            }
            
            // Elenco dei calendari PC rilevati
            Text(localizationManager.text(it: "Calendari Rilevati sul tuo PC", en: "Calendars Found on your PC"))
                .font(UniFont.headline())
            
            if availablePCCalendars.isEmpty {
                VStack(spacing: 8) {
                    Text(localizationManager.text(
                        it: "Nessun calendario rilevato o autorizzazione necessaria.",
                        en: "No calendars detected or permission required."
                    ))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    
                    Button(localizationManager.text(it: "Richiedi Accesso Calendari PC", en: "Request PC Calendar Access")) {
                        Task {
                            _ = await AppleCalendarManager.shared.requestAccess()
                            refreshPCCalendarsList()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(availablePCCalendars) { pcCal in
                    pcCalendarRow(pcCal)
                }
            }
        }
    }
    
    private func pcCalendarRow(_ pcCal: AppleCalendarManager.MacCalendarInfo) -> some View {
        let isAlreadyConnected = dataManager.calendarSources.contains(where: { $0.appleCalendarIdentifier == pcCal.id })
        
        return UniCard(padding: 10) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: pcCal.colorHex) ?? .blue)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(pcCal.title)
                        .font(UniFont.body())
                        .fontWeight(.medium)
                    
                    Text("\(pcCal.sourceTitle) • \(pcCal.isAcademic ? localizationManager.text(it: "Scolastico", en: "Academic") : localizationManager.text(it: "Personale", en: "Personal"))")
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isAlreadyConnected {
                    UniBadge(localizationManager.text(it: "Collegato", en: "Connected"), color: .green)
                } else {
                    Button {
                        connectSinglePCCalendar(pcCal)
                    } label: {
                        Text(localizationManager.text(it: "Collega", en: "Connect"))
                            .font(UniFont.caption())
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - Tab 1: Nuovo Feed iCal
    private var newFeedTab: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(localizationManager.text(it: "Aggiungi un Feed iCal o Webcal", en: "Add an iCal or Webcal Feed"))
                .font(UniFont.headline())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(localizationManager.text(it: "Nome del Calendario", en: "Calendar Name"))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                
                TextField(localizationManager.text(it: "es. Orario Lezioni Ingegneria", en: "e.g. Computer Science Schedule"), text: $newFeedTitle)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(localizationManager.text(it: "URL Feed (.ics o webcal://)", en: "Feed URL (.ics or webcal://)"))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                
                TextField("https://.../calendario.ics oppure webcal://...", text: $newFeedURL)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Switch Scolastico / Personale
            Toggle(isOn: $newFeedIsAcademic) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Calendario Scolastico / Universitario", en: "Academic / University Calendar"))
                        .font(UniFont.body())
                        .fontWeight(.medium)
                    
                    Text(localizationManager.text(
                        it: "Se attivo, uni estrarrà automaticamente i corsi e mostrerà le lezioni nella dashboard e negli orari di studio.",
                        en: "If active, uni extracts course subjects and displays lecture times on your dashboard."
                    ))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.checkbox)
            
            // Scelta Colore
            VStack(alignment: .leading, spacing: 8) {
                Text(localizationManager.text(it: "Colore di Riconoscimento", en: "Color Tag"))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(colorPalette, id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex) ?? .blue)
                            .frame(width: 26, height: 26)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: newFeedColorHex == hex ? 2.5 : 0)
                            )
                            .onTapGesture {
                                newFeedColorHex = hex
                            }
                    }
                }
            }
            
            Button {
                addNewFeed()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text(localizationManager.text(it: "Aggiungi e Sincronizza Feed", en: "Add & Sync Feed"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .disabled(newFeedURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Divider()
                .padding(.vertical, 6)
            
            // Importa File .ics locale
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Hai un file .ics salvato sul PC?", en: "Have a local .ics file on your PC?"))
                        .font(UniFont.body())
                        .fontWeight(.medium)
                    Text(localizationManager.text(it: "Puoi importare direttamente un file di calendario dal tuo computer.", en: "You can import a calendar file directly from your computer."))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    selectLocalICSFile()
                } label: {
                    Label(localizationManager.text(it: "Sfoglia file .ics...", en: "Browse .ics file..."), systemImage: "doc.badge.plus")
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    // MARK: - Tab 2: Calendari Connessi
    private var connectedCalendarsTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            if dataManager.calendarSources.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(themeManager.accentColor.opacity(0.8))
                        .padding(.top, 20)
                    
                    Text(localizationManager.text(it: "Nessun calendario collegato", en: "No connected calendars"))
                        .font(UniFont.headline())
                    
                    Text(localizationManager.text(
                        it: "Collega il feed iCal delle tue lezioni universitarie o replica con un click tutti i calendari del tuo PC per avere tutto sotto controllo.",
                        en: "Connect your university iCal feed or replicate all PC calendars in one click to stay organized."
                    ))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
                    
                    HStack(spacing: 12) {
                        Button {
                            selectedTab = 0
                        } label: {
                            Label(localizationManager.text(it: "Replica dal PC", en: "Replicate from PC"), systemImage: "desktopcomputer")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            selectedTab = 1
                        } label: {
                            Label(localizationManager.text(it: "Aggiungi Feed iCal", en: "Add iCal Feed"), systemImage: "link")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.primary.opacity(0.02))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                HStack {
                    Text(localizationManager.text(
                        it: "\(dataManager.calendarSources.count) calendari configurati",
                        en: "\(dataManager.calendarSources.count) calendars configured"
                    ))
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            await dataManager.syncAllCalendars()
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.clockwise")
                            Text(localizationManager.text(it: "Sincronizza Tutti Ora", en: "Sync All Now"))
                        }
                        .font(UniFont.caption())
                    }
                    .buttonStyle(.bordered)
                    .disabled(dataManager.isSyncingCalendar)
                }
                
                ForEach(dataManager.calendarSources) { source in
                    calendarSourceRow(source)
                }
            }
        }
    }
    
    private func calendarSourceRow(_ source: CalendarSource) -> some View {
        UniCard(padding: 12) {
            HStack(spacing: 12) {
                // Indicatore Colore
                Circle()
                    .fill(Color(hex: source.colorHex) ?? themeManager.accentColor)
                    .frame(width: 14, height: 14)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(source.title)
                            .font(UniFont.body())
                            .fontWeight(.medium)
                            .foregroundStyle(source.isEnabled ? .primary : .secondary)
                        
                        // Badge Scolastico / Non Scolastico (Senza Emoji, usa icone SF Symbol)
                        Button {
                            dataManager.toggleSourceAcademic(id: source.id)
                        } label: {
                            HStack(spacing: 3) {
                                Image(systemName: source.isAcademic ? "graduationcap.fill" : "person.fill")
                                Text(source.isAcademic
                                     ? localizationManager.text(it: "Scolastico", en: "Academic")
                                     : localizationManager.text(it: "Personale", en: "Personal"))
                            }
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(source.isAcademic ? themeManager.accentColor.opacity(0.15) : Color.purple.opacity(0.15))
                            .foregroundStyle(source.isAcademic ? themeManager.accentColor : Color.purple)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Clicca per cambiare tra evento scolastico ed extra-scolastico", en: "Click to toggle between academic and personal"))
                    }
                    
                    HStack(spacing: 8) {
                        Label(source.sourceType.localizedTitle(using: localizationManager), systemImage: source.sourceType.icon)
                        
                        if source.eventCount > 0 {
                            Text("• \(source.eventCount) " + localizationManager.text(it: "eventi", en: "events"))
                        }
                        
                        if let lastSync = source.lastSyncDate {
                            Text("• " + formatSyncDate(lastSync))
                        }
                    }
                    .font(UniFont.caption())
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Toggle Attivo / Disattivo
                Toggle("", isOn: Binding(
                    get: { source.isEnabled },
                    set: { _ in dataManager.toggleCalendarSource(id: source.id) }
                ))
                .labelsHidden()
                .toggleStyle(.switch)
                .scaleEffect(0.8)
                .help(localizationManager.text(it: "Mostra o nascondi gli eventi di questo calendario", en: "Toggle calendar visibility"))
                
                // Pulsante Elimina
                Button {
                    dataManager.removeCalendarSource(id: source.id)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundStyle(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Rimuovi questo calendario", en: "Remove this calendar"))
                .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - Actions
    private func addNewFeed() {
        let trimmed = newFeedURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let title = newFeedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? (newFeedIsAcademic ? localizationManager.text(it: "Calendario Corsi", en: "Courses Calendar") : localizationManager.text(it: "Calendario Personale", en: "Personal Calendar"))
            : newFeedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        dataManager.addCalendarSource(
            title: title,
            url: trimmed,
            colorHex: newFeedColorHex,
            isAcademic: newFeedIsAcademic,
            sourceType: .webcal
        )
        
        newFeedTitle = ""
        newFeedURL = ""
        selectedTab = 2
        
        Task {
            await dataManager.syncAllCalendars()
        }
    }
    
    private func selectLocalICSFile() {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.init(filenameExtension: "ics") ?? .text]
        panel.prompt = localizationManager.text(it: "Importa Calendario", en: "Import Calendar")
        
        if panel.runModal() == .OK, let selectedURL = panel.url {
            dataManager.importICSFromFile(url: selectedURL)
            selectedTab = 2
        }
        #endif
    }
    
    private func refreshPCCalendarsList() {
        Task {
            AppleCalendarManager.shared.refreshStatus()
            if AppleCalendarManager.shared.hasFullAccess {
                self.availablePCCalendars = AppleCalendarManager.shared.getAvailableMacCalendars()
            }
        }
    }
    
    private func replicateAllPC() {
        isReplicatingPC = true
        Task {
            _ = await dataManager.importAllMacCalendars()
            refreshPCCalendarsList()
            isReplicatingPC = false
            selectedTab = 2
        }
    }
    
    private func connectSinglePCCalendar(_ pcCal: AppleCalendarManager.MacCalendarInfo) {
        dataManager.addCalendarSource(
            title: "\(pcCal.title) (\(pcCal.sourceTitle))",
            url: "",
            colorHex: pcCal.colorHex,
            isAcademic: pcCal.isAcademic,
            sourceType: .appleCalendar,
            appleCalendarIdentifier: pcCal.id
        )
        refreshPCCalendarsList()
        selectedTab = 2
        Task {
            await dataManager.syncAllCalendars()
        }
    }
    
    private static let syncDateFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "d MMM HH:mm"
        return f
    }()
    
    private static let syncDateFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "d MMM HH:mm"
        return f
    }()
    
    private func formatSyncDate(_ date: Date) -> String {
        let f = localizationManager.currentLanguage == .italian ? Self.syncDateFormatterIT : Self.syncDateFormatterEN
        return f.string(from: date)
    }
}
