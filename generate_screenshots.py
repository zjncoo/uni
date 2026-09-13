#!/usr/bin/env python3
import subprocess
import os

os.makedirs("docs/assets/screenshots", exist_ok=True)

# Common macOS window SVG components
def make_window(content_svg, active_tab="dashboard", title="uni — Studente"):
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="1000" viewBox="0 0 1600 1000">
  <defs>
    <filter id="winShadow" x="-5%" y="-5%" width="110%" height="115%">
      <feDropShadow dx="0" dy="25" stdDeviation="30" flood-color="#000000" flood-opacity="0.18" />
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-color="#000000" flood-opacity="0.08" />
    </filter>
    <linearGradient id="bgGrad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0F172A" />
      <stop offset="50%" stop-color="#1E1B4B" />
      <stop offset="100%" stop-color="#0F172A" />
    </linearGradient>
    <linearGradient id="accentGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#6366F1" />
      <stop offset="100%" stop-color="#8B5CF6" />
    </linearGradient>
    <linearGradient id="cardGrad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#FFFFFF" />
      <stop offset="100%" stop-color="#FAFAFA" />
    </linearGradient>
    <filter id="softShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="2" stdDeviation="5" flood-color="#000000" flood-opacity="0.04" />
    </filter>
  </defs>

  <!-- Ambient Backdrop -->
  <rect width="1600" height="1000" fill="url(#bgGrad)" />
  <circle cx="200" cy="150" r="300" fill="#6366F1" opacity="0.15" filter="blur(60px)" />
  <circle cx="1400" cy="850" r="350" fill="#8B5CF6" opacity="0.12" filter="blur(70px)" />

  <!-- macOS Window Frame -->
  <g transform="translate(60, 40)" filter="url(#winShadow)">
    <rect width="1480" height="920" rx="16" fill="#F8FAFC" />
    <rect width="1480" height="920" rx="16" fill="none" stroke="rgba(255,255,255,0.2)" stroke-width="1" />

    <!-- Sidebar (Left 280px) -->
    <path d="M 0 16 C 0 7.16 7.16 0 16 0 L 280 0 L 280 920 L 16 920 C 7.16 920 0 912.84 0 904 Z" fill="#F1F5F9" />
    <line x1="280" y1="0" x2="280" y2="920" stroke="#E2E8F0" stroke-width="1" />

    <!-- Window Controls (Traffic Lights) -->
    <circle cx="28" cy="28" r="6.5" fill="#FF5F56" stroke="#E0443E" stroke-width="0.5" />
    <circle cx="48" cy="28" r="6.5" fill="#FFBD2E" stroke="#DEA123" stroke-width="0.5" />
    <circle cx="68" cy="28" r="6.5" fill="#27C93F" stroke="#1AAB29" stroke-width="0.5" />

    <!-- Sidebar Header: App Icon & Name -->
    <g transform="translate(24, 60)">
      <rect width="32" height="32" rx="8" fill="url(#accentGrad)" />
      <text x="16" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="16" font-weight="700" fill="#FFFFFF" text-anchor="middle">u</text>
      <text x="42" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="20" font-weight="700" fill="#0F172A">uni</text>
      
      <!-- Spotlight shortcut badge -->
      <rect x="195" y="6" width="38" height="20" rx="5" fill="#E2E8F0" />
      <text x="214" y="20" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">⌘K</text>
    </g>

    <!-- Sidebar Navigation Items -->
    <g transform="translate(16, 120)">
      <!-- Search Input in Sidebar -->
      <rect width="248" height="34" rx="8" fill="#E2E8F0" opacity="0.8" />
      <circle cx="20" cy="17" r="5" fill="none" stroke="#64748B" stroke-width="1.5" />
      <line x1="24" y1="21" x2="28" y2="25" stroke="#64748B" stroke-width="1.5" />
      <text x="36" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">Cerca veloce...</text>
      <rect x="210" y="8" width="28" height="18" rx="4" fill="#CBD5E1" />
      <text x="224" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="600" fill="#475569" text-anchor="middle">⌘F</text>

      <!-- Section: GENERALE -->
      <text x="12" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="700" fill="#94A3B8" letter-spacing="0.8">GENERALE</text>
      
      <!-- Nav Item: Dashboard -->
      <g transform="translate(0, 82)">
        <rect width="248" height="36" rx="8" fill="{'#6366F1' if active_tab=='dashboard' else 'none'}" />
        <text x="16" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" fill="{'#FFFFFF' if active_tab=='dashboard' else '#334155'}">⚡️</text>
        <text x="42" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="{'600' if active_tab=='dashboard' else '400'}" fill="{'#FFFFFF' if active_tab=='dashboard' else '#334155'}">Dashboard</text>
      </g>

      <!-- Nav Item: Calendario -->
      <g transform="translate(0, 122)">
        <rect width="248" height="36" rx="8" fill="{'#6366F1' if active_tab=='calendar' else 'none'}" />
        <text x="16" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" fill="{'#FFFFFF' if active_tab=='calendar' else '#334155'}">📅</text>
        <text x="42" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="{'600' if active_tab=='calendar' else '400'}" fill="{'#FFFFFF' if active_tab=='calendar' else '#334155'}">Calendario &amp; Orario</text>
      </g>

      <!-- Section: DIDATTICA -->
      <text x="12" y="184" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="700" fill="#94A3B8" letter-spacing="0.8">DIDATTICA</text>

      <!-- Nav Item: Corsi -->
      <g transform="translate(0, 196)">
        <rect width="248" height="36" rx="8" fill="{'#6366F1' if active_tab=='courses' else 'none'}" />
        <text x="16" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" fill="{'#FFFFFF' if active_tab=='courses' else '#334155'}">📚</text>
        <text x="42" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="{'600' if active_tab=='courses' else '400'}" fill="{'#FFFFFF' if active_tab=='courses' else '#334155'}">Corsi &amp; Materie</text>
        <rect x="214" y="9" width="22" height="18" rx="9" fill="{'rgba(255,255,255,0.25)' if active_tab=='courses' else '#E2E8F0'}" />
        <text x="225" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10.5" font-weight="600" fill="{'#FFFFFF' if active_tab=='courses' else '#64748B'}" text-anchor="middle">5</text>
      </g>

      <!-- Nav Item: Scadenze -->
      <g transform="translate(0, 236)">
        <rect width="248" height="36" rx="8" fill="{'#6366F1' if active_tab=='deadlines' else 'none'}" />
        <text x="16" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" fill="{'#FFFFFF' if active_tab=='deadlines' else '#334155'}">⏱️</text>
        <text x="42" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="{'600' if active_tab=='deadlines' else '400'}" fill="{'#FFFFFF' if active_tab=='deadlines' else '#334155'}">Scadenze &amp; Task</text>
        <rect x="214" y="9" width="22" height="18" rx="9" fill="{'#EF4444' if active_tab=='deadlines' else '#FEE2E2'}" />
        <text x="225" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10.5" font-weight="700" fill="{'#FFFFFF' if active_tab=='deadlines' else '#DC2626'}" text-anchor="middle">2</text>
      </g>

      <!-- Nav Item: Esami -->
      <g transform="translate(0, 276)">
        <rect width="248" height="36" rx="8" fill="{'#6366F1' if active_tab=='exams' else 'none'}" />
        <text x="16" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" fill="{'#FFFFFF' if active_tab=='exams' else '#334155'}">🎓</text>
        <text x="42" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="{'600' if active_tab=='exams' else '400'}" fill="{'#FFFFFF' if active_tab=='exams' else '#334155'}">Esami &amp; Appelli</text>
      </g>

      <!-- Nav Item: Timer Focus -->
      <g transform="translate(0, 316)">
        <rect width="248" height="36" rx="8" fill="{'#6366F1' if active_tab=='focus' else 'none'}" />
        <text x="16" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" fill="{'#FFFFFF' if active_tab=='focus' else '#334155'}">⏳</text>
        <text x="42" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="{'600' if active_tab=='focus' else '400'}" fill="{'#FFFFFF' if active_tab=='focus' else '#334155'}">Focus Timer</text>
      </g>

      <!-- Nav Item: Impostazioni -->
      <g transform="translate(0, 356)">
        <rect width="248" height="36" rx="8" fill="{'#6366F1' if active_tab=='settings' else 'none'}" />
        <text x="16" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" fill="{'#FFFFFF' if active_tab=='settings' else '#334155'}">⚙️</text>
        <text x="42" y="22" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="{'600' if active_tab=='settings' else '400'}" fill="{'#FFFFFF' if active_tab=='settings' else '#334155'}">Impostazioni</text>
      </g>
    </g>

    <!-- Sidebar Bottom: Outlook Mail Button -->
    <g transform="translate(16, 868)">
      <line x1="0" y1="-12" x2="248" y2="-12" stroke="#E2E8F0" stroke-width="1" />
      <rect width="36" height="36" rx="8" fill="rgba(99,102,241,0.12)" />
      <!-- Envelope Icon -->
      <path d="M 10 13 L 26 13 C 27.1 13 28 13.9 28 15 L 28 25 C 28 26.1 27.1 27 26 27 L 10 27 C 8.9 27 8 26.1 8 25 L 8 15 C 8 13.9 8.9 13 10 13 Z" fill="none" stroke="#6366F1" stroke-width="1.8" />
      <path d="M 8 15 L 18 21 L 28 15" fill="none" stroke="#6366F1" stroke-width="1.8" stroke-linejoin="round" />
      <text x="46" y="23" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="500" fill="#475569">Posta Universitaria</text>
    </g>

    <!-- Main Content Stage (Right of 280px) -->
    <g transform="translate(310, 24)">
      <!-- Top Titlebar Label & Action -->
      <text x="0" y="20" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="500" fill="#64748B">{title}</text>
      
      <!-- Main Content Insertion -->
      <g transform="translate(0, 36)">
        {content_svg}
      </g>
    </g>
  </g>
</svg>"""

# ==============================================================================
# 1. SCREENSHOT: DASHBOARD & NEXT SECTION
# ==============================================================================
dashboard_content = """
<!-- Top Date & Greetings -->
<text x="0" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#6366F1" letter-spacing="1">DOMENICA 13 SETTEMBRE 2026</text>
<text x="0" y="62" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="32" font-weight="700" fill="#0F172A">Bentornato, Francesco 👋</text>
<text x="0" y="88" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" fill="#64748B">Università degli Studi di Padova • Ingegneria Informatica</text>

<!-- Motivational Quote Card -->
<g transform="translate(0, 110)" filter="url(#softShadow)">
  <rect width="1120" height="74" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
  <circle cx="38" cy="37" r="18" fill="rgba(99,102,241,0.12)" />
  <text x="38" y="42" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" text-anchor="middle">✨</text>
  <text x="68" y="28" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10.5" font-weight="700" fill="#6366F1" letter-spacing="0.8">FRASE DEL GIORNO</text>
  <text x="68" y="50" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13.5" font-style="italic" fill="#1E293B">"Il successo è la somma di piccoli sforzi, ripetuti giorno dopo giorno."</text>
  <text x="615" y="50" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">— Robert Collier</text>
</g>

<!-- NEXT SECTION HEADER -->
<g transform="translate(0, 215)">
  <text x="0" y="16" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="18" font-weight="700" fill="#0F172A">NEXT</text>
  <text x="56" y="16" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" fill="#64748B">• I tuoi prossimi impegni in programma</text>
</g>

<!-- 3 INTERACTIVE SHORTCUT CARDS (NEXT) -->
<g transform="translate(0, 240)">
  <!-- Card 1: Next Lecture -->
  <g transform="translate(0, 0)" filter="url(#softShadow)">
    <rect width="360" height="135" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <rect width="360" height="4" rx="2" fill="#3B82F6" />
    <g transform="translate(18, 22)">
      <rect width="28" height="28" rx="6" fill="#EFF6FF" />
      <text x="14" y="19" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" text-anchor="middle">🕒</text>
      <text x="36" y="14" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="700" fill="#64748B" letter-spacing="0.6">PROSSIMA LEZIONE</text>
      <rect x="250" y="2" width="65" height="18" rx="5" fill="#DBEAFE" />
      <text x="282" y="15" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10.5" font-weight="600" fill="#1E40AF" text-anchor="middle">Aula 2B</text>
      
      <text x="0" y="48" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="15" font-weight="700" fill="#0F172A">Algoritmi &amp; Strutture Dati</text>
      <text x="0" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12.5" font-weight="500" fill="#3B82F6">Lunedì • 09:00 - 11:00</text>
      <text x="0" y="88" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#94A3B8">Tocca per aprire nel Calendario →</text>
    </g>
  </g>

  <!-- Card 2: Next Deadline -->
  <g transform="translate(380, 0)" filter="url(#softShadow)">
    <rect width="360" height="135" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <rect width="360" height="4" rx="2" fill="#EF4444" />
    <g transform="translate(18, 22)">
      <rect width="28" height="28" rx="6" fill="#FEF2F2" />
      <text x="14" y="19" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" text-anchor="middle">⚠️</text>
      <text x="36" y="14" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="700" fill="#64748B" letter-spacing="0.6">PROSSIMA SCADENZA</text>
      <rect x="260" y="2" width="55" height="18" rx="5" fill="#FEE2E2" />
      <text x="287" y="15" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10.5" font-weight="700" fill="#DC2626" text-anchor="middle">URGENTE</text>

      <text x="0" y="48" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="15" font-weight="700" fill="#0F172A">Relazione Progetto Reti</text>
      <text x="0" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12.5" font-weight="500" fill="#DC2626">Oggi alle 23:59 • Tra 12 ore</text>
      <text x="0" y="88" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#94A3B8">Tocca per completare la task →</text>
    </g>
  </g>

  <!-- Card 3: Next Exam -->
  <g transform="translate(760, 0)" filter="url(#softShadow)">
    <rect width="360" height="135" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <rect width="360" height="4" rx="2" fill="#8B5CF6" />
    <g transform="translate(18, 22)">
      <rect width="28" height="28" rx="6" fill="#F5F3FF" />
      <text x="14" y="19" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14" text-anchor="middle">🎓</text>
      <text x="36" y="14" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="700" fill="#64748B" letter-spacing="0.6">PROSSIMO ESAME</text>
      <rect x="250" y="2" width="65" height="18" rx="5" fill="#EDE9FE" />
      <text x="282" y="15" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10.5" font-weight="600" fill="#6D28D9" text-anchor="middle">9 CFU</text>

      <text x="0" y="48" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="15" font-weight="700" fill="#0F172A">Sistemi Operativi</text>
      <text x="0" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12.5" font-weight="600" fill="#7C3AED">18 Settembre 2026 • Tra 5 giorni</text>
      <text x="0" y="88" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#94A3B8">Tocca per dettagli appello →</text>
    </g>
  </g>
</g>

<!-- ACTIVE COURSES GRID -->
<g transform="translate(0, 410)">
  <text x="0" y="16" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="18" font-weight="700" fill="#0F172A">Corsi del Semestre</text>
  
  <!-- Course Card 1 -->
  <g transform="translate(0, 35)" filter="url(#softShadow)">
    <rect width="360" height="240" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="34" cy="36" r="14" fill="#6366F1" />
    <text x="34" y="41" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#FFFFFF" text-anchor="middle">ASD</text>
    <text x="58" y="34" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" font-weight="700" fill="#0F172A">Algoritmi &amp; Strutture Dati</text>
    <text x="58" y="52" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">Prof. Rossi • 9 CFU</text>
    
    <line x1="20" y1="75" x2="340" y2="75" stroke="#F1F5F9" stroke-width="1" />
    
    <text x="20" y="105" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#334155">Stato Preparazione</text>
    <!-- Progress Bar -->
    <rect x="20" y="120" width="320" height="8" rx="4" fill="#E2E8F0" />
    <rect x="20" y="120" width="240" height="8" rx="4" fill="#6366F1" />
    <text x="20" y="148" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">75% completato • 12/16 lezioni</text>

    <!-- Badges -->
    <rect x="20" y="175" width="110" height="24" rx="6" fill="#F1F5F9" />
    <text x="75" y="191" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="500" fill="#475569" text-anchor="middle">📄 6 File PDF</text>
    
    <rect x="140" y="175" width="120" height="24" rx="6" fill="#F1F5F9" />
    <text x="200" y="191" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="500" fill="#475569" text-anchor="middle">⏱️ 1 Consegna</text>
  </g>

  <!-- Course Card 2 -->
  <g transform="translate(380, 35)" filter="url(#softShadow)">
    <rect width="360" height="240" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="34" cy="36" r="14" fill="#0EA5E9" />
    <text x="34" y="41" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#FFFFFF" text-anchor="middle">SO</text>
    <text x="58" y="34" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" font-weight="700" fill="#0F172A">Sistemi Operativi</text>
    <text x="58" y="52" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">Prof. Bianchi • 9 CFU</text>

    <line x1="20" y1="75" x2="340" y2="75" stroke="#F1F5F9" stroke-width="1" />

    <text x="20" y="105" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#334155">Stato Preparazione</text>
    <!-- Progress Bar -->
    <rect x="20" y="120" width="320" height="8" rx="4" fill="#E2E8F0" />
    <rect x="20" y="120" width="290" height="8" rx="4" fill="#0EA5E9" />
    <text x="20" y="148" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">90% completato • Pronto per l'esame</text>

    <!-- Badges -->
    <rect x="20" y="175" width="110" height="24" rx="6" fill="#F1F5F9" />
    <text x="75" y="191" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="500" fill="#475569" text-anchor="middle">📄 14 File PDF</text>

    <rect x="140" y="175" width="120" height="24" rx="6" fill="#EDE9FE" />
    <text x="200" y="191" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#6D28D9" text-anchor="middle">🎓 Appello 18 Set</text>
  </g>

  <!-- Course Card 3 -->
  <g transform="translate(760, 35)" filter="url(#softShadow)">
    <rect width="360" height="240" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="34" cy="36" r="14" fill="#10B981" />
    <text x="34" y="41" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#FFFFFF" text-anchor="middle">RC</text>
    <text x="58" y="34" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" font-weight="700" fill="#0F172A">Reti di Calcolatori</text>
    <text x="58" y="52" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">Prof. Verdi • 6 CFU</text>

    <line x1="20" y1="75" x2="340" y2="75" stroke="#F1F5F9" stroke-width="1" />

    <text x="20" y="105" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#334155">Stato Preparazione</text>
    <!-- Progress Bar -->
    <rect x="20" y="120" width="320" height="8" rx="4" fill="#E2E8F0" />
    <rect x="20" y="120" width="160" height="8" rx="4" fill="#10B981" />
    <text x="20" y="148" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">50% completato • Consegna imminente</text>

    <!-- Badges -->
    <rect x="20" y="175" width="110" height="24" rx="6" fill="#F1F5F9" />
    <text x="75" y="191" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="500" fill="#475569" text-anchor="middle">📄 8 File PDF</text>

    <rect x="140" y="175" width="120" height="24" rx="6" fill="#FEE2E2" />
    <text x="200" y="191" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="700" fill="#DC2626" text-anchor="middle">⚠️ Scade Oggi</text>
  </g>
</g>
"""

# ==============================================================================
# 2. SCREENSHOT: CALENDAR & TIMETABLE
# ==============================================================================
calendar_content = """
<text x="0" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#6366F1" letter-spacing="1">CALENDARIO &amp; ORARIO</text>
<text x="0" y="60" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="30" font-weight="700" fill="#0F172A">Settimana 14 - 18 Settembre 2026</text>

<!-- Week Controls & iCal Sync -->
<g transform="translate(750, 25)">
  <rect width="180" height="34" rx="8" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
  <text x="90" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12.5" font-weight="600" fill="#334155" text-anchor="middle">Oggi • Settimana Corrente</text>

  <g transform="translate(195, 0)">
    <rect width="165" height="34" rx="8" fill="#6366F1" />
    <text x="82" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#FFFFFF" text-anchor="middle">🔄 Sincronizza iCal</text>
  </g>
</g>

<!-- Timetable Grid Header -->
<g transform="translate(0, 95)">
  <!-- Day Columns: Lun, Mar, Mer, Gio, Ven -->
  <g transform="translate(60, 0)">
    <rect width="200" height="32" rx="6" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="100" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#0F172A" text-anchor="middle">Lunedì 14</text>
  </g>
  <g transform="translate(275, 0)">
    <rect width="200" height="32" rx="6" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="100" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#0F172A" text-anchor="middle">Martedì 15</text>
  </g>
  <g transform="translate(490, 0)">
    <rect width="200" height="32" rx="6" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="100" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#0F172A" text-anchor="middle">Mercoledì 16</text>
  </g>
  <g transform="translate(705, 0)">
    <rect width="200" height="32" rx="6" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="100" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#0F172A" text-anchor="middle">Giovedì 17</text>
  </g>
  <g transform="translate(920, 0)">
    <rect width="200" height="32" rx="6" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="100" y="21" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#0F172A" text-anchor="middle">Venerdì 18</text>
  </g>
</g>

<!-- Timetable Grid Body -->
<g transform="translate(0, 140)">
  <!-- Time Labels on left -->
  <text x="0" y="45" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#94A3B8">09:00</text>
  <line x1="45" y1="40" x2="1120" y2="40" stroke="#F1F5F9" stroke-width="1" />

  <text x="0" y="165" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#94A3B8">11:00</text>
  <line x1="45" y1="160" x2="1120" y2="160" stroke="#F1F5F9" stroke-width="1" />

  <text x="0" y="285" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#94A3B8">14:00</text>
  <line x1="45" y1="280" x2="1120" y2="280" stroke="#F1F5F9" stroke-width="1" />

  <text x="0" y="405" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#94A3B8">16:00</text>
  <line x1="45" y1="400" x2="1120" y2="400" stroke="#F1F5F9" stroke-width="1" />

  <!-- LECTURE BLOCKS -->
  <!-- Lunedì 09:00 - 11:00: Algoritmi -->
  <g transform="translate(60, 40)" filter="url(#softShadow)">
    <rect width="200" height="110" rx="10" fill="#EEF2FF" stroke="#C7D2FE" stroke-width="1" />
    <rect width="5" height="110" rx="2" fill="#6366F1" />
    <text x="14" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#3730A3">Algoritmi</text>
    <text x="14" y="44" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11.5" font-weight="600" fill="#4F46E5">09:00 - 11:00</text>
    <text x="14" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#475569">📍 Aula 2B • Edificio A</text>
    <text x="14" y="90" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#64748B">Prof. Rossi</text>
  </g>

  <!-- Martedì 09:00 - 11:00: Reti -->
  <g transform="translate(275, 40)" filter="url(#softShadow)">
    <rect width="200" height="110" rx="10" fill="#ECFDF5" stroke="#A7F3D0" stroke-width="1" />
    <rect width="5" height="110" rx="2" fill="#10B981" />
    <text x="14" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#065F46">Reti di Calcolatori</text>
    <text x="14" y="44" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11.5" font-weight="600" fill="#059669">09:00 - 11:00</text>
    <text x="14" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#475569">📍 Lab 1 • Polo Nord</text>
    <text x="14" y="90" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#64748B">Prof. Verdi</text>
  </g>

  <!-- Martedì 14:00 - 16:30: Sistemi Operativi -->
  <g transform="translate(275, 280)" filter="url(#softShadow)">
    <rect width="200" height="130" rx="10" fill="#F0F9FF" stroke="#BAE6FD" stroke-width="1" />
    <rect width="5" height="130" rx="2" fill="#0EA5E9" />
    <text x="14" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#075985">Sistemi Operativi</text>
    <text x="14" y="44" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11.5" font-weight="600" fill="#0284C7">14:00 - 16:30</text>
    <text x="14" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#475569">📍 Aula Magna</text>
    <text x="14" y="90" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#64748B">Prof. Bianchi</text>
    <rect x="14" y="102" width="75" height="18" rx="4" fill="#E0F2FE" />
    <text x="51" y="115" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="9.5" font-weight="700" fill="#0369A1" text-anchor="middle">Laboratorio</text>
  </g>

  <!-- Mercoledì 11:30 - 13:30: Algoritmi -->
  <g transform="translate(490, 160)" filter="url(#softShadow)">
    <rect width="200" height="110" rx="10" fill="#EEF2FF" stroke="#C7D2FE" stroke-width="1" />
    <rect width="5" height="110" rx="2" fill="#6366F1" />
    <text x="14" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#3730A3">Algoritmi</text>
    <text x="14" y="44" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11.5" font-weight="600" fill="#4F46E5">11:30 - 13:30</text>
    <text x="14" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#475569">📍 Aula 2B</text>
    <text x="14" y="90" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#64748B">Esercitazione guidata</text>
  </g>

  <!-- Giovedì 09:00 - 11:00: Reti -->
  <g transform="translate(705, 40)" filter="url(#softShadow)">
    <rect width="200" height="110" rx="10" fill="#ECFDF5" stroke="#A7F3D0" stroke-width="1" />
    <rect width="5" height="110" rx="2" fill="#10B981" />
    <text x="14" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#065F46">Reti di Calcolatori</text>
    <text x="14" y="44" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11.5" font-weight="600" fill="#059669">09:00 - 11:00</text>
    <text x="14" y="70" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#475569">📍 Lab 1</text>
    <text x="14" y="90" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#64748B">Prof. Verdi</text>
  </g>

  <!-- Venerdì 09:00 - 12:00: ESAME -->
  <g transform="translate(920, 40)" filter="url(#softShadow)">
    <rect width="200" height="140" rx="10" fill="#F5F3FF" stroke="#DDD6FE" stroke-width="1.5" />
    <rect width="5" height="140" rx="2" fill="#8B5CF6" />
    <rect x="14" y="12" width="60" height="18" rx="4" fill="#8B5CF6" />
    <text x="44" y="25" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="700" fill="#FFFFFF" text-anchor="middle">APPELLO</text>
    <text x="14" y="52" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" font-weight="700" fill="#4C1D95">Sistemi Operativi</text>
    <text x="14" y="72" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11.5" font-weight="600" fill="#7C3AED">09:00 - 12:00</text>
    <text x="14" y="98" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#475569">📍 Aula E1 • Prova Scritta</text>
    <text x="14" y="120" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#6D28D9">⏰ Tra 5 giorni</text>
  </g>
</g>
"""

# ==============================================================================
# 3. SCREENSHOT: DEADLINES & TASKS
# ==============================================================================
deadlines_content = """
<text x="0" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#6366F1" letter-spacing="1">SCADENZE &amp; TASK</text>
<text x="0" y="60" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="30" font-weight="700" fill="#0F172A">Consegne &amp; Attività Programmate</text>

<!-- Filter pills -->
<g transform="translate(0, 95)">
  <rect width="80" height="30" rx="15" fill="#6366F1" />
  <text x="40" y="20" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#FFFFFF" text-anchor="middle">Tutte (4)</text>

  <g transform="translate(90, 0)">
    <rect width="90" height="30" rx="15" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="45" y="20" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="500" fill="#475569" text-anchor="middle">Urgenti (1)</text>
  </g>

  <g transform="translate(190, 0)">
    <rect width="115" height="30" rx="15" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="57" y="20" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="500" fill="#475569" text-anchor="middle">Questa settimana</text>
  </g>
</g>

<!-- Deadlines List -->
<g transform="translate(0, 145)">
  <!-- Deadline Card 1: Urgent -->
  <g transform="translate(0, 0)" filter="url(#softShadow)">
    <rect width="1120" height="110" rx="12" fill="#FFFFFF" stroke="#FCA5A5" stroke-width="1.5" />
    <!-- Checkbox -->
    <circle cx="40" cy="55" r="14" fill="none" stroke="#CBD5E1" stroke-width="2" />
    
    <text x="75" y="42" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" font-weight="700" fill="#0F172A">Relazione Progetto Reti di Calcolatori</text>
    <text x="75" y="65" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" fill="#64748B">Consegna codice sorgente e benchmark delle prestazioni socket TCP/IP</text>
    <text x="75" y="88" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#DC2626">⚠️ Scade Oggi alle 23:59 • Tra 12 ore</text>

    <!-- Badges on right -->
    <rect x="880" y="32" width="105" height="26" rx="6" fill="#FEE2E2" />
    <text x="932" y="49" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="700" fill="#DC2626" text-anchor="middle">ALTA PRIORITÀ</text>

    <rect x="995" y="32" width="105" height="26" rx="6" fill="#ECFDF5" />
    <text x="1047" y="49" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#065F46" text-anchor="middle">Reti (6 CFU)</text>
    
    <text x="1040" y="88" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#64748B">📎 2 allegati</text>
  </g>

  <!-- Deadline Card 2: Medium -->
  <g transform="translate(0, 130)" filter="url(#softShadow)">
    <rect width="1120" height="110" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="40" cy="55" r="14" fill="none" stroke="#CBD5E1" stroke-width="2" />

    <text x="75" y="42" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" font-weight="700" fill="#0F172A">Esercizio 4: Alberi Binari di Ricerca</text>
    <text x="75" y="65" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" fill="#64748B">Implementazione in C++ del bilanciamento AVL e test di complessità computazionale</text>
    <text x="75" y="88" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#D97706">⏱️ Scade Mercoledì 16 Settembre • Tra 3 giorni</text>

    <rect x="880" y="32" width="105" height="26" rx="6" fill="#FEF3C7" />
    <text x="932" y="49" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="700" fill="#D97706" text-anchor="middle">MEDIA PRIORITÀ</text>

    <rect x="995" y="32" width="105" height="26" rx="6" fill="#EEF2FF" />
    <text x="1047" y="49" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#3730A3" text-anchor="middle">Algoritmi (9 CFU)</text>
  </g>

  <!-- Deadline Card 3: Normal -->
  <g transform="translate(0, 260)" filter="url(#softShadow)">
    <rect width="1120" height="110" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="40" cy="55" r="14" fill="none" stroke="#CBD5E1" stroke-width="2" />

    <text x="75" y="42" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" font-weight="700" fill="#0F172A">Presentazione Tesina Sistemi Operativi</text>
    <text x="75" y="65" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" fill="#64748B">Slide PowerPoint sull'architettura microkernel e gestione processi IPC</text>
    <text x="75" y="88" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="500" fill="#475569">📅 Scade Lunedì 21 Settembre • Tra 8 giorni</text>

    <rect x="880" y="32" width="105" height="26" rx="6" fill="#F1F5F9" />
    <text x="932" y="49" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#475569" text-anchor="middle">NORMALE</text>

    <rect x="995" y="32" width="105" height="26" rx="6" fill="#F0F9FF" />
    <text x="1047" y="49" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#075985" text-anchor="middle">Sistemi Op. (9 CFU)</text>
  </g>
</g>
"""

# ==============================================================================
# 4. SCREENSHOT: EXAMS & GPA
# ==============================================================================
exams_content = """
<text x="0" y="24" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#8B5CF6" letter-spacing="1">ESAMI &amp; PIANO DI STUDI</text>
<text x="0" y="60" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="30" font-weight="700" fill="#0F172A">Carriera Universitaria &amp; Appelli</text>

<!-- Metrics Row (GPA, CFU, Projection) -->
<g transform="translate(0, 95)">
  <!-- Card 1: Weighted Average -->
  <g transform="translate(0, 0)" filter="url(#softShadow)">
    <rect width="360" height="110" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="24" y="32" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="700" fill="#64748B" letter-spacing="0.6">MEDIA PONDERATA</text>
    <text x="24" y="78" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="36" font-weight="700" fill="#6366F1">28.8 <tspan font-size="18" font-weight="500" fill="#94A3B8">/ 30</tspan></text>
    <text x="24" y="98" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#10B981">▲ +0.4 rispetto al 1° anno</text>
  </g>

  <!-- Card 2: CFU Acquired -->
  <g transform="translate(380, 0)" filter="url(#softShadow)">
    <rect width="360" height="110" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="24" y="32" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="700" fill="#64748B" letter-spacing="0.6">CREDITI FORMATIVI (CFU)</text>
    <text x="24" y="78" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="36" font-weight="700" fill="#0F172A">126 <tspan font-size="18" font-weight="500" fill="#94A3B8">/ 180 CFU</tspan></text>
    <text x="24" y="98" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#64748B">70% completato della Laurea</text>
  </g>

  <!-- Card 3: Degree Base Score -->
  <g transform="translate(760, 0)" filter="url(#softShadow)">
    <rect width="360" height="110" rx="14" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <text x="24" y="32" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="700" fill="#64748B" letter-spacing="0.6">BASE DI LAUREA PREVISTA</text>
    <text x="24" y="78" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="36" font-weight="700" fill="#8B5CF6">105.6 <tspan font-size="18" font-weight="500" fill="#94A3B8">/ 110</tspan></text>
    <text x="24" y="98" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#8B5CF6">Con lode potenziale</text>
  </g>
</g>

<!-- Upcoming Exam Sessions -->
<g transform="translate(0, 235)">
  <text x="0" y="20" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="18" font-weight="700" fill="#0F172A">Prossimi Appelli d'Esame</text>
  
  <g transform="translate(0, 40)" filter="url(#softShadow)">
    <rect width="1120" height="95" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="48" cy="48" r="22" fill="#F5F3FF" />
    <text x="48" y="55" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" text-anchor="middle">🎓</text>

    <text x="86" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" font-weight="700" fill="#0F172A">Sistemi Operativi — 1° Appello Sessione Autunnale</text>
    <text x="86" y="60" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" fill="#64748B">Prova Scritta e Discussione Progetto in Aula E1 • Prof. Bianchi</text>
    <text x="86" y="80" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#8B5CF6">📅 Venerdì 18 Settembre 2026 • 09:00 (tra 5 giorni)</text>

    <rect x="995" y="32" width="105" height="30" rx="8" fill="#EDE9FE" />
    <text x="1047" y="51" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#6D28D9" text-anchor="middle">9 CFU</text>
  </g>

  <g transform="translate(0, 150)" filter="url(#softShadow)">
    <rect width="1120" height="95" rx="12" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
    <circle cx="48" cy="48" r="22" fill="#EEF2FF" />
    <text x="48" y="55" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" text-anchor="middle">📝</text>

    <text x="86" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="16" font-weight="700" fill="#0F172A">Algoritmi &amp; Strutture Dati — Appello Finale</text>
    <text x="86" y="60" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" fill="#64748B">Prova Scritta al calcolatore in Lab 2 • Prof. Rossi</text>
    <text x="86" y="80" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="600" fill="#6366F1">📅 Martedì 29 Settembre 2026 • 14:30 (tra 16 giorni)</text>

    <rect x="995" y="32" width="105" height="30" rx="8" fill="#EEF2FF" />
    <text x="1047" y="51" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" font-weight="700" fill="#3730A3" text-anchor="middle">9 CFU</text>
  </g>
</g>
"""

# ==============================================================================
# 5. SCREENSHOT: SPOTLIGHT GLOBAL SEARCH (COMMAND PALETTE)
# ==============================================================================
search_content = """
<!-- Dimmed backdrop behind Spotlight palette -->
<rect x="-30" y="-30" width="1180" height="850" fill="#0F172A" opacity="0.45" rx="12" />

<!-- Floating Spotlight Modal (Centered) -->
<g transform="translate(180, 80)" filter="url(#winShadow)">
  <rect width="760" height="520" rx="16" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1" />
  
  <!-- Search Input Header -->
  <g transform="translate(24, 28)">
    <circle cx="12" cy="12" r="8" fill="none" stroke="#6366F1" stroke-width="2.5" />
    <line x1="18" y1="18" x2="25" y2="25" stroke="#6366F1" stroke-width="2.5" stroke-linecap="round" />
    <text x="38" y="20" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display'" font-size="22" font-weight="500" fill="#0F172A">alg</text>
    <!-- Blinking Cursor -->
    <line x1="72" y1="2" x2="72" y2="24" stroke="#6366F1" stroke-width="2" />
    
    <rect x="660" y="3" width="50" height="22" rx="5" fill="#F1F5F9" />
    <text x="685" y="18" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#64748B" text-anchor="middle">ESC</text>
  </g>

  <line x1="0" y1="74" x2="760" y2="74" stroke="#F1F5F9" stroke-width="1.5" />

  <!-- Filter Pills Bar -->
  <g transform="translate(24, 92)">
    <rect width="75" height="26" rx="13" fill="#6366F1" />
    <text x="37" y="17" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="600" fill="#FFFFFF" text-anchor="middle">Tutti (4)</text>

    <g transform="translate(85, 0)">
      <rect width="80" height="26" rx="13" fill="#F1F5F9" />
      <text x="40" y="17" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="500" fill="#475569" text-anchor="middle">📚 Corsi</text>
    </g>

    <g transform="translate(175, 0)">
      <rect width="95" height="26" rx="13" fill="#F1F5F9" />
      <text x="47" y="17" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="500" fill="#475569" text-anchor="middle">⏱️ Scadenze</text>
    </g>

    <g transform="translate(280, 0)">
      <rect width="80" height="26" rx="13" fill="#F1F5F9" />
      <text x="40" y="17" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="500" fill="#475569" text-anchor="middle">🎓 Esami</text>
    </g>

    <g transform="translate(370, 0)">
      <rect width="90" height="26" rx="13" fill="#F1F5F9" />
      <text x="45" y="17" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" font-weight="500" fill="#475569" text-anchor="middle">📄 File PDF</text>
    </g>
  </g>

  <!-- Search Results List -->
  <g transform="translate(16, 136)">
    <!-- Result 1 (Highlighted / Selected) -->
    <g transform="translate(0, 0)">
      <rect width="728" height="66" rx="10" fill="#EEF2FF" />
      <circle cx="34" cy="33" r="16" fill="#6366F1" />
      <text x="34" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" text-anchor="middle">📚</text>
      <text x="64" y="27" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14.5" font-weight="700" fill="#0F172A"><tspan fill="#4F46E5">Alg</tspan>oritmi &amp; Strutture Dati</text>
      <text x="64" y="47" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">Corso • Prof. Rossi • 9 CFU • Aula 2B</text>
      <rect x="660" y="24" width="48" height="20" rx="4" fill="#C7D2FE" />
      <text x="684" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10.5" font-weight="700" fill="#3730A3" text-anchor="middle">Invio ↵</text>
    </g>

    <!-- Result 2: Scadenza -->
    <g transform="translate(0, 74)">
      <rect width="728" height="66" rx="10" fill="none" />
      <circle cx="34" cy="33" r="16" fill="#FEF3C7" />
      <text x="34" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" text-anchor="middle">⏱️</text>
      <text x="64" y="27" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14.5" font-weight="600" fill="#0F172A">Esercizio 4: <tspan fill="#D97706">Alg</tspan>oritmi di Ordinamento</text>
      <text x="64" y="47" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">Scadenza • Scade Mercoledì 16 Settembre</text>
      <rect x="620" y="24" width="88" height="20" rx="4" fill="#FEF3C7" />
      <text x="664" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="600" fill="#B45309" text-anchor="middle">Tra 3 giorni</text>
    </g>

    <!-- Result 3: Esame -->
    <g transform="translate(0, 148)">
      <rect width="728" height="66" rx="10" fill="none" />
      <circle cx="34" cy="33" r="16" fill="#EDE9FE" />
      <text x="34" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" text-anchor="middle">🎓</text>
      <text x="64" y="27" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14.5" font-weight="600" fill="#0F172A">Appello Finale di <tspan fill="#7C3AED">Alg</tspan>oritmi</text>
      <text x="64" y="47" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">Esame • Martedì 29 Settembre 2026 • 14:30</text>
      <rect x="635" y="24" width="73" height="20" rx="4" fill="#EDE9FE" />
      <text x="671" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="10" font-weight="600" fill="#6D28D9" text-anchor="middle">Appello</text>
    </g>

    <!-- Result 4: PDF -->
    <g transform="translate(0, 222)">
      <rect width="728" height="66" rx="10" fill="none" />
      <circle cx="34" cy="33" r="16" fill="#F1F5F9" />
      <text x="34" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="13" text-anchor="middle">📄</text>
      <text x="64" y="27" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="14.5" font-weight="600" fill="#0F172A">Slide_<tspan fill="#4F46E5">Alg</tspan>oritmi_Grafi_Cammini_Minimi.pdf</text>
      <text x="64" y="47" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="12" fill="#64748B">Allegato • 2.8 MB • Apri con Anteprima</text>
      <text x="668" y="38" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#94A3B8">PDF</text>
    </g>
  </g>

  <!-- Footer Navigation Info -->
  <g transform="translate(24, 485)">
    <text x="0" y="14" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text'" font-size="11" fill="#94A3B8">Usa ↑ ↓ per navigare • ↵ per selezionare • ESC per chiudere</text>
  </g>
</g>
"""

screens = [
    ("dashboard", dashboard_content, "dashboard", "uni — Dashboard &amp; NEXT"),
    ("calendar", calendar_content, "calendar", "uni — Calendario Orario"),
    ("deadlines", deadlines_content, "deadlines", "uni — Scadenze &amp; Task"),
    ("exams", exams_content, "exams", "uni — Esami &amp; Carriera"),
    ("search", search_content, "dashboard", "uni — Ricerca Rapida ⌘K"),
]

for name, content, tab, title in screens:
    svg_data = make_window(content, active_tab=tab, title=title)
    svg_path = f"docs/assets/screenshots/{name}.svg"
    png_path = f"docs/assets/screenshots/{name}.png"
    
    with open(svg_path, "w") as f:
        f.write(svg_data)
        
    subprocess.run(["sips", "-s", "format", "png", svg_path, "--out", png_path], check=True)
    print(f"Generated {png_path} successfully")

print("All screenshots generated successfully!")
