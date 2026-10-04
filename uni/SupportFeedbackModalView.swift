//
//  SupportFeedbackModalView.swift
//  uni
//
//  Created by zinco.cc on 01/10/2026.
//

import SwiftUI

struct SupportFeedbackModalView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    // Official Help Webpage & Google Form Endpoints
    private static let helpWebpageURLString = "https://uni.zinco.cc/help.html"
    private static let formPostURLString = "https://docs.google.com/forms/d/e/1FAIpQLSfuhE8PKXY8OwtvQuMNbLpGtzy630xY4xOOF1TsB7Wryhwu-A/formResponse"
    
    // Google Form Entry IDs
    private static let entryTypeID = "entry.639411743"
    private static let entrySubjectID = "entry.1637433744"
    private static let entryDescriptionID = "entry.2050167357"
    private static let entryRatingID = "entry.410718318"
    
    enum SubmissionType: String, CaseIterable {
        case bugReport = "Bug Report"
        case featureRequest = "Feature Request"
        
        func title(with lm: LocalizationManager) -> String {
            switch self {
            case .bugReport:
                return lm.text(it: "Segnala un Bug", en: "Bug Report")
            case .featureRequest:
                return lm.text(it: "Suggerisci Funzionalità", en: "Feature Request")
            }
        }
        
        var icon: String {
            switch self {
            case .bugReport: return "ladybug.fill"
            case .featureRequest: return "sparkles"
            }
        }
    }
    
    @State private var submissionType: SubmissionType = .featureRequest
    @State private var subject: String = ""
    @State private var detailedDescription: String = ""
    @State private var rating: Int = 5
    @State private var includeSystemInfo: Bool = true
    
    @State private var isSubmitting: Bool = false
    @State private var isSuccess: Bool = false
    @State private var errorMessage: String? = nil
    
    private var diagnosticsString: String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        #if arch(arm64)
        let arch = "Apple Silicon"
        #else
        let arch = "Intel"
        #endif
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.5.1"
        return "uni v\(version) • macOS \(osVersion) • \(arch)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(themeManager.accentColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(themeManager.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizationManager.text(it: "Supporto & Feedback", en: "Support & Feedback"))
                        .font(UniFont.title())
                        .fontWeight(.bold)
                    Text(localizationManager.text(it: "Invia suggerimenti o segnalazioni direttamente al team di uni", en: "Submit feedback or report issues directly to the uni team"))
                        .font(UniFont.caption())
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Pulsante Pagina Web
                Button {
                    if let url = URL(string: Self.helpWebpageURLString) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "safari")
                            .font(.system(size: 11))
                        Text(localizationManager.text(it: "Pagina Help Web", en: "Web Help Page"))
                            .font(UniFont.caption())
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .buttonStyle(.plain)
                .help(localizationManager.text(it: "Apri la pagina di supporto sul sito web ufficiale (uni.zinco.cc/help)", en: "Open support page on official website (uni.zinco.cc/help)"))
            }
            .padding(18)
            .background(Color.primary.opacity(0.02))
            
            Divider()
            
            // Content
            if isSuccess {
                successStateView
            } else {
                formContentView
            }
            
            Divider()
            
            // Footer
            HStack {
                Button(localizationManager.t(.cancel)) {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                if let err = errorMessage {
                    Text(err)
                        .font(UniFont.caption())
                        .foregroundStyle(.red)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSuccess {
                    Button(localizationManager.text(it: "Fatto", en: "Done")) {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(themeManager.accentColor)
                } else {
                    Button {
                        submitToGoogleForm()
                    } label: {
                        HStack(spacing: 6) {
                            if isSubmitting {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 11))
                            }
                            Text(isSubmitting ? localizationManager.text(it: "Invio in corso...", en: "Submitting...") : localizationManager.text(it: "Invia Feedback", en: "Submit Feedback"))
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .tint(themeManager.accentColor)
                    .disabled(isSubmitting || subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || detailedDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(16)
            .background(Color.primary.opacity(0.02))
        }
        .frame(width: 580, height: 600)
    }
    
    // MARK: - Form View
    private var formContentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // 1. Tipo di invio (Bug Report vs Feature Request)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Text(localizationManager.text(it: "TIPO DI SEGNALAZIONE", en: "SUBMISSION TYPE"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                        Text("*")
                            .foregroundStyle(.red)
                    }
                    
                    HStack(spacing: 12) {
                        ForEach(SubmissionType.allCases, id: \.self) { type in
                            let isSelected = submissionType == type
                            Button {
                                submissionType = type
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: type.icon)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(isSelected ? themeManager.accentColor : .secondary)
                                    Text(type.title(with: localizationManager))
                                        .font(UniFont.subheadline())
                                        .fontWeight(isSelected ? .semibold : .regular)
                                        .foregroundStyle(isSelected ? .primary : .secondary)
                                    Spacer()
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(themeManager.accentColor)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(isSelected ? themeManager.accentColor.opacity(0.1) : Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(isSelected ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // 2. Oggetto / Titolo
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text(localizationManager.text(it: "OGGETTO", en: "SUBJECT"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                        Text("*")
                            .foregroundStyle(.red)
                    }
                    
                    TextField(localizationManager.text(it: "Es. 'Aggiungere filtro per semestre' oppure 'Errore salvataggio esame'", en: "E.g. 'Add semester filter' or 'Exam saving issue'"), text: $subject)
                        .textFieldStyle(.plain)
                        .font(UniFont.body())
                        .padding(9)
                        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                        )
                }
                
                // 3. Descrizione dettagliata
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text(localizationManager.text(it: "DESCRIZIONE DETTAGLIATA", en: "DETAILED DESCRIPTION"))
                            .font(UniFont.sectionLabel())
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                        Text("*")
                            .foregroundStyle(.red)
                    }
                    
                    ZStack(alignment: .topLeading) {
                        if detailedDescription.isEmpty {
                            Text(localizationManager.text(it: "Descrivi il comportamento riscontrato o come dovrebbe funzionare la novità richiesta...", en: "Describe the bug encountered or how the suggested feature should work..."))
                                .font(UniFont.body())
                                .foregroundStyle(.secondary.opacity(0.7))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                        }
                        
                        TextEditor(text: $detailedDescription)
                            .font(UniFont.body())
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .padding(6)
                            .frame(minHeight: 110, maxHeight: 170)
                    }
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
                }
                
                // 4. Valutazione Complessiva (1-5)
                VStack(alignment: .leading, spacing: 8) {
                    Text(localizationManager.text(it: "VALUTAZIONE GENERALE DI UNI", en: "OVERALL RATING OF UNI"))
                        .font(UniFont.sectionLabel())
                        .foregroundStyle(.secondary)
                        .tracking(1.0)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { score in
                                let isSelected = rating >= score
                                Button {
                                    rating = score
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(isSelected ? themeManager.accentColor.opacity(0.15) : Color.primary.opacity(0.04))
                                            .frame(height: 38)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: isSelected ? "star.fill" : "star")
                                                .font(.system(size: 13))
                                                .foregroundStyle(isSelected ? themeManager.accentColor : .secondary)
                                            Text("\(score)")
                                                .font(UniFont.headline())
                                                .fontWeight(.semibold)
                                                .foregroundStyle(isSelected ? themeManager.accentColor : .secondary)
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(isSelected ? themeManager.accentColor.opacity(0.4) : Color.primary.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        HStack {
                            Text(localizationManager.text(it: "1 - Molto scarsa", en: "1 - Very Poor"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(localizationManager.text(it: "5 - Eccellente", en: "5 - Excellent"))
                                .font(UniFont.caption())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // 5. Includi info diagnostiche
                Toggle(isOn: $includeSystemInfo) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizationManager.text(it: "Includi informazioni di sistema", en: "Include system information"))
                            .font(UniFont.subheadline())
                            .fontWeight(.medium)
                        Text(localizationManager.text(it: "Allega \(diagnosticsString) per facilitare l'analisi del feedback", en: "Attaches \(diagnosticsString) to assist debugging"))
                            .font(UniFont.caption())
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.checkbox)
            }
            .padding(20)
        }
    }
    
    // MARK: - Success View
    private var successStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.14))
                    .frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)
            }
            
            Text(localizationManager.text(it: "Feedback inviato con successo! 🎉", en: "Feedback submitted successfully! 🎉"))
                .font(UniFont.title())
                .fontWeight(.bold)
            
            Text(localizationManager.text(it: "Grazie per il tuo contributo: la tua segnalazione è stata salvata direttamente nel database di uni.", en: "Thank you! Your feedback has been received and saved into the uni feedback database."))
                .font(UniFont.subheadline())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    // MARK: - Headless HTTP POST to Google Form
    private func submitToGoogleForm() {
        let cleanSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        var cleanDescription = detailedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanSubject.isEmpty, !cleanDescription.isEmpty else { return }
        
        if includeSystemInfo {
            cleanDescription += "\n\n[Diagnostica: \(diagnosticsString)]"
        }
        
        isSubmitting = true
        errorMessage = nil
        
        guard let url = URL(string: Self.formPostURLString) else {
            isSubmitting = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "fvv", value: "1"),
            URLQueryItem(name: "pageHistory", value: "0"),
            URLQueryItem(name: Self.entryTypeID, value: submissionType.rawValue),
            URLQueryItem(name: Self.entrySubjectID, value: cleanSubject),
            URLQueryItem(name: Self.entryDescriptionID, value: cleanDescription),
            URLQueryItem(name: Self.entryRatingID, value: "\(rating)")
        ]
        
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if (200...302).contains(httpResponse.statusCode) {
                    await MainActor.run {
                        self.isSubmitting = false
                        SoundManager.shared.play(.success)
                        NotificationManager.shared.notify(
                            title: localizationManager.text(it: "Feedback registrato! 🎉", en: "Feedback recorded! 🎉"),
                            message: cleanSubject,
                            type: .success,
                            icon: "paperplane.fill"
                        )
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            self.isSuccess = true
                        }
                        
                        // Auto-dismiss after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            dismiss()
                        }
                    }
                } else {
                    await MainActor.run {
                        self.isSubmitting = false
                        self.errorMessage = localizationManager.text(
                            it: "Errore durante l'invio (HTTP \(httpResponse.statusCode)). Riprova.",
                            en: "Submission error (HTTP \(httpResponse.statusCode)). Please retry."
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    self.isSubmitting = false
                    self.errorMessage = localizationManager.text(
                        it: "Errore di connessione. Riprova o apri nel browser.",
                        en: "Connection error. Retry or open in browser."
                    )
                }
            }
        }
    }
}
