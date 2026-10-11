//
//  DeadlinesPrintView.swift
//  uni
//
//  Created by zinco.cc on 11/10/2026.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import PDFKit

// MARK: - Deadlines & Assignments Print View (A4 Layout)
struct DeadlinesPrintView: View {
    let items: [UnifiedTimelineItem]
    let filterDescription: String
    @ObservedObject var dataManager: DataManager
    @ObservedObject var localizationManager: LocalizationManager
    
    fileprivate static let datePrintFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()
    
    private var pendingCount: Int {
        items.filter { !$0.isCompleted }.count
    }
    
    private var urgentCount: Int {
        items.filter { $0.isUrgent }.count
    }
    
    private var totalPendingAmount: Double {
        items.compactMap { item -> Double? in
            switch item {
            case .deadline(let d):
                return d.isCompleted ? nil : d.amount
            case .assignment:
                return nil
            }
        }.reduce(0, +)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Istituzionale & Intestazione Studente
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dataManager.universityName.isEmpty ? "UNIVERSITÀ DEGLI STUDI" : dataManager.universityName.uppercased())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    Text(localizationManager.text(it: "Scadenze & Consegne Didattiche", en: "Deadlines & Academic Assignments"))
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.black)
                    
                    HStack(spacing: 8) {
                        Text("\(localizationManager.text(it: "Studente", en: "Student")): \(dataManager.studentName.isEmpty ? "—" : dataManager.studentName)")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        if !filterDescription.isEmpty {
                            Text("•")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                            Text("\(localizationManager.text(it: "Filtro", en: "Filter")): \(filterDescription)")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        UniPrintLogoView(size: 16)
                        Text("uni")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.black)
                    }
                    
                    Text("\(localizationManager.text(it: "Data emissione", en: "Issued on")): \(Self.datePrintFormatter.string(from: Date()))")
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // KPI Summary Cards
            HStack(spacing: 10) {
                kpiCard(
                    title: localizationManager.text(it: "TOTALE ELEMENTI", en: "TOTAL ITEMS"),
                    value: "\(items.count)",
                    color: .black
                )
                
                kpiCard(
                    title: localizationManager.text(it: "IN SOSPESO", en: "PENDING"),
                    value: "\(pendingCount)",
                    color: pendingCount > 0 ? .orange : .black
                )
                
                kpiCard(
                    title: localizationManager.text(it: "URGENTI / IMMINENTI", en: "URGENT / DUE SOON"),
                    value: "\(urgentCount)",
                    color: urgentCount > 0 ? .red : .black
                )
                
                kpiCard(
                    title: localizationManager.text(it: "IMPORTO DA SALDARE", en: "FEES TO PAY"),
                    value: totalPendingAmount > 0 ? String(format: "%.2f €", totalPendingAmount) : "—",
                    color: totalPendingAmount > 0 ? .blue : .black
                )
            }
            
            Divider()
            
            // Tabella Scadenze & Compiti
            VStack(alignment: .leading, spacing: 6) {
                // Header Tabella
                HStack {
                    Text(localizationManager.text(it: "TIPO & TITOLO", en: "TYPE & TITLE"))
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(localizationManager.text(it: "CORSO", en: "COURSE"))
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 110, alignment: .leading)
                    
                    Text(localizationManager.text(it: "SCADENZA", en: "DUE DATE"))
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 120, alignment: .leading)
                    
                    Text(localizationManager.text(it: "DETTAGLI / €", en: "DETAILS / €"))
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 85, alignment: .trailing)
                    
                    Text(localizationManager.text(it: "STATO", en: "STATUS"))
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 65, alignment: .trailing)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                    if items.isEmpty {
                    Text(localizationManager.text(it: "Nessuna scadenza o consegna corrispondente ai filtri impostati.", en: "No deadlines or assignments match the selected filters."))
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        DeadlinePrintRowView(
                            index: index,
                            item: item,
                            dataManager: dataManager,
                            localizationManager: localizationManager
                        )
                    }
                }
            }
            
            Spacer()
            
            // Footer Ufficiale uni (con Logo, Nome e Link al sito)
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    UniPrintLogoView(size: 14)
                    Text("uni")
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(.black)
                }
                
                Text("•")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                
                Text(localizationManager.text(it: "Documento riepilogativo delle scadenze generato da uni per macOS", en: "Deadlines summary report generated by uni for macOS"))
                    .font(.system(size: 8, weight: .light))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("uni.zinco.cc")
                    .font(.system(size: 8.5, weight: .regular))
                    .foregroundStyle(.black.opacity(0.85))
            }
            .padding(.top, 4)
        }
        .padding(32)
        .frame(width: 595)
        .frame(minHeight: 842)
        .background(Color.white)
    }
    
    private func kpiCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Row Subview for Swift Compiler Efficiency
private struct DeadlinePrintRowView: View {
    let index: Int
    let item: UnifiedTimelineItem
    let dataManager: DataManager
    let localizationManager: LocalizationManager
    
    fileprivate static let itemDateFormatterIT: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEE d MMM yyyy, HH:mm"
        return f
    }()
    
    fileprivate static let itemDateFormatterEN: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEE, MMM d yyyy, HH:mm"
        return f
    }()
    
    var body: some View {
        let course = dataManager.courses.first(where: { $0.id == item.courseId })
        let courseName = course?.name ?? "—"
        let dateFmt = localizationManager.currentLanguage == .english ? Self.itemDateFormatterEN : Self.itemDateFormatterIT
        let dateStr = dateFmt.string(from: item.dueDate)
        let descriptionText: String? = {
            switch item {
            case .deadline(let d):
                let t = d.notes.trimmingCharacters(in: .whitespacesAndNewlines)
                return t.isEmpty ? nil : t
            case .assignment(let a):
                let t = a.details.trimmingCharacters(in: .whitespacesAndNewlines)
                return t.isEmpty ? nil : t
            }
        }()
        let links: [String] = {
            switch item {
            case .deadline(let d):
                return d.allLinks
            case .assignment(let a):
                return a.allLinks
            }
        }()
        
        HStack(alignment: .top, spacing: 6) {
            // Colonna 1: Icona, Titolo, Descrizione se disponibile, Link se disponibili (tutto per intero su più righe)
            VStack(alignment: .leading, spacing: 2.5) {
                HStack(alignment: .top, spacing: 5) {
                    switch item {
                    case .deadline(let d):
                        Image(systemName: "clock.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.purple)
                            .padding(.top, 2)
                        Text(d.title)
                            .font(.system(size: 9.5, weight: .regular))
                            .foregroundStyle(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    case .assignment(let a):
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.blue)
                            .padding(.top, 2)
                        Text(a.title)
                            .font(.system(size: 9.5, weight: .regular))
                            .foregroundStyle(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                if let descriptionText = descriptionText {
                    Text(descriptionText)
                        .font(.system(size: 8, weight: .light))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 13)
                }
                
                if !links.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(links, id: \.self) { link in
                            HStack(alignment: .top, spacing: 3) {
                                Image(systemName: "link")
                                    .font(.system(size: 6.5))
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 1.5)
                                Text(link)
                                    .font(.system(size: 7.5, weight: .light))
                                    .foregroundStyle(.blue.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.leading, 13)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Corso
            Text(courseName)
                .font(.system(size: 9, weight: .light))
                .foregroundStyle(.black.opacity(0.75))
                .frame(width: 105, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 1)
            
            // Data
            Text(dateStr)
                .font(.system(size: 8.5, weight: .light, design: .monospaced))
                .foregroundStyle(item.isUrgent ? Color.red : Color.black.opacity(0.8))
                .frame(width: 115, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 1)
            
            // Dettagli / Importo / Priorità
            detailColumn
                .frame(width: 80, alignment: .trailing)
                .padding(.top, 1)
            
            // Stato
            statusColumn
                .frame(width: 65, alignment: .trailing)
                .padding(.top, 1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4.5)
        .background(index % 2 == 1 ? Color.black.opacity(0.02) : Color.clear)
    }
    
    @ViewBuilder
    private var detailColumn: some View {
        switch item {
        case .deadline(let d):
            if let amt = d.amount, amt > 0 {
                Text(String(format: "%.2f €", amt))
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(.blue)
            } else {
                Text(d.priority.localizedName)
                    .font(.system(size: 8.5, weight: .light))
                    .foregroundStyle(.secondary)
            }
        case .assignment(let a):
            if a.weightPercent > 0 {
                Text("\(a.weightPercent)%")
                    .font(.system(size: 8.5, weight: .regular))
                    .foregroundStyle(.secondary)
            } else {
                Text(a.status.localized(with: localizationManager))
                    .font(.system(size: 8.5, weight: .light))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var statusColumn: some View {
        if item.isCompleted {
            HStack(spacing: 3) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.green)
                Text(localizationManager.text(it: "Fatto", en: "Done"))
                    .font(.system(size: 8.5, weight: .regular))
                    .foregroundStyle(.green)
            }
        } else if item.isUrgent {
            Text(localizationManager.text(it: "Urgente", en: "Urgent"))
                .font(.system(size: 8.5, weight: .medium))
                .foregroundStyle(.red)
        } else {
            Text(localizationManager.text(it: "In corso", en: "Open"))
                .font(.system(size: 8.5, weight: .light))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Deadlines Export Manager
@MainActor
class DeadlinesExportManager {
    static let shared = DeadlinesExportManager()
    
    func exportPDF(
        items: [UnifiedTimelineItem],
        filterDescription: String,
        dataManager: DataManager,
        localizationManager: LocalizationManager
    ) {
        #if canImport(AppKit)
        let printView = DeadlinesPrintView(
            items: items,
            filterDescription: filterDescription,
            dataManager: dataManager,
            localizationManager: localizationManager
        )
        
        let targetWidth: CGFloat = 595
        let targetHeight: CGFloat = 842
        let renderer = ImageRenderer(content: printView)
        renderer.proposedSize = ProposedViewSize(width: targetWidth, height: nil)
        renderer.scale = 2.0
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        
        let dateClean = DateFormatter.shortDate.string(from: Date()).replacingOccurrences(of: "/", with: "-")
        let sanitizedUser = dataManager.studentName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let userPart = sanitizedUser.isEmpty ? "" : "_\(sanitizedUser)"
        savePanel.nameFieldStringValue = "uni_deadlines\(userPart)_\(dateClean).pdf"
        savePanel.title = localizationManager.text(it: "Salva Riepilogo Scadenze in PDF", en: "Save Deadlines Summary as PDF")
        
        guard savePanel.runModal() == .OK, let url = savePanel.url else { return }
        
        var writeSuccess = false
        let pdfData = NSMutableData()
        
        if let consumer = CGDataConsumer(data: pdfData as CFMutableData) {
            renderer.render { size, context in
                let pageHeight = max(targetHeight, size.height)
                var box = CGRect(x: 0, y: 0, width: targetWidth, height: pageHeight)
                if let pdfContext = CGContext(consumer: consumer, mediaBox: &box, nil) {
                    pdfContext.beginPDFPage(nil)
                    context(pdfContext)
                    pdfContext.endPDFPage()
                    pdfContext.closePDF()
                }
            }
            
            if pdfData.length > 0 {
                do {
                    try (pdfData as Data).write(to: url, options: .atomic)
                    writeSuccess = true
                } catch {
                    print("Errore scrittura PDF: \(error)")
                }
            }
        }
        
        // Fallback affidabile con PDFKit se il context vettoriale non ha scritto
        if !writeSuccess, let nsImage = renderer.nsImage {
            if let pdfPage = PDFPage(image: nsImage) {
                let pdfDoc = PDFDocument()
                pdfDoc.insert(pdfPage, at: 0)
                writeSuccess = pdfDoc.write(to: url)
            }
        }
        
        if writeSuccess {
            NotificationManager.shared.notify(
                title: localizationManager.text(it: "PDF Scadenze Esportato", en: "Deadlines PDF Exported"),
                message: localizationManager.text(it: "File PDF salvato con successo sul tuo Mac.", en: "PDF file saved successfully on your Mac."),
                type: .success,
                icon: "doc.text.fill"
            )
            
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
        #endif
    }
}
