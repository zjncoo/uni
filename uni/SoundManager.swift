//
//  SoundManager.swift
//  uni
//
//  Created by Francesco Zanchetta on 12/09/2026.
//

import Foundation
import SwiftUI
import Combine
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Refined Sound Effect Types
public enum SoundEffect {
    case pop          // Click/pop leggero e soddisfacente (toggle checkbox, selezioni, drag&drop file)
    case success      // Chime cristallino ed elegante (scadenza completata, sincronizzazione riuscita, salvataggio)
    case notification // Suono discreto e morbido per comparsa Toast HUD a pillola
    case timer        // Avviso acustico soft per Focus Timer (avvio, pausa, sessione completata)
    case remove       // Soffio leggero e pulito per eliminazione elemento o ripristino
}

// MARK: - Sound Manager
public class SoundManager: ObservableObject {
    public static let shared = SoundManager()
    
    @Published public var soundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "uni_sound_effects_enabled")
        }
    }
    
    #if canImport(AppKit)
    private var cachedSounds: [String: NSSound] = [:]
    #endif
    
    private init() {
        self.soundEnabled = UserDefaults.standard.object(forKey: "uni_sound_effects_enabled") as? Bool ?? true
        preloadSounds()
    }
    
    private func preloadSounds() {
        #if canImport(AppKit)
        let soundNames = ["Pop", "Tink", "Blow", "Morse", "Ping", "Purr"]
        for name in soundNames {
            if let sound = NSSound(named: name) {
                cachedSounds[name] = sound
            }
        }
        #endif
    }
    
    /// Riproduce un feedback sonoro leggero, raffinato e proporzionato
    public func play(_ effect: SoundEffect) {
        guard soundEnabled else { return }
        
        #if canImport(AppKit)
        DispatchQueue.main.async {
            switch effect {
            case .pop:
                if let s = self.cachedSounds["Pop"] ?? NSSound(named: "Pop") {
                    s.stop()
                    s.volume = 0.35 // Volume calibrato, super leggero
                    s.play()
                }
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
                
            case .success:
                if let s = self.cachedSounds["Tink"] ?? NSSound(named: "Tink") {
                    s.stop()
                    s.volume = 0.42 // Tocco cristallino di successo
                    s.play()
                }
                NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                
            case .notification:
                if let s = self.cachedSounds["Morse"] ?? NSSound(named: "Morse") {
                    s.stop()
                    s.volume = 0.28
                    s.play()
                }
                
            case .timer:
                if let s = self.cachedSounds["Ping"] ?? NSSound(named: "Ping") {
                    s.stop()
                    s.volume = 0.40
                    s.play()
                }
                NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
                
            case .remove:
                if let s = self.cachedSounds["Blow"] ?? NSSound(named: "Blow") {
                    s.stop()
                    s.volume = 0.30
                    s.play()
                }
            }
        }
        #endif
    }
}
