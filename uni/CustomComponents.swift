//
//  CustomComponents.swift
//  uni
//
//  Created by zinco.cc on 02/10/2026.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif
import UniformTypeIdentifiers

// MARK: - Reusable Folder & File Drag & Drop Link Field
public struct UniFolderDropZoneView: View {
    @Binding var localFilePath: String?
    @Binding var localFileName: String?
    var label: String = "Cartella o File Collegato"
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var isDropTargeted: Bool = false
    @State private var isHovered: Bool = false
    
    private var isDarkMode: Bool {
        if themeManager.themeMode == .dark { return true }
        if themeManager.themeMode == .light { return false }
        return systemColorScheme == .dark
    }
    
    public init(
        localFilePath: Binding<String?>,
        localFileName: Binding<String?>,
        label: String = "Cartella o File Collegato"
    ) {
        self._localFilePath = localFilePath
        self._localFileName = localFileName
        self.label = label
    }
    
    private var isLinked: Bool {
        guard let p = localFilePath?.trimmingCharacters(in: .whitespacesAndNewlines), !p.isEmpty else {
            return false
        }
        return true
    }
    
    private var isDirectory: Bool {
        guard let path = localFilePath else { return false }
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(UniFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if isLinked {
                    Button {
                        browseFolderOrFile()
                    } label: {
                        Text(localizationManager.text(it: "Cambia", en: "Change"))
                            .font(UniFont.caption())
                            .foregroundStyle(themeManager.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if let path = localFilePath, !path.isEmpty {
                // Linked State Card
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(themeManager.accentColor.opacity(0.12))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: isDirectory ? "folder.fill" : "doc.text.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(themeManager.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localFileName ?? URL(fileURLWithPath: path).lastPathComponent)
                            .font(UniFont.body())
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                        
                        Text(path)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        // Reveal in Finder button
                        Button {
                            AppSystemHelper.revealInFinder(path: path)
                        } label: {
                            Image(systemName: "folder")
                                .font(.system(size: 12))
                                .padding(6)
                                .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Mostra nel Finder", en: "Reveal in Finder"))
                        
                        // Open file/folder
                        Button {
                            AppSystemHelper.openLocalFile(path: path)
                        } label: {
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 12))
                                .padding(6)
                                .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Apri cartella o file", en: "Open folder or file"))
                        
                        // Remove link
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                localFilePath = nil
                                localFileName = nil
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .padding(6)
                                .background(Color.red.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                        .help(localizationManager.text(it: "Scollega", en: "Unlink"))
                    }
                }
                .padding(10)
                .background(isDarkMode ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isDarkMode ? Color.white.opacity(0.10) : Color.black.opacity(0.08), lineWidth: 1)
                )
            } else {
                // Empty Dropzone
                Button {
                    browseFolderOrFile()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: isDropTargeted ? "arrow.down.doc.fill" : "folder.badge.plus")
                            .font(.system(size: 24))
                            .foregroundStyle(isDropTargeted ? themeManager.accentColor : .secondary)
                            .scaleEffect(isDropTargeted ? 1.15 : 1.0)
                        
                        VStack(spacing: 2) {
                            Text(isDropTargeted ? localizationManager.text(it: "Rilascia per collegare!", en: "Drop to link!") : localizationManager.text(it: "Trascina qui una cartella o file dal Finder", en: "Drag & drop a folder or file from Finder"))
                                .font(UniFont.body())
                                .fontWeight(.medium)
                                .foregroundStyle(isDropTargeted ? themeManager.accentColor : .primary)
                            
                            Text(localizationManager.text(it: "oppure clicca per sfogliare dal Mac", en: "or click to browse from Mac"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .padding(.horizontal, 16)
                    .background(isDropTargeted ? themeManager.accentColor.opacity(0.08) : (isDarkMode ? Color.white.opacity(0.03) : Color.black.opacity(0.02)))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                isDropTargeted ? themeManager.accentColor : (isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.12)),
                                style: StrokeStyle(lineWidth: isDropTargeted ? 2 : 1.2, dash: [5, 4])
                            )
                    )
                }
                .buttonStyle(.plain)
                .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                    handleDrop(providers: providers)
                }
            }
        }
    }
    
    private func browseFolderOrFile() {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.prompt = localizationManager.text(it: "Collega", en: "Link")
        panel.message = localizationManager.text(it: "Seleziona una cartella o file da collegare", en: "Select a folder or file to link")
        
        if panel.runModal() == .OK, let url = panel.url {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                self.localFilePath = url.path
                self.localFileName = url.lastPathComponent
            }
        }
        #endif
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            var targetURL: URL? = nil
            if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                targetURL = url
            } else if let url = item as? URL {
                targetURL = url
            }
            
            if let url = targetURL {
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        self.localFilePath = url.path
                        self.localFileName = url.lastPathComponent
                    }
                }
            }
        }
        return true
    }
}

// MARK: - Custom Editorial Date and Hour Picker
public struct UniCustomDateTimePicker: View {
    @Binding var selectedDate: Date
    var label: String = "Data e Ora"
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var isShowingPickerModal: Bool = false
    @State private var isHovered: Bool = false
    
    private var isDarkMode: Bool {
        if themeManager.themeMode == .dark { return true }
        if themeManager.themeMode == .light { return false }
        return systemColorScheme == .dark
    }
    
    public init(
        selectedDate: Binding<Date>,
        label: String = "Data e Ora"
    ) {
        self._selectedDate = selectedDate
        self.label = label
    }
    
    private var formattedDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: localizationManager.currentLanguage == .italian ? "it_IT" : "en_US")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f.string(from: selectedDate).capitalized
    }
    
    private var formattedTimeString: String {
        localizationManager.formatTime(selectedDate)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(UniFont.caption())
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            // Custom Trigger Field
            Button {
                isShowingPickerModal.toggle()
            } label: {
                HStack(spacing: 12) {
                    // Date display
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13))
                            .foregroundStyle(themeManager.accentColor)
                        
                        Text(formattedDateString)
                            .font(UniFont.body())
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    // Time display
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        
                        Text(formattedTimeString)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(themeManager.accentColor)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isDarkMode ? Color.white.opacity(0.12) : Color.black.opacity(0.08), lineWidth: 1)
                )
                .opacity(isHovered ? 0.70 : 1.0)
            }
            .buttonStyle(.plain)
            .onHover { h in
                withAnimation(.easeInOut(duration: 0.15)) { isHovered = h }
            }
            .popover(isPresented: $isShowingPickerModal, arrowEdge: .bottom) {
                UniCustomDatePickerPopoverContent(
                    date: $selectedDate,
                    isPresented: $isShowingPickerModal
                )
                .environmentObject(themeManager)
                .environmentObject(localizationManager)
            }
        }
    }
}

// MARK: - Popover Content for Custom Date and Hour Picker
struct UniCustomDatePickerPopoverContent: View {
    @Binding var date: Date
    @Binding var isPresented: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var workingMonth: Date = Date()
    @State private var selectedHour: Int = 18
    @State private var selectedMinute: Int = 0
    
    private let calendar = Calendar.current
    
    private var isDarkMode: Bool {
        if themeManager.themeMode == .dark { return true }
        if themeManager.themeMode == .light { return false }
        return systemColorScheme == .dark
    }
    
    init(date: Binding<Date>, isPresented: Binding<Bool>) {
        self._date = date
        self._isPresented = isPresented
        let cal = Calendar.current
        _workingMonth = State(initialValue: date.wrappedValue)
        _selectedHour = State(initialValue: cal.component(.hour, from: date.wrappedValue))
        _selectedMinute = State(initialValue: cal.component(.minute, from: date.wrappedValue))
    }
    
    private var monthYearTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: localizationManager.currentLanguage == .italian ? "it_IT" : "en_US")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: workingMonth).capitalized
    }
    
    private var currentPreviewTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: localizationManager.currentLanguage == .italian ? "it_IT" : "en_US")
        f.dateFormat = localizationManager.currentLanguage == .italian ? "EEE d MMM, HH:mm" : "EEE, MMM d, h:mm a"
        return f.string(from: date).capitalized
    }
    
    var body: some View {
        VStack(spacing: 14) {
            // Header with current preview and Close
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "IMPOSTA DATA & ORA", en: "SET DATE & TIME").uppercased())
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundStyle(themeManager.accentColor)
                    
                    Text(currentPreviewTitle)
                        .font(UniFont.headline())
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .padding(6)
                        .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 2)
            
            // Quick Presets Bar
            HStack(spacing: 6) {
                presetChip(title: localizationManager.text(it: "Oggi", en: "Today"), daysAhead: 0, hour: 18)
                presetChip(title: localizationManager.text(it: "Domani", en: "Tomorrow"), daysAhead: 1, hour: 18)
                presetChip(title: "+7 Giorni", daysAhead: 7, hour: 18)
                presetChip(title: localizationManager.text(it: "Fine Mese", en: "End of Month"), endOfMonth: true)
            }
            
            Rectangle()
                .fill(isDarkMode ? Color.white.opacity(0.10) : Color.black.opacity(0.08))
                .frame(height: 1.5)
            
            // Month navigation
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                        .padding(6)
                        .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(monthYearTitle)
                    .font(UniFont.body())
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .padding(6)
                        .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            
            // Weekday symbols
            let weekdaySymbols = localizationManager.currentLanguage == .italian ? ["L", "M", "M", "G", "V", "S", "D"] : ["M", "T", "W", "T", "F", "S", "S"]
            HStack {
                ForEach(weekdaySymbols.indices, id: \.self) { i in
                    Text(weekdaySymbols[i])
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Month Calendar Days Grid
            let days = generateDaysInMonth(for: workingMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(days, id: \.id) { gridDay in
                    if let d = gridDay.date {
                        let isSelected = calendar.isDate(d, inSameDayAs: date)
                        let isToday = calendar.isDateInToday(d)
                        let dayNum = calendar.component(.day, from: d)
                        
                        Button {
                            updateDay(d)
                        } label: {
                            ZStack {
                                if isSelected {
                                    Circle()
                                        .fill(themeManager.accentColor)
                                        .frame(width: 28, height: 28)
                                } else if isToday {
                                    Circle()
                                        .stroke(themeManager.accentColor, lineWidth: 1.5)
                                        .frame(width: 28, height: 28)
                                }
                                
                                Text("\(dayNum)")
                                    .font(.system(size: 12, weight: isSelected || isToday ? .bold : .regular))
                                    .foregroundStyle(isSelected ? themeManager.accentTextColor : Color.primary)
                            }
                            .frame(height: 28)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 28)
                    }
                }
            }
            
            Rectangle()
                .fill(isDarkMode ? Color.white.opacity(0.10) : Color.black.opacity(0.08))
                .frame(height: 1.5)
            
            // Hour & Minute Controls
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(localizationManager.text(it: "ORARIO DI SCADENZA", en: "DUE TIME").uppercased())
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Quick Hour Chips
                    HStack(spacing: 4) {
                        if localizationManager.is12HourTime {
                            quickTimeChip("9 AM", h: 9, m: 0)
                            quickTimeChip("12 PM", h: 12, m: 0)
                            quickTimeChip("6 PM", h: 18, m: 0)
                            quickTimeChip("11:59 PM", h: 23, m: 59)
                        } else {
                            quickTimeChip("09:00", h: 9, m: 0)
                            quickTimeChip("12:00", h: 12, m: 0)
                            quickTimeChip("18:00", h: 18, m: 0)
                            quickTimeChip("23:59", h: 23, m: 59)
                        }
                    }
                }
                
                HStack(spacing: localizationManager.is12HourTime ? 8 : 16) {
                    if localizationManager.is12HourTime {
                        // 12-hour English Stepper (1..12)
                        HStack(spacing: 5) {
                            Text(localizationManager.text(it: "Ora:", en: "Hour:"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            
                            Button {
                                let currentH12 = selectedHour % 12 == 0 ? 12 : selectedHour % 12
                                let nextH12 = currentH12 > 1 ? currentH12 - 1 : 12
                                let isPM = selectedHour >= 12
                                selectedHour = isPM ? (nextH12 == 12 ? 12 : nextH12 + 12) : (nextH12 == 12 ? 0 : nextH12)
                                applyTime()
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 20, height: 20)
                                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            let displayH12 = selectedHour % 12 == 0 ? 12 : selectedHour % 12
                            Text("\(displayH12)")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .frame(width: 22)
                            
                            Button {
                                let currentH12 = selectedHour % 12 == 0 ? 12 : selectedHour % 12
                                let nextH12 = currentH12 < 12 ? currentH12 + 1 : 1
                                let isPM = selectedHour >= 12
                                selectedHour = isPM ? (nextH12 == 12 ? 12 : nextH12 + 12) : (nextH12 == 12 ? 0 : nextH12)
                                applyTime()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 20, height: 20)
                                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Minute Stepper
                        HStack(spacing: 5) {
                            Text(localizationManager.text(it: "Minuti:", en: "Min:"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            
                            Button {
                                if selectedMinute >= 5 { selectedMinute -= 5 } else { selectedMinute = 55 }
                                applyTime()
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 20, height: 20)
                                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Text(String(format: "%02d", selectedMinute))
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .frame(width: 24)
                            
                            Button {
                                if selectedMinute <= 50 { selectedMinute += 5 } else { selectedMinute = 0 }
                                applyTime()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 20, height: 20)
                                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer(minLength: 2)
                        
                        // AM / PM Switcher
                        HStack(spacing: 2) {
                            Button {
                                if selectedHour >= 12 {
                                    selectedHour -= 12
                                    applyTime()
                                }
                            } label: {
                                Text("AM")
                                    .font(.system(size: 10.5, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3.5)
                                    .background(selectedHour < 12 ? themeManager.accentColor : Color.clear)
                                    .foregroundStyle(selectedHour < 12 ? themeManager.accentTextColor : .secondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                if selectedHour < 12 {
                                    selectedHour += 12
                                    applyTime()
                                }
                            } label: {
                                Text("PM")
                                    .font(.system(size: 10.5, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3.5)
                                    .background(selectedHour >= 12 ? themeManager.accentColor : Color.clear)
                                    .foregroundStyle(selectedHour >= 12 ? themeManager.accentTextColor : .secondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(2)
                        .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    } else {
                        // 24-hour Italian Stepper (00..23)
                        HStack(spacing: 8) {
                            Text(localizationManager.text(it: "Ora:", en: "Hour:"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            
                            Button {
                                if selectedHour > 0 { selectedHour -= 1 } else { selectedHour = 23 }
                                applyTime()
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 22, height: 22)
                                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Text(String(format: "%02d", selectedHour))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .frame(width: 30)
                            
                            Button {
                                if selectedHour < 23 { selectedHour += 1 } else { selectedHour = 0 }
                                applyTime()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 22, height: 22)
                                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                        
                        // Minute Stepper
                        HStack(spacing: 8) {
                            Text(localizationManager.text(it: "Minuti:", en: "Min:"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            
                            Button {
                                if selectedMinute >= 5 { selectedMinute -= 5 } else { selectedMinute = 55 }
                                applyTime()
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 22, height: 22)
                                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Text(String(format: "%02d", selectedMinute))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .frame(width: 30)
                            
                            Button {
                                if selectedMinute <= 50 { selectedMinute += 5 } else { selectedMinute = 0 }
                                applyTime()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 22, height: 22)
                                    .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(isDarkMode ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Confirm Button
            Button {
                isPresented = false
            } label: {
                Text(localizationManager.text(it: "Fatto", en: "Done"))
                    .font(UniFont.subheadline())
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(themeManager.accentColor)
                    .foregroundStyle(themeManager.accentTextColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(width: 330)
        .background(.ultraThinMaterial)
    }
    
    private func presetChip(title: String, daysAhead: Int = 0, hour: Int = 18, endOfMonth: Bool = false) -> some View {
        Button {
            var target = Date()
            if endOfMonth {
                if let interval = calendar.dateInterval(of: .month, for: date) {
                    target = interval.end.addingTimeInterval(-86400)
                }
            } else if daysAhead > 0 {
                target = calendar.date(byAdding: .day, value: daysAhead, to: Date()) ?? Date()
            }
            selectedHour = hour
            selectedMinute = (hour == 23) ? 59 : 0
            
            var comps = calendar.dateComponents([.year, .month, .day], from: target)
            comps.hour = selectedHour
            comps.minute = selectedMinute
            if let finalDate = calendar.date(from: comps) {
                self.date = finalDate
                self.workingMonth = finalDate
            }
        } label: {
            Text(title)
                .font(.system(size: 10.5, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
    
    private func quickTimeChip(_ text: String, h: Int, m: Int) -> some View {
        let isCurrent = selectedHour == h && selectedMinute == m
        return Button {
            selectedHour = h
            selectedMinute = m
            applyTime()
        } label: {
            Text(text)
                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(isCurrent ? themeManager.accentColor.opacity(0.2) : (isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.05)))
                .foregroundStyle(isCurrent ? themeManager.accentColor : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }
    
    private func updateDay(_ newDay: Date) {
        var comps = calendar.dateComponents([.year, .month, .day], from: newDay)
        comps.hour = selectedHour
        comps.minute = selectedMinute
        if let combined = calendar.date(from: comps) {
            self.date = combined
        }
    }
    
    private func applyTime() {
        var comps = calendar.dateComponents([.year, .month, .day], from: date)
        comps.hour = selectedHour
        comps.minute = selectedMinute
        if let combined = calendar.date(from: comps) {
            self.date = combined
        }
    }
    
    private func changeMonth(by val: Int) {
        if let m = calendar.date(byAdding: .month, value: val, to: workingMonth) {
            self.workingMonth = m
        }
    }
    
    private func generateDaysInMonth(for monthDate: Date) -> [CalendarGridDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { return [] }
        let startOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let leadingSpaces = (weekday + 5) % 7 // Monday = 0
        
        var days: [CalendarGridDay] = []
        var idCounter = 0
        for _ in 0..<leadingSpaces {
            days.append(CalendarGridDay(id: idCounter, date: nil))
            idCounter += 1
        }
        guard let range = calendar.range(of: .day, in: .month, for: monthDate) else { return days }
        for day in 1...range.count {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(CalendarGridDay(id: idCounter, date: dayDate))
                idCounter += 1
            }
        }
        return days
    }
}

// MARK: - Search Status Filter Enum
public enum SearchStatusFilter: String, CaseIterable {
    case all = "all"
    case pending = "pending"
    case completed = "completed"
    
    public func localized(with lm: LocalizationManager) -> String {
        switch self {
        case .all: return lm.text(it: "Tutti", en: "All")
        case .pending: return lm.text(it: "In sospeso", en: "Pending")
        case .completed: return lm.text(it: "Completati", en: "Completed")
        }
    }
}

// MARK: - Full Right-Side Search Workspace View
public struct UniSearchWorkspaceView: View {
    @Binding public var selectedTab: String
    public var onClose: (() -> Void)?
    public var onOpenNewDeadline: () -> Void
    public var onOpenNewExam: () -> Void
    public var onOpenNewAssignment: () -> Void
    public var onOpenNewCourse: () -> Void
    public var onOpenFocusTimer: () -> Void
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    @State private var searchText = ""
    @State private var selectedCategory: PaletteItem.Category = .all
    @State private var selectedStatus: SearchStatusFilter = .all
    @State private var selectedIndex = 0
    @FocusState private var isFieldFocused: Bool
    @State private var hoveredItemId: String? = nil
    @State private var eventMonitor: Any? = nil
    
    @Environment(\.colorScheme) private var systemColorScheme
    private var isDarkMode: Bool {
        if themeManager.themeMode == .dark { return true }
        if themeManager.themeMode == .light { return false }
        return systemColorScheme == .dark
    }
    
    public init(
        selectedTab: Binding<String>,
        onClose: (() -> Void)? = nil,
        onOpenNewDeadline: @escaping () -> Void,
        onOpenNewExam: @escaping () -> Void,
        onOpenNewAssignment: @escaping () -> Void,
        onOpenNewCourse: @escaping () -> Void,
        onOpenFocusTimer: @escaping () -> Void
    ) {
        self._selectedTab = selectedTab
        self.onClose = onClose
        self.onOpenNewDeadline = onOpenNewDeadline
        self.onOpenNewExam = onOpenNewExam
        self.onOpenNewAssignment = onOpenNewAssignment
        self.onOpenNewCourse = onOpenNewCourse
        self.onOpenFocusTimer = onOpenFocusTimer
    }
    
    private func closeSearch() {
        searchText = ""
        selectedCategory = .all
        selectedStatus = .all
        selectedIndex = 0
        isFieldFocused = false
        onClose?()
    }
    
    // MARK: - All Connected Items Index
    private var allItems: [PaletteItem] {
        var items: [PaletteItem] = []
        
        // 1. Azioni Rapide & Comandi
        items.append(PaletteItem(
            id: "action-new-deadline",
            title: localizationManager.text(it: "Nuova Scadenza", en: "New Deadline"),
            subtitle: localizationManager.text(it: "Aggiungi una scadenza, promemoria o data limite", en: "Add a deadline, due date or reminder"),
            category: .actions,
            iconName: "plus.circle.fill",
            badgeText: "⌘N",
            color: themeManager.accentColor,
            searchTerms: "nuova scadenza crea aggiungi data limite termine promemoria urgente deadline new task",
            snippet: localizationManager.text(it: "Crea una nuova scadenza con data, priorità e corso associato.", en: "Create a new deadline with due date, priority and course."),
            action: {
                selectedTab = "deadlines"
                closeSearch()
                onOpenNewDeadline()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-new-exam",
            title: localizationManager.text(it: "Pianifica Esame", en: "Schedule Exam"),
            subtitle: localizationManager.text(it: "Registra o prepara un nuovo appello d'esame", en: "Register or prepare an exam session"),
            category: .actions,
            iconName: "graduationcap.fill",
            badgeText: nil,
            color: .orange,
            searchTerms: "pianifica esame esami appello sessione nuovo crea schedule exam",
            snippet: localizationManager.text(it: "Registra un appello scritto o orale con aula e data.", en: "Register a written or oral exam session with room and date."),
            action: {
                selectedTab = "exams"
                closeSearch()
                onOpenNewExam()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-new-assignment",
            title: localizationManager.text(it: "Nuovo Compito / Assignment / File", en: "New Assignment / Project / File"),
            subtitle: localizationManager.text(it: "Collega un compito, report, codice o consegna", en: "Link a report, code, document or homework submission"),
            category: .actions,
            iconName: "doc.badge.plus",
            badgeText: nil,
            color: .blue,
            searchTerms: "nuovo assignment compito compiti compitino progetto progetti consegna consegne relazione report file documento pdf tesi homework new task",
            snippet: localizationManager.text(it: "Collega un file locale o link cloud a un compito universitario.", en: "Attach a local file or cloud link to an academic assignment."),
            action: {
                selectedTab = "assignments"
                closeSearch()
                onOpenNewAssignment()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-new-course",
            title: localizationManager.text(it: "Nuovo Corso Universitario", en: "New University Course"),
            subtitle: localizationManager.text(it: "Aggiungi materia, CFU, professore e orario", en: "Add course, credits, professor and schedule"),
            category: .actions,
            iconName: "book.fill",
            badgeText: nil,
            color: .purple,
            searchTerms: "nuovo corso corsi materia materie cfu professore docente aula new course",
            snippet: localizationManager.text(it: "Configura materia di studio con codice, CFU, orario e docente.", en: "Configure university subject with code, credits and professor."),
            action: {
                selectedTab = "courses"
                closeSearch()
                onOpenNewCourse()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-focus-timer",
            title: localizationManager.text(it: "Timer Studio / Pomodoro", en: "Study / Pomodoro Timer"),
            subtitle: localizationManager.text(it: "Avvia una sessione di concentrazione per un corso", en: "Start a focus study session for a course"),
            category: .actions,
            iconName: "timer",
            badgeText: "⌘T",
            color: themeManager.accentColor,
            searchTerms: "timer studio pomodoro concentrazione focus sessione",
            snippet: localizationManager.text(it: "Sessioni di studio intervallate con tracciamento tempo.", en: "Study sessions with Pomodoro intervals and course tracking."),
            action: {
                closeSearch()
                onOpenFocusTimer()
            }
        ))
        
        items.append(PaletteItem(
            id: "action-sync-calendar",
            title: localizationManager.text(it: "Sincronizza Calendario Orario", en: "Sync Academic Calendar"),
            subtitle: localizationManager.text(it: "Aggiorna lezioni dal feed universitario webcal/.ics", en: "Update lectures from university webcal/.ics feed"),
            category: .actions,
            iconName: "arrow.clockwise",
            badgeText: "⌘R",
            color: .secondary,
            searchTerms: "sincronizza calendario orario lezioni feed ics webcal refresh sync",
            snippet: localizationManager.text(it: "Scarica e rinfresca le lezioni e gli orari dal feed webcal.", en: "Fetch and refresh lectures from the academic webcal feed."),
            action: {
                closeSearch()
                Task {
                    await dataManager.syncCalendarFeed()
                    NotificationManager.shared.notify(
                        title: localizationManager.text(it: "Calendario sincronizzato", en: "Calendar synchronized"),
                        message: localizationManager.text(it: "\(dataManager.syncedEvents.count) lezioni ed eventi aggiornati.", en: "\(dataManager.syncedEvents.count) events updated."),
                        type: .success,
                        icon: "calendar.badge.clock"
                    )
                }
            }
        ))
        
        // 2. Corsi Universitari (Tutti i campi: nome, codice, prof, aula, note, cfu, link, file)
        for course in dataManager.courses {
            let color = Color(hex: course.colorHex) ?? themeManager.accentColor
            let prof = course.professor.isEmpty ? localizationManager.text(it: "Docente N/D", en: "Instructor N/A") : course.professor
            let room = course.room.isEmpty ? "" : " • " + localizationManager.text(it: "Aula ", en: "Room ") + course.room
            let linksText = course.links.map { "\($0.title) \($0.url)" }.joined(separator: " ")
            let filesText = course.linkedFiles.map { "\($0.name) \($0.filePath)" }.joined(separator: " ")
            let scheduleText = course.schedule.map { "\($0.dayName) \($0.startTime) \($0.endTime) \($0.room)" }.joined(separator: " ")
            
            let noteSnippet = course.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : course.notes
            
            items.append(PaletteItem(
                id: "course-\(course.id)",
                title: course.name,
                subtitle: "Prof. \(prof) • \(course.cfu) CFU\(room)",
                category: .courses,
                iconName: "book.closed.fill",
                badgeText: "\(course.cfu) CFU",
                color: color,
                searchTerms: "corso corsi course courses materia materie \(course.code) \(course.name) \(course.professor) \(course.professorEmail) \(course.room) \(course.notes) \(course.cfu) cfu \(linksText) \(filesText) \(scheduleText)",
                snippet: noteSnippet,
                action: {
                    selectedTab = "courses"
                    dataManager.selectedCourseId = course.id
                    closeSearch()
                }
            ))
        }
        
        // 3. Scadenze & Consegne (Titolo, note, corso, link, file allegato, priorità, stato)
        for deadline in dataManager.deadlines {
            let courseName = dataManager.courses.first(where: { $0.id == deadline.courseId })?.name ?? localizationManager.text(it: "Generale", en: "General")
            let dateStr = DateFormatter.shortDate.string(from: deadline.dueDate)
            let isUrgent = !deadline.isCompleted && deadline.priority == .high
            let dueText = localizationManager.text(it: "Scade il", en: "Due")
            let linkText = !deadline.allLinks.isEmpty ? " • Link" : ""
            let fileText = deadline.localFileName.flatMap { " • 📎 \($0)" } ?? ""
            let linksAll = deadline.allLinks.joined(separator: " ")
            let fileAll = "\(deadline.localFileName ?? "") \(deadline.localFilePath ?? "")"
            
            let noteSnippet = deadline.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : deadline.notes
            
            items.append(PaletteItem(
                id: "deadline-\(deadline.id)",
                title: deadline.title,
                subtitle: "\(courseName) • \(dueText) \(dateStr)\(fileText)\(linkText)",
                category: .deadlines,
                iconName: deadline.isCompleted ? "checkmark.circle.fill" : (isUrgent ? "exclamationmark.circle.fill" : "clock.fill"),
                badgeText: deadline.isCompleted ? localizationManager.text(it: "Completata", en: "Completed") : deadline.priority.localizedName,
                color: deadline.isCompleted ? .green : deadline.priority.color,
                searchTerms: "scadenza scadenze deadline deadlines data limite termine promemoria urgente task \(courseName) \(deadline.title) \(deadline.notes) \(deadline.priority.localizedName) \(deadline.isCompleted ? "fatto completata completato done" : "da fare aperta aperto in sospeso pending") \(linksAll) \(fileAll)",
                snippet: noteSnippet,
                action: {
                    selectedTab = "deadlines"
                    dataManager.selectedDeadlineId = deadline.id
                    closeSearch()
                }
            ))
        }
        
        // 4. Assignments & Compiti & File (Titolo, dettagli, note, corso, file locale, peso, stato)
        for assignment in dataManager.assignments {
            let courseName = dataManager.courses.first(where: { $0.id == assignment.courseId })?.name ?? localizationManager.text(it: "Generale", en: "General")
            let fileInfo = assignment.localFileName.flatMap { " • 📎 \($0)" } ?? ""
            let linkInfo = !assignment.allLinks.isEmpty ? " • 🔗 Link" : ""
            let linksAll = assignment.allLinks.joined(separator: " ")
            let fileAll = "\(assignment.localFileName ?? "") \(assignment.localFilePath ?? "") \(assignment.localFileSize ?? "")"
            let statusName = assignment.status.localized(with: localizationManager)
            let weightInfo = assignment.weightPercent > 0 ? " • Peso: \(assignment.weightPercent)%" : ""
            let dateStr = DateFormatter.shortDate.string(from: assignment.dueDate)
            let duePrefix = localizationManager.text(it: "Consegna", en: "Due")
            
            let detailSnippet = assignment.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : assignment.details
            
            items.append(PaletteItem(
                id: "assignment-\(assignment.id)",
                title: assignment.title,
                subtitle: "\(courseName) • \(duePrefix): \(dateStr)\(weightInfo)\(fileInfo)\(linkInfo)",
                category: .assignments,
                iconName: assignment.localFilePath != nil ? "doc.text.fill" : "doc.text",
                badgeText: assignment.isCompleted ? localizationManager.text(it: "Completato", en: "Completed") : (assignment.localFileName != nil ? "File" : statusName),
                color: assignment.isCompleted ? .green : (assignment.status == .inProgress ? .blue : .secondary),
                searchTerms: "assignment assignments compito compiti progetto progetti relazione report consegna consegne file documento pdf tesi homework esercizio esercizi \(courseName) \(assignment.title) \(assignment.details) \(fileAll) \(linksAll) \(statusName) \(assignment.isCompleted ? "fatto completato completed done" : "in corso da fare not started pending")",
                snippet: detailSnippet,
                action: {
                    selectedTab = "assignments"
                    dataManager.selectedAssignmentId = assignment.id
                    closeSearch()
                }
            ))
        }
        
        // 5. Esami & Sessioni (Titolo, corso, tipo, aula, note, voto, obiettivo, stato)
        for exam in dataManager.exams {
            let courseName = dataManager.courses.first(where: { $0.id == exam.courseId })?.name ?? localizationManager.text(it: "Esame", en: "Exam")
            let dateStr = DateFormatter.shortDate.string(from: exam.examDate)
            let roomStr = exam.room.isEmpty ? "" : " • " + localizationManager.text(it: "Aula ", en: "Room ") + exam.room
            let badge: String = {
                if exam.status == .passed {
                    return exam.grade.flatMap { "\($0)/30" } ?? localizationManager.text(it: "Superato", en: "Passed")
                }
                return exam.status.localizedName
            }()
            let targetStr = exam.targetGrade.flatMap { "Obiettivo: \($0)" } ?? ""
            let noteSnippet = exam.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : exam.notes
            
            items.append(PaletteItem(
                id: "exam-\(exam.id)",
                title: exam.title,
                subtitle: "\(courseName) • \(exam.type.localizedName) • \(dateStr)\(roomStr)",
                category: .exams,
                iconName: "graduationcap.fill",
                badgeText: badge,
                color: exam.status.badgeColor,
                searchTerms: "esame esami exam exams appello appelli sessione prova voto cfu orale scritto scritto orale \(courseName) \(exam.title) \(exam.type.localizedName) \(exam.room) \(exam.notes) \(exam.status.localizedName) \(badge) \(targetStr)",
                snippet: noteSnippet,
                action: {
                    selectedTab = "exams"
                    dataManager.selectedExamId = exam.id
                    closeSearch()
                }
            ))
        }
        
        // 6. Calendario Lezioni (Titolo, orario, aula, note)
        for event in dataManager.syncedEvents.prefix(120) {
            let location = event.location.isEmpty ? localizationManager.text(it: "Aula N/D", en: "Room N/A") : event.location
            let dateStr = DateFormatter.shortDateTime.string(from: event.startDate)
            let detailSnippet = event.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : event.details
            
            items.append(PaletteItem(
                id: "event-\(event.id)",
                title: event.title,
                subtitle: "\(location) • \(dateStr)",
                category: .calendar,
                iconName: "calendar.badge.clock",
                badgeText: localizationManager.text(it: "Lezione", en: "Lecture"),
                color: .teal,
                searchTerms: "lezione lezioni orario orari calendario aula calendar lecture event \(event.title) \(event.location) \(event.details)",
                snippet: detailSnippet,
                action: {
                    selectedTab = "calendar"
                    closeSearch()
                }
            ))
        }
        
        return items
    }
    
    // MARK: - Filtered and Ranked Results
    private var filteredItems: [PaletteItem] {
        let baseFiltered = UniSearchEngine.filterAndRank(
            items: allItems,
            query: searchText,
            category: selectedCategory
        )
        
        if selectedStatus == .all {
            return baseFiltered
        }
        
        return baseFiltered.filter { item in
            switch item.category {
            case .deadlines:
                guard let dl = dataManager.deadlines.first(where: { "deadline-\($0.id)" == item.id }) else { return true }
                return selectedStatus == .pending ? !dl.isCompleted : dl.isCompleted
            case .assignments:
                guard let asgn = dataManager.assignments.first(where: { "assignment-\($0.id)" == item.id }) else { return true }
                return selectedStatus == .pending ? !asgn.isCompleted : asgn.isCompleted
            case .exams:
                guard let ex = dataManager.exams.first(where: { "exam-\($0.id)" == item.id }) else { return true }
                return selectedStatus == .pending ? ex.status != .passed : ex.status == .passed
            default:
                return true
            }
        }
    }
    
    // MARK: - Live Category Counts
    private func countForCategory(_ cat: PaletteItem.Category) -> Int {
        switch cat {
        case .all:
            return allItems.count
        case .courses:
            return dataManager.courses.count
        case .deadlines:
            return dataManager.deadlines.count
        case .assignments:
            return dataManager.assignments.count
        case .exams:
            return dataManager.exams.count
        case .calendar:
            return dataManager.syncedEvents.count
        case .actions:
            return 6
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // TOP SEARCH HEADER BAR (Solid background, edge to edge)
            searchHeaderBar
            
            // MAIN WORKSPACE (Results Area on Left/Center, Filters on Right Side)
            HStack(spacing: 0) {
                // Left / Center Results Workspace (spacious, edge-to-edge)
                resultsWorkspaceView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 1.5pt Vertical Divider
                Rectangle()
                    .fill(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.08))
                    .frame(width: 1.5)
                
                // Right Side Filters Column (~260pt)
                filtersRightPanelView
                    .frame(width: 260)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            isDarkMode ? Color(red: 0.11, green: 0.11, blue: 0.13) : Color(red: 0.97, green: 0.97, blue: 0.98)
        )
        .onAppear {
            selectedCategory = .all
            selectedStatus = .all
            selectedIndex = 0
            isFieldFocused = true
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.keyCode == 53 { // ESC
                    closeSearch()
                    return nil
                } else if event.keyCode == 126 { // UP ARROW
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                    return nil
                } else if event.keyCode == 125 { // DOWN ARROW
                    if selectedIndex < filteredItems.count - 1 {
                        selectedIndex += 1
                    }
                    return nil
                }
                return event
            }
        }
        .onDisappear {
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
            }
        }
    }
    
    // MARK: - Search Header Bar
    private var searchHeaderBar: some View {
        HStack(spacing: 14) {
            // Magnifying Glass
            ZStack {
                Circle()
                    .fill(themeManager.accentColor.opacity(isDarkMode ? 0.20 : 0.12))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.accentColor)
            }
            
            // Input TextField
            TextField(
                localizationManager.text(
                    it: "Cerca compiti, corsi, esami, scadenze, note o file...",
                    en: "Search assignments, courses, exams, deadlines, notes or files..."
                ),
                text: $searchText
            )
            .textFieldStyle(.plain)
            .font(.system(size: 15, weight: .medium))
            .focused($isFieldFocused)
            .onSubmit {
                if !filteredItems.isEmpty && selectedIndex >= 0 && selectedIndex < filteredItems.count {
                    let it = filteredItems[selectedIndex]
                    it.action()
                }
            }
            .onChange(of: searchText) { _, _ in
                selectedIndex = 0
            }
            
            // Results Count Badge
            if !filteredItems.isEmpty {
                Text("\(filteredItems.count) " + localizationManager.text(it: "risultati", en: "results"))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(
                        isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.05),
                        in: Capsule()
                    )
            }
            
            // Clear Button
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Cancella testo", en: "Clear text"))
            }
            
            // Esc Pill
            Text("Esc")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary.opacity(0.8))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            
            // Close Button
            Button {
                closeSearch()
            } label: {
                Text(localizationManager.text(it: "Chiudi", en: "Close"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(themeManager.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(themeManager.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            isDarkMode ? Color(red: 0.14, green: 0.14, blue: 0.16) : Color.white
        )
        .overlay(
            Rectangle()
                .fill(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.08))
                .frame(height: 1.5),
            alignment: .bottom
        )
    }
    
    // MARK: - Left / Center Results Workspace View
    private var resultsWorkspaceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Results Workspace Sub-header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: selectedCategory.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                    
                    Text(selectedCategory.localizedTitle(with: localizationManager).uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.secondary)
                    
                    Text("(\(filteredItems.count))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary.opacity(0.8))
                }
                
                Spacer()
                
                // Status Filter Chips inside Results View
                if selectedCategory == .all || selectedCategory == .deadlines || selectedCategory == .assignments || selectedCategory == .exams {
                    HStack(spacing: 4) {
                        ForEach(SearchStatusFilter.allCases, id: \.self) { st in
                            let isSelected = selectedStatus == st
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    selectedStatus = st
                                    selectedIndex = 0
                                }
                            } label: {
                                Text(st.localized(with: localizationManager))
                                    .font(.system(size: 10.5, weight: isSelected ? .bold : .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3.5)
                                    .background(isSelected ? themeManager.accentColor : Color.primary.opacity(0.05))
                                    .foregroundStyle(isSelected ? themeManager.accentTextColor : Color.primary.opacity(0.8))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(isDarkMode ? Color.black.opacity(0.12) : Color.white.opacity(0.5))
            
            Divider()
            
            // Results ScrollView or Empty State
            if filteredItems.isEmpty {
                emptyResultsStateView
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                                UniSearchCardView(
                                    item: item,
                                    isSelected: index == selectedIndex,
                                    isHovered: hoveredItemId == item.id,
                                    isSuggested: index == 0 && !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                )
                                .id(item.id)
                                .onHover { h in
                                    if h { hoveredItemId = item.id } else if hoveredItemId == item.id { hoveredItemId = nil }
                                }
                                .onTapGesture {
                                    selectedIndex = index
                                    item.action()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    .onChange(of: selectedIndex) { _, newIndex in
                        if newIndex >= 0 && newIndex < filteredItems.count {
                            withAnimation {
                                proxy.scrollTo(filteredItems[newIndex].id, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyResultsStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(isDarkMode ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(.secondary.opacity(0.6))
            }
            
            VStack(spacing: 6) {
                Text(
                    searchText.isEmpty
                        ? localizationManager.text(it: "Nessun elemento in questa categoria", en: "No items in this category")
                        : localizationManager.text(it: "Nessun risultato per \"\(searchText)\"", en: "No results for \"\(searchText)\"")
                )
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                
                Text(
                    localizationManager.text(
                        it: "Prova a cercare il nome del corso, un docente, un file allegato (.pdf), una data o parole contenute nelle note.",
                        en: "Try searching course names, instructors, attached files (.pdf), due dates, or words in notes."
                    )
                )
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Text(localizationManager.text(it: "Cancella ricerca", en: "Clear Search"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(themeManager.accentColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(themeManager.accentColor.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(30)
    }
    
    // MARK: - Right Side Filters Panel View
    private var filtersRightPanelView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(themeManager.accentColor)
                
                Text(localizationManager.text(it: "FILTRI & CATEGORIE", en: "FILTERS & CATEGORIES"))
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isDarkMode ? Color.black.opacity(0.15) : Color.black.opacity(0.02))
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Category Selection List
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localizationManager.text(it: "CATEGORIE", en: "CATEGORIES"))
                            .font(.system(size: 9.5, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(.secondary.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.bottom, 2)
                        
                        ForEach([
                            PaletteItem.Category.all,
                            .courses,
                            .deadlines,
                            .assignments,
                            .exams,
                            .calendar,
                            .actions
                        ], id: \.self) { cat in
                            let isSelected = selectedCategory == cat
                            let count = countForCategory(cat)
                            
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    selectedCategory = cat
                                    selectedIndex = 0
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: cat.icon)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(isSelected ? themeManager.accentTextColor : (Color.primary.opacity(0.7)))
                                        .frame(width: 18)
                                    
                                    Text(cat.localizedTitle(with: localizationManager))
                                        .font(.system(size: 12.5, weight: isSelected ? .bold : .medium))
                                        .foregroundStyle(isSelected ? themeManager.accentTextColor : Color.primary)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text("\(count)")
                                        .font(.system(size: 10.5, weight: .semibold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            isSelected ? themeManager.accentTextColor.opacity(0.25) : (isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06)),
                                            in: Capsule()
                                        )
                                        .foregroundStyle(isSelected ? themeManager.accentTextColor : .secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(isSelected ? themeManager.accentColor : Color.clear)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Divider()
                    
                    // Status Filter Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.text(it: "STATO ATTIVITÀ", en: "ACTIVITY STATUS"))
                            .font(.system(size: 9.5, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(.secondary.opacity(0.8))
                            .padding(.horizontal, 8)
                        
                        VStack(spacing: 3) {
                            ForEach(SearchStatusFilter.allCases, id: \.self) { st in
                                let isSelected = selectedStatus == st
                                Button {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        selectedStatus = st
                                        selectedIndex = 0
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                            .font(.system(size: 12))
                                            .foregroundStyle(isSelected ? themeManager.accentColor : .secondary)
                                        
                                        Text(st.localized(with: localizationManager))
                                            .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                                            .foregroundStyle(isSelected ? .primary : .secondary)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(isSelected ? themeManager.accentColor.opacity(0.08) : Color.clear)
                                    )
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Quick Tips & Shortcuts
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizationManager.text(it: "NAVIGAZIONE RAPIDA", en: "QUICK NAVIGATION"))
                            .font(.system(size: 9.5, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(.secondary.opacity(0.8))
                            .padding(.horizontal, 8)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            shortcutLegendRow(key: "↵", label: localizationManager.text(it: "Apri elemento selezionato", en: "Open selected item"))
                            shortcutLegendRow(key: "↑ ↓", label: localizationManager.text(it: "Naviga tra i risultati", en: "Navigate results"))
                            shortcutLegendRow(key: "Esc", label: localizationManager.text(it: "Chiudi ricerca", en: "Close search"))
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(14)
            }
        }
        .background(
            isDarkMode ? Color(red: 0.13, green: 0.13, blue: 0.15) : Color(red: 0.95, green: 0.95, blue: 0.97)
        )
    }
    
    private func shortcutLegendRow(key: String, label: String) -> some View {
        HStack(spacing: 8) {
            Text(key)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Rich Search Card Component
public struct UniSearchCardView: View {
    public let item: PaletteItem
    public let isSelected: Bool
    public let isHovered: Bool
    public var isSuggested: Bool = false
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.colorScheme) private var systemColorScheme
    private var isDarkMode: Bool {
        if themeManager.themeMode == .dark { return true }
        if themeManager.themeMode == .light { return false }
        return systemColorScheme == .dark
    }
    
    private var categoryBadgeInfo: (text: String, icon: String, color: Color) {
        switch item.category {
        case .courses:
            return (localizationManager.text(it: "CORSO", en: "COURSE"), "book.closed.fill", .purple)
        case .deadlines:
            return (localizationManager.text(it: "SCADENZA", en: "DEADLINE"), "clock.fill", .red)
        case .assignments:
            return (localizationManager.text(it: "COMPITO", en: "ASSIGNMENT"), "doc.text.fill", .blue)
        case .exams:
            return (localizationManager.text(it: "ESAME", en: "EXAM"), "graduationcap.fill", .orange)
        case .calendar:
            return (localizationManager.text(it: "LEZIONE", en: "LECTURE"), "calendar.badge.clock", .teal)
        case .actions:
            return (localizationManager.text(it: "AZIONE", en: "ACTION"), "bolt.fill", themeManager.accentColor)
        default:
            return (localizationManager.text(it: "ALTRO", en: "OTHER"), "circle.fill", .secondary)
        }
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Category / Entity Colored Icon Box
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(item.color.opacity(isDarkMode ? 0.22 : 0.14))
                    .frame(width: 38, height: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(item.color.opacity(isDarkMode ? 0.35 : 0.25), lineWidth: 1)
                    )
                
                Image(systemName: item.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(item.color)
            }
            .padding(.top, 1)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title and Badges Row
                HStack(spacing: 7) {
                    // Explicit Category Badge (e.g. [SCADENZA] vs [COMPITO] vs [CORSO] vs [ESAME])
                    HStack(spacing: 3.5) {
                        Image(systemName: categoryBadgeInfo.icon)
                            .font(.system(size: 8.5, weight: .bold))
                        Text(categoryBadgeInfo.text)
                            .font(.system(size: 9, weight: .bold))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        categoryBadgeInfo.color.opacity(isDarkMode ? 0.22 : 0.12),
                        in: RoundedRectangle(cornerRadius: 4, style: .continuous)
                    )
                    .foregroundStyle(categoryBadgeInfo.color)
                    
                    Text(item.title)
                        .font(.system(size: 14.5, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    if isSuggested {
                        HStack(spacing: 3.5) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 9, weight: .bold))
                            Text(localizationManager.text(it: "SUGGERITO", en: "BEST MATCH"))
                                .font(.system(size: 9, weight: .bold))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            themeManager.accentColor.opacity(isDarkMode ? 0.26 : 0.14),
                            in: RoundedRectangle(cornerRadius: 4, style: .continuous)
                        )
                        .foregroundStyle(themeManager.accentColor)
                    }
                    
                    if let badge = item.badgeText {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(
                                item.color.opacity(isDarkMode ? 0.25 : 0.12),
                                in: RoundedRectangle(cornerRadius: 5, style: .continuous)
                            )
                            .foregroundStyle(item.color)
                    }
                    
                    Spacer()
                    
                    // Return key action hint (visible on hover / selected)
                    if isSelected || isHovered {
                        HStack(spacing: 4) {
                            Text("↵")
                                .font(.system(size: 11, weight: .bold))
                            Text("Apri")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(themeManager.accentColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2.5)
                        .background(
                            themeManager.accentColor.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 5, style: .continuous)
                        )
                        .transition(.opacity)
                    }
                }
                
                // Subtitle
                Text(item.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // Optional Snippet (Notes, details, file preview)
                if let snip = item.snippet, !snip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(snip)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary.opacity(0.85))
                        .lineLimit(2)
                        .padding(.top, 1)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    isSelected
                        ? themeManager.accentColor.opacity(isDarkMode ? 0.18 : 0.10)
                        : (isHovered ? (isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.04)) : (isDarkMode ? Color(red: 0.15, green: 0.15, blue: 0.17) : Color.white))
                )
                .shadow(color: Color.black.opacity(isDarkMode ? 0.20 : 0.04), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(
                    isSelected
                        ? themeManager.accentColor.opacity(0.85)
                        : (isSuggested ? themeManager.accentColor.opacity(0.35) : (isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.08))),
                    lineWidth: isSelected ? 1.5 : (isSuggested ? 1.2 : 1)
                )
        )
        .contentShape(Rectangle())
    }
}

// Backward-compatible wrapper if referenced
public struct UniTopInlineSearchBarView: View {
    public let width: CGFloat
    @Binding public var selectedTab: String
    public var onClose: (() -> Void)?
    public var onOpenNewDeadline: () -> Void
    public var onOpenNewExam: () -> Void
    public var onOpenNewAssignment: () -> Void
    public var onOpenNewCourse: () -> Void
    public var onOpenFocusTimer: () -> Void
    
    public init(
        width: CGFloat = 600,
        selectedTab: Binding<String>,
        onClose: (() -> Void)? = nil,
        onOpenNewDeadline: @escaping () -> Void,
        onOpenNewExam: @escaping () -> Void,
        onOpenNewAssignment: @escaping () -> Void,
        onOpenNewCourse: @escaping () -> Void,
        onOpenFocusTimer: @escaping () -> Void
    ) {
        self.width = width
        self._selectedTab = selectedTab
        self.onClose = onClose
        self.onOpenNewDeadline = onOpenNewDeadline
        self.onOpenNewExam = onOpenNewExam
        self.onOpenNewAssignment = onOpenNewAssignment
        self.onOpenNewCourse = onOpenNewCourse
        self.onOpenFocusTimer = onOpenFocusTimer
    }
    
    public var body: some View {
        UniSearchWorkspaceView(
            selectedTab: $selectedTab,
            onClose: onClose,
            onOpenNewDeadline: onOpenNewDeadline,
            onOpenNewExam: onOpenNewExam,
            onOpenNewAssignment: onOpenNewAssignment,
            onOpenNewCourse: onOpenNewCourse,
            onOpenFocusTimer: onOpenFocusTimer
        )
    }
}

