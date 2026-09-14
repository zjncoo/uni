//
//  QuoteManager.swift
//  uni
//
//  Created by zinco.cc on 10/09/2026.
//

import SwiftUI
import Combine

public class QuoteManager: ObservableObject {
    public static let shared = QuoteManager()
    
    private static let storageKey = "uni_custom_quotes"
    private static let currentQuoteIndexKey = "uni_quote_index"
    
    @Published public var quotes: [String] = [] {
        didSet {
            UserDefaults.standard.set(quotes, forKey: Self.storageKey)
        }
    }
    
    @Published public var currentQuoteIndex: Int = 0 {
        didSet {
            UserDefaults.standard.set(currentQuoteIndex, forKey: Self.currentQuoteIndexKey)
        }
    }
    
    public init() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.storageKey)
        if let saved = saved, !saved.isEmpty {
            self.quotes = saved
        } else {
            // Frasi di default bilingue stimolanti ed eleganti
            self.quotes = [
                "L'eccellenza non è un atto, ma un'abitudine.",
                "Focalizzati sul processo, i risultati seguiranno.",
                "Un passo alla volta, ogni sessione di studio conta.",
                "La disciplina è il ponte tra gli obiettivi e il successo.",
                "Focus on progress, not perfection.",
                "Small daily improvements over time lead to stunning results."
            ]
        }
        self.currentQuoteIndex = UserDefaults.standard.integer(forKey: Self.currentQuoteIndexKey)
        if currentQuoteIndex >= quotes.count {
            currentQuoteIndex = 0
        }
    }
    
    public var currentQuote: String {
        guard !quotes.isEmpty else {
            return "Costanza, metodo e dedizione."
        }
        let safeIndex = currentQuoteIndex % quotes.count
        return quotes[safeIndex]
    }
    
    public func nextQuote() {
        guard !quotes.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
        }
    }
    
    public func addQuote(_ quote: String) {
        let trimmed = quote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        quotes.append(trimmed)
    }
    
    public func removeQuote(at offsets: IndexSet) {
        quotes.remove(atOffsets: offsets)
        if currentQuoteIndex >= quotes.count {
            currentQuoteIndex = max(0, quotes.count - 1)
        }
    }
    
    public func deleteQuote(at index: Int) {
        guard index >= 0 && index < quotes.count else { return }
        quotes.remove(at: index)
        if currentQuoteIndex >= quotes.count {
            currentQuoteIndex = max(0, quotes.count - 1)
        }
    }
}
