/**
 * uni — Official Showcase Script
 * Features:
 *  1. Automatic browser language detection (IT / EN) + manual toggle with persistence.
 *  2. Interactive Dynamic Island Pill Notification simulation.
 *  3. Dynamic today date formatted for the mockup.
 *  4. Motion-primitive style intersection animations.
 */

// ===================================================================
// 1. Translations Dictionary (Italian & English)
// ===================================================================
const i18n = {
  it: {
    nav_features: "Funzionalità",
    nav_panoramica: "Panoramica",
    nav_preview: "Panoramica",
    nav_help: "Supporto",
    nav_download: "Scarica .dmg",
    footer_help: "Supporto &amp; Feedback",

    riquadro_stats: "01 / RENDIMENTO & STATISTICHE",
    riquadro_heading: "Ciao Daniel 👋 la tua carriera è <strong>in perfetto orario</strong>",
    pill_gpa: "Media: <strong>28.84</strong>",
    pill_exams: "🏆 <strong>14/18</strong> esami superati",
    pill_zerocopy: "⚡️ <strong>Zero-Copy</strong> Finder",
    pill_local: "🔒 <strong>100%</strong> Locale sul Mac",

    riquadro_yellow_title: "Prossima lezione: <strong>Ingegneria del Software</strong>",
    riquadro_yellow_sub: "Aula 3 • Ore 11:30 (Sincronizzato da iCal ateneo)",
    riquadro_yellow_prof: "👨‍🏫 Prof. Bianchi • Oggi",

    riquadro_blue_label: "Avanzamento percorso accademico",
    riquadro_seg_triennale: "Triennale",
    riquadro_seg_magistrale: "Magistrale",
    riquadro_blue_status: "Sei in anticipo sulla tabella di marcia 😊",
    riquadro_blue_sub: "138 / 180 CFU acquisiti • Base laurea stimata: ~105.7",

    dock_overview: "Panoramica",
    dock_cal: "Calendario",
    dock_deadlines: "Scadenze",
    dock_exams: "Esami",
    dock_search: "Cerca",

    hero_badge: "100% Swift & AppKit nativo per Mac",
    hero_title: "L'app accademica per Mac.<br><span class=\"hero-title-accent\">Progettata come si deve.</span>",
    hero_subtitle: "Tutti i tuoi corsi, orari 24h sincronizzati dal calendario dell'ateneo, scadenze, esami e la posta di Outlook. 100% nativa per macOS, privata e senza distrazioni.",
    hero_cta_dmg: "Scarica per Mac (.dmg)",
    hero_cta_sub: "Universal • Apple Silicon & Intel",
    hero_cta_github: "Vedi su GitHub",

    stat_privacy: "Privato & Locale sul tuo Mac",
    stat_sync: "Orario iCal Rigoroso",
    stat_search: "Palette di Ricerca Globale",
    stat_nocopy: "File Duplicati (Zero-Copy)",

    pill_title: "Scadenza completata",
    pill_desc: "Progetto Finale archiviato con successo 🎉",
    pill_test_btn: "Test notifica",

    mock_search: "Cerca materie...",
    mock_group_general: "GENERALE",
    mock_nav_overview: "Panoramica",
    mock_nav_cal: "Calendario",
    mock_group_didactics: "DIDATTICA",
    mock_nav_courses: "Materie (6)",
    mock_nav_deadlines: "Scadenze",
    mock_nav_exams: "Esami",
    mock_nav_assignments: "Assignments",

    mock_today_badge: "OGGI",
    mock_greeting: "“L'eccellenza non è un atto, ma un'abitudine.”",
    mock_add_deadline: "Nuova Scadenza",
    mock_stat_gpa: "Media Ponderata",
    mock_stat_base: "Base laurea: ~105.7",
    mock_stat_cfu: "CFU Acquisiti",
    mock_stat_ontrack: "In perfetto orario",
    mock_stat_next: "Prossimo Appello",
    mock_stat_days: "Tra 9 giorni • Aula 2B",

    mock_outlook_inbox: "Posta in Arrivo • Microsoft Outlook Mac",
    mock_outlook_refresh: "Aggiorna",
    mock_courses_header: "MATERIE ATTIVE & FILE COLLEGATI (ZERO-COPY)",

    feat_badge: "Progettata per macOS",
    feat_title: "Tutto ciò che serve per studiare.<br>Senza fronzoli.",
    feat_subtitle: "Disegnata per dialogare in modo naturale con il Finder, con i calendari universitari e con le email dei docenti.",

    bento1_tag: "01 / Panoramica & NEXT.",
    bento1_title: "Panoramica Istantanea & Sezione NEXT",
    bento1_desc: "A colpo d'occhio trovi la prossima lezione in aula, la scadenza più urgente e il prossimo appello d'esame. Clicca sui riquadri per accedere direttamente alla sezione desiderata.",

    bento2_tag: "02 / Calendario & Orario 24h.",
    bento2_title: "Orario Settimanale 24h",
    bento2_desc: "Sincronizzazione iCal/webcal con l'ateneo o configurazione manuale. Aule, docenti e orari sempre sotto controllo.",

    bento3_tag: "03 / Scadenze & Priorità.",
    bento3_title: "Scadenze con Priorità",
    bento3_desc: "Countdown automatico al minuto, badge di urgenza, allegati locali zero-copy e filtri per materia.",

    bento4_tag: "04 / Libretto, Media & Esami.",
    bento4_title: "Media Ponderata & Voto Laurea",
    bento4_desc: "Calcolo automatico della media ponderata, CFU registrati e simulazione della base di partenza per la laurea.",

    bento5_tag: "05 / Ricerca Globale ⌘K.",
    bento5_title: "Palette di Ricerca Globale ⌘K / ⌘F",
    bento5_desc: "Richiama in qualunque momento la ricerca stile Spotlight di macOS: trova istantaneamente corsi, dispense PDF, appelli d'esame e lezioni con filtri a pillola.",

    zoom_screenshot: "Clicca per ingrandire",

    dl_title: "Scarica uni per il tuo Mac.",
    dl_desc: "Compatibile con macOS (Apple Silicon & Intel). Scarica l'immagine disco .dmg oppure compila l'app direttamente dal codice sorgente su GitHub.",
    dl_btn_dmg: "Scarica uni per macOS (.dmg)",
    dl_btn_dmg_sub: "Universal • Apple Silicon & Intel",
    dl_btn_zip: "Scarica Archivio (.zip)",
    dl_btn_zip_sub: "Pacchetto Completo • 1.1 MB",
    dl_btn_github: "Apri Repository GitHub",
    dl_btn_github_sub: "Codice Sorgente Open Source",
    step1: "Scarica il file .dmg o .zip",
    step2: "Trascina uni in Applicazioni",
    step3: "Avvia e organizza i tuoi corsi",
    dmg_showcase_hint: "Esperienza d'installazione refined: apri il .dmg e trascina semplicemente l'app nella cartella Applicazioni.",

    nav_faq: "FAQ",
    faq_badge: "FAQ & Assistenza",
    faq_title: "Domande Frequenti",
    faq_subtitle: "Tutto quello che c'è da sapere su compatibilità, sincronizzazione calendari, privacy e licenza di uni.",
    faq_q1: "Cos'è uni e quali vantaggi offre rispetto ad altre app?",
    faq_a1: "uni è un workspace accademico sviluppato nativamente per macOS in Swift e AppKit. A differenza di app web o basate su Electron, è ultra-reattiva, consuma pochissima memoria RAM (&lt;40 MB), funziona al 100% offline ed è perfettamente integrata con il Finder e l'ecosistema Mac.",
    faq_q2: "Quali versioni di macOS e processori Mac sono supportati?",
    faq_a2: "uni è compilata come binario Universale nativo per macOS 13.0 (Ventura), macOS 14.0 (Sonoma) e macOS 15.0 (Sequoia) o successivi, pienamente compatibile sia con processori Apple Silicon (M1, M2, M3, M4) che con processori Intel.",
    faq_q3: "Come funziona la sincronizzazione con i calendari universitari (Esse3, Cineca)?",
    faq_a3: "uni supporta lo standard iCalendar (iCal/webcal RFC 5545). È sufficiente incollare il link del feed o importare il file .ics fornito dal proprio ateneo: l'app ripulisce i titoli da codici inutili, individua docenti, aule ed imposta l'orario settimanale rigoroso a 24 ore.",
    faq_q4: "I miei dati accademici e le mie email sono al sicuro e privati?",
    faq_a4: "Sì, al 100%. uni segue una rigida politica di privacy locale: nessun dato viene mai inviato a server esterni, non è presente alcuna telemetria o tracciamento e le comunicazioni con Outlook avvengono solo tramite AppleScript locale sul tuo Mac.",
    faq_q5: "L'app è gratuita e open source?",
    faq_a5: "Sì, uni è completamente gratuita e rilasciata con codice sorgente aperto sotto licenza libera MIT su GitHub, senza abbonamenti né acquisti in-app.",
    faq_q6: "Cosa significa gestione file Zero-Copy con il Finder?",
    faq_a6: "Quando colleghi dispense, slide o PDF a una materia in uni, i file rimangono esattamente nelle loro cartelle originali nel Finder tramite security-scoped bookmarks, senza occupare spazio su disco duplicato.",

    footer_privacy: "Privacy &amp; Cookie Policy",
    nav_home: "← Torna al sito",
    legal_badge: "Informativa Legale &amp; Privacy",
    legal_title: "Privacy Policy &amp; Cookie Policy",
    legal_updated: "Ultimo aggiornamento: 13 Settembre 2026",
    btn_back_home: "← Torna alla Homepage di uni",

    mobile_notice: "uni è concepita e sviluppata esclusivamente per Mac. Apri questo sito dal tuo computer per scaricare l'app.",
    mobile_copy_link: "Copia link per Mac",
    mobile_link_copied: "Link copiato! ✓",
    mobile_warning_text: "Disponibile solo per Mac • Download disabilitato su mobile",
    mobile_toast_msg: "uni è disponibile esclusivamente per Mac. Apri questo sito da un computer per scaricare l'app.",

    footer_sub: "Progettata con cura per gli studenti universitari su Mac.",
    footer_credit: "Designed by <a href=\"https://zinco.cc\" target=\"_blank\" rel=\"noopener\">zinco.cc</a>",
    footer_back_to_top: "↑ Torna in cima",
    footer_col_project: "Progetto",
    footer_col_resources: "Info &amp; Risorse",
    footer_tagline: "100% Locale • Offline First • Swift &amp; AppKit",

    help_badge: "SUPPORTO &amp; FEEDBACK • COMUNITÀ UNI",
    help_title: "Come possiamo aiutarti?",
    help_sub: "Segnala un bug o richiedi una nuova funzionalità per uni.",
    help_type_label: "TIPO DI SEGNALAZIONE",
    help_type_bug: "Segnala un Bug",
    help_type_feat: "Suggerisci Funzionalità",
    help_subject_label: "OGGETTO",
    help_subject_ph: "Es. 'Aggiungere filtro per semestre' o 'Errore import iCal'",
    help_desc_label: "DESCRIZIONE DETTAGLIATA",
    help_desc_ph: "Descrivi il comportamento riscontrato o la novità richiesta...",
    help_rating_label: "VALUTAZIONE GENERALE DI UNI",
    help_rating_low: "1 - Molto scarsa",
    help_rating_high: "5 - Eccellente",
    help_submit_btn: "Invia Feedback",
    help_submitting: "Invio in corso...",
    help_success_title: "Feedback inviato con successo! 🎉",
    help_success_desc: "Grazie per il tuo contributo: la tua risposta è stata registrata direttamente nel database di supporto di uni.",
    help_success_another: "Invia un'altra segnalazione",
    help_tip_title: "💡 Suggerimento per utenti Mac",
    help_tip_desc: "Se usi l'app uni per macOS, puoi inviare feedback direttamente dal pulsante <strong>?</strong> nella barra laterale, che allega automaticamente la versione del sistema.",

    notfound_badge: "ERRORE 404 • PAGINA NON TROVATA",
    notfound_title: "Questa pagina non è all'ordine del giorno.",
    notfound_desc: "Il link che hai seguito potrebbe essere errato, spostato o non più disponibile. Torna alla home o visita la pagina di supporto.",
    notfound_btn_home: "Torna alla Home",
    notfound_btn_help: "Centro Supporto &amp; Bug",
    notfound_q_features: "Orari 24h, Sezione NEXT, Zero-Copy",
    notfound_q_download: "Installazione per Apple Silicon &amp; Intel",
    notfound_q_support: "Segnala problemi o suggerisci novità"
  },

  en: {
    nav_features: "Features",
    nav_panoramica: "Overview",
    nav_preview: "Overview",
    nav_help: "Support",
    nav_download: "Download .dmg",
    footer_help: "Support &amp; Feedback",

    riquadro_stats: "01 / PERFORMANCE & STATS",
    riquadro_heading: "Hello Daniel 👋 your academic career is <strong>right on schedule</strong>",
    pill_gpa: "GPA: <strong>28.84</strong>",
    pill_exams: "🏆 <strong>14/18</strong> exams passed",
    pill_zerocopy: "⚡️ <strong>Zero-Copy</strong> Finder",
    pill_local: "🔒 <strong>100%</strong> Local on Mac",

    riquadro_yellow_title: "Next lecture: <strong>Software Engineering</strong>",
    riquadro_yellow_sub: "Room 3 • 11:30 AM (Synced from campus iCal)",
    riquadro_yellow_prof: "👨‍🏫 Prof. Bianchi • Today",

    riquadro_blue_label: "Academic Career Progress",
    riquadro_seg_triennale: "Bachelor",
    riquadro_seg_magistrale: "Master",
    riquadro_blue_status: "You are ahead of schedule 😊",
    riquadro_blue_sub: "138 / 180 ECTS earned • Graduation estimate: ~105.7",

    dock_overview: "Overview",
    dock_cal: "Calendar",
    dock_deadlines: "Deadlines",
    dock_exams: "Exams",
    dock_search: "Search",

    hero_badge: "100% Native Swift & AppKit for Mac",
    hero_title: "The academic app for Mac.<br><span class=\"hero-title-accent\">Crafted as it should be.</span>",
    hero_subtitle: "All your courses, 24-hour schedules synced from your university calendar, deadlines, exams, and Outlook mail. 100% native macOS, private and distraction-free.",
    hero_cta_dmg: "Download for Mac (.dmg)",
    hero_cta_sub: "Universal • Apple Silicon & Intel",
    hero_cta_github: "View on GitHub",

    stat_privacy: "100% Private & Local to your Mac",
    stat_sync: "Strict 24h iCal Format",
    stat_search: "Global Search Palette",
    stat_nocopy: "Zero-Copy Linked Files",

    pill_title: "Deadline Completed",
    pill_desc: "Final Project archived successfully 🎉",
    pill_test_btn: "Test notification",

    mock_search: "Search courses...",
    mock_group_general: "GENERAL",
    mock_nav_overview: "Overview",
    mock_nav_cal: "Calendar",
    mock_group_didactics: "COURSES & WORK",
    mock_nav_courses: "Courses (6)",
    mock_nav_deadlines: "Deadlines",
    mock_nav_exams: "Exams",
    mock_nav_assignments: "Assignments",

    mock_today_badge: "TODAY",
    mock_greeting: "“Excellence is not an act, but a habit.”",
    mock_add_deadline: "New Deadline",
    mock_stat_gpa: "Weighted GPA",
    mock_stat_base: "Graduation estimate: ~105.7",
    mock_stat_cfu: "Credits Earned",
    mock_stat_ontrack: "Right on schedule",
    mock_stat_next: "Next Exam Session",
    mock_stat_days: "In 9 days • Room 2B",

    mock_outlook_inbox: "Inbox • Microsoft Outlook Mac",
    mock_outlook_refresh: "Refresh",
    mock_courses_header: "ACTIVE COURSES & LINKED FILES (ZERO-COPY)",

    feat_badge: "Crafted for macOS",
    feat_title: "Everything you need for your studies.<br>Zero clutter.",
    feat_subtitle: "Designed to feel right at home with Finder, your campus calendar, and faculty emails.",

    bento1_tag: "01 / Overview & NEXT.",
    bento1_title: "Instant Overview & NEXT Widget",
    bento1_desc: "Get an immediate view of your next scheduled lecture and classroom, top-priority deadline, and upcoming exam session. Click any card to jump straight into that section.",

    bento2_tag: "02 / 24h Weekly Timetable.",
    bento2_title: "24h Weekly Timetable",
    bento2_desc: "Sync your university iCal/webcal calendar or configure classes manually. Rooms, professors, and class hours always at your fingertips.",

    bento3_tag: "03 / Deadlines & Priority.",
    bento3_title: "Prioritized Academic Deadlines",
    bento3_desc: "Minute-by-minute countdown, priority urgency tags, zero-copy linked study files, and course-specific filters.",

    bento4_tag: "04 / Grades & GPA Projection.",
    bento4_title: "Weighted GPA & Degree Projection",
    bento4_desc: "Automatic weighted average calculation, recorded credits (CFU/ECTS), and real-time degree starting score projection.",

    bento5_tag: "05 / Global Search ⌘K.",
    bento5_title: "Spotlight-Style Global Search ⌘K / ⌘F",
    bento5_desc: "Summon the macOS-native search palette at any time: instantly locate courses, PDF slides, exam dates, and lectures with interactive pill filters.",

    zoom_screenshot: "Click to zoom",

    dl_title: "Download uni for your Mac.",
    dl_desc: "Compatible with macOS (Apple Silicon & Intel). Download the .dmg disk image or build directly from the source on GitHub.",
    dl_btn_dmg: "Download uni for macOS (.dmg)",
    dl_btn_dmg_sub: "Universal • Apple Silicon & Intel",
    dl_btn_zip: "Download Archive (.zip)",
    dl_btn_zip_sub: "Complete Package • 1.1 MB",
    dl_btn_github: "Open GitHub Repository",
    dl_btn_github_sub: "Open Source Repository",
    step1: "Download the .dmg or .zip file",
    step2: "Drag uni to Applications",
    step3: "Launch and organize your courses",
    dmg_showcase_hint: "Refined installation experience: open the .dmg and drag the app into your Applications folder.",

    nav_faq: "FAQ",
    faq_badge: "FAQ & Support",
    faq_title: "Frequently Asked Questions",
    faq_subtitle: "Everything you need to know regarding compatibility, calendar syncing, privacy, and licensing for uni.",
    faq_q1: "What is uni and what makes it different from web-based tools?",
    faq_a1: "uni is an academic workspace crafted natively for macOS using Swift and AppKit. Unlike web wrappers or heavy Electron applications, it starts up instantly, uses minimal RAM (&lt;40 MB), works 100% offline, and integrates seamlessly with Finder and the Apple ecosystem.",
    faq_q2: "Which macOS versions and Mac processors are supported?",
    faq_a2: "uni is built as a Universal binary for macOS 13.0 (Ventura), macOS 14.0 (Sonoma), and macOS 15.0 (Sequoia) or newer, running at peak performance on Apple Silicon (M1, M2, M3, M4) and Intel Macs.",
    faq_q3: "How does university calendar synchronization work (Esse3, Cineca)?",
    faq_a3: "uni supports the iCalendar standard (iCal/webcal RFC 5545). Simply paste your university feed link or import an .ics file: uni cleans course titles, identifies lecturers and classrooms, and builds your 24-hour weekly timetable.",
    faq_q4: "Are my student records and faculty emails secure and private?",
    faq_a4: "Yes, 100%. uni enforces a strict offline-first, local-only architecture: no data is ever sent to external cloud servers, there is zero telemetry tracking, and Outlook integration executes purely via local AppleScript on your Mac.",
    faq_q5: "Is uni free and open source?",
    faq_a5: "Yes, uni is completely free and released under the permissive open-source MIT License on GitHub, with no subscriptions or in-app purchases.",
    faq_q6: "What is Zero-Copy linked file management with Finder?",
    faq_a6: "When you link lecture slides or syllabus PDFs to a subject, files remain in their original folders in Finder via security-scoped bookmarks, without wasting duplicate SSD storage space.",

    footer_privacy: "Privacy &amp; Cookie Policy",
    nav_home: "← Back to Home",
    legal_badge: "Legal &amp; Privacy Notice",
    legal_title: "Privacy Policy &amp; Cookie Policy",
    legal_updated: "Last updated: September 13, 2026",
    btn_back_home: "← Back to uni Homepage",

    pol_sec1_title: "1. Data Controller",
    pol_sec1_desc: "This document describes the privacy practices of the website <strong>https://uni.zinco.cc/</strong> and the macOS application <strong>uni</strong> with respect to the processing of personal data pursuant to the EU General Data Protection Regulation (GDPR 2016/679).",
    pol_sec1_owner: "The Data Controller is <strong>zinco.cc</strong> (<a href=\"https://zinco.cc\" target=\"_blank\" rel=\"noopener\">zinco.cc</a>), reachable via the official GitHub repository at <a href=\"https://github.com/zjncoo/uni\" target=\"_blank\" rel=\"noopener\">zjncoo/uni</a> or through contact channels on zinco.cc.",

    pol_sec2_title: "2. Privacy in the macOS Application \"uni\"",
    pol_sec2_highlight_title: "100% Local &amp; Offline-First Privacy",
    pol_sec2_highlight_desc: "The uni desktop application does not collect, transmit, or store any personal data on remote servers or third-party platforms.",
    pol_sec2_p1_title: "No Account or Sign-up:",
    pol_sec2_p1_desc: "No account creation, login, or personal profile is required to use the software.",
    pol_sec2_p2_title: "Local Academic Data:",
    pol_sec2_p2_desc: "Courses, timetable schedules, exam dates, recorded grades, deadlines, and personal notes remain exclusively on your local Mac disk storage.",
    pol_sec2_p3_title: "Zero-Copy File Linking:",
    pol_sec2_p3_desc: "Syllabi, PDFs, and slide decks linked to your courses remain in your selected Finder directories. uni only retains security-scoped bookmarks without duplicating or uploading files.",
    pol_sec2_p4_title: "Calendar Sync (iCal):",
    pol_sec2_p4_desc: "University iCal/webcal feeds are retrieved via direct, encrypted network connections between your Mac and your campus portal without third-party intermediaries.",
    pol_sec2_p5_title: "Microsoft Outlook Integration:",
    pol_sec2_p5_desc: "Outlook mail integration operates entirely locally via macOS AppleScript Automation. The app never asks for passwords or relays email contents externally.",
    pol_sec2_p6_title: "Zero Telemetry &amp; Tracking:",
    pol_sec2_p6_desc: "uni contains zero advertising SDKs, tracking libraries, or analytics telemetry.",

    pol_sec3_title: "3. Website Data Processing",
    pol_sec3_desc: "The website <strong>https://uni.zinco.cc/</strong> is a static informational site hosted on <strong>GitHub Pages</strong> provided by GitHub Inc. (Microsoft Corporation).",
    pol_sec3_logs: "During visits, GitHub servers may automatically record standard technical access logs (IP address, timestamp, browser User-Agent, requested files) necessary to secure infrastructure and prevent abuse, governed by the GitHub General Privacy Statement.",

    pol_sec4_title: "4. Cookie Policy",
    pol_sec4_desc: "This section details the use of cookies and local storage on our website under the ePrivacy Directive and GDPR.",
    pol_sec4_highlight_title: "Zero Profiling or Advertising Tracking Cookies",
    pol_sec4_highlight_desc: "This site DOES NOT use profiling cookies, DOES NOT use tracking pixels (such as Meta Pixel or Google Ads), and DOES NOT sell data to third parties.",
    pol_sec4_types_title: "Storage &amp; Technologies Employed:",
    th_tool: "Tool",
    th_type: "Category",
    th_purpose: "Purpose",
    th_duration: "Duration",
    badge_tech: "Local Technical",
    badge_service: "External Service",
    cookie_row1_desc: "Stores user's chosen language preference (Italian or English) to display the website in the requested language on subsequent visits.",
    cookie_row1_dur: "Persistent (until browser data is cleared)",
    cookie_row2_desc: "Web typography delivery (Inter &amp; JetBrains Mono) via Google CDN. Does not install tracking cookies on your device.",
    cookie_row2_dur: "Browsing session",
    cookie_row3_desc: "Anonymous client-side HTTP request to api.github.com to query the latest available app release assets.",
    cookie_row3_dur: "Temporary / No cookies",
    pol_sec4_nobanner: "Because this site exclusively utilizes essential technical storage and operates without profiling or cross-site tracking cookies, prior cookie banner consent is not required under applicable law.",
    pol_sec4_manage_title: "Managing or Clearing Browser Storage",
    pol_sec4_manage_desc: "You may clear local site storage at any time through your browser privacy settings (Safari, Chrome, Firefox).",

    pol_sec5_title: "5. User Rights (GDPR)",
    pol_sec5_desc: "Under Articles 15-22 of the GDPR, users hold the right to access, rectify, erase, or restrict processing of their personal data, or submit complaints to data protection authorities.",
    pol_sec5_r1: "Access any personal data processed and receive copies;",
    pol_sec5_r2: "Request rectification of inaccurate or incomplete data;",
    pol_sec5_r3: "Request deletion of data (\"right to be forgotten\");",
    pol_sec5_r4: "Restrict or object to processing on legitimate grounds;",
    pol_sec5_r5: "Lodge a complaint with a supervisory authority (e.g. Garante Privacy).",
    pol_sec5_note: "Since uni stores no student data on servers, exercising your rights is instantly accomplished by removing the app from your Mac or clearing browser storage.",

    pol_sec6_title: "6. Changes &amp; Updates",
    pol_sec6_desc: "The Data Controller reserves the right to update this policy to reflect legal or technical revisions. The latest version will always be published on this page with the revision date.",

    mobile_notice: "uni is crafted and developed exclusively for Mac. Open this site on your computer to download the app.",
    mobile_copy_link: "Copy link for Mac",
    mobile_link_copied: "Link copied! ✓",
    mobile_warning_text: "Available only for Mac • Download disabled on mobile",
    mobile_toast_msg: "uni is available exclusively for Mac. Open this site on a computer to download the app.",

    footer_sub: "Carefully designed for university students on Mac.",
    footer_credit: "Designed by <a href=\"https://zinco.cc\" target=\"_blank\" rel=\"noopener\">zinco.cc</a>",
    footer_back_to_top: "↑ Back to top",
    footer_col_project: "Project",
    footer_col_resources: "Info &amp; Resources",
    footer_tagline: "100% Local • Offline First • Swift &amp; AppKit",

    help_badge: "SUPPORT &amp; FEEDBACK • UNI COMMUNITY",
    help_title: "How can we help?",
    help_sub: "Report a bug or suggest a new feature for uni.",
    help_type_label: "SUBMISSION TYPE",
    help_type_bug: "Bug Report",
    help_type_feat: "Feature Request",
    help_subject_label: "SUBJECT",
    help_subject_ph: "E.g. 'Add semester filter' or 'iCal import issue'",
    help_desc_label: "DETAILED DESCRIPTION",
    help_desc_ph: "Describe the issue encountered or the desired feature...",
    help_rating_label: "OVERALL RATING OF UNI",
    help_rating_low: "1 - Very Poor",
    help_rating_high: "5 - Excellent",
    help_submit_btn: "Submit Feedback",
    help_submitting: "Submitting...",
    help_success_title: "Feedback submitted successfully! 🎉",
    help_success_desc: "Thank you for your contribution! Your feedback has been recorded directly in the uni support database.",
    help_success_another: "Submit another response",
    help_tip_title: "💡 Tip for Mac users",
    help_tip_desc: "If you're using the uni Mac app, you can submit feedback directly via the <strong>?</strong> button in the sidebar, which automatically attaches system diagnostic info.",

    notfound_badge: "ERROR 404 • PAGE NOT FOUND",
    notfound_title: "This page is not on the syllabus.",
    notfound_desc: "The link you followed may be incorrect, moved, or no longer available. Head back home or visit our support page.",
    notfound_btn_home: "Back to Home",
    notfound_btn_help: "Support &amp; Bug Center",
    notfound_q_features: "24h Schedules, NEXT section, Zero-Copy",
    notfound_q_download: "Installer for Apple Silicon &amp; Intel",
    notfound_q_support: "Report issues or suggest features"
  }
};

// ===================================================================
// 2. Language Detection & Switching
// ===================================================================
let currentLanguage = 'it';
window.i18n = i18n;
window.currentLanguage = currentLanguage;

function detectInitialLanguage() {
  // 1. Check local storage
  const saved = localStorage.getItem('uni_site_lang');
  if (saved && (saved === 'it' || saved === 'en')) {
    return saved;
  }
  // 2. Check browser language (navigator.language)
  const browserLang = (navigator.language || navigator.userLanguage || 'en').toLowerCase();
  if (browserLang.startsWith('it')) {
    return 'it';
  }
  return 'en';
}

function setLanguage(lang) {
  currentLanguage = lang;
  window.currentLanguage = lang;
  localStorage.setItem('uni_site_lang', lang);
  document.documentElement.lang = lang;

  // Update language switcher UI active class
  document.querySelectorAll('.lang-option').forEach(el => {
    el.classList.toggle('active', el.getAttribute('data-lang') === lang);
  });

  // Update all translatable elements with data-i18n
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (i18n[lang] && i18n[lang][key]) {
      el.innerHTML = i18n[lang][key];
    }
  });

  // Update translatable placeholders with data-i18n-placeholder
  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (i18n[lang] && i18n[lang][key]) {
      el.setAttribute('placeholder', i18n[lang][key]);
    }
  });

  // Update dynamic date in mockup
  updateMockupDate(lang);
}

function initLanguageSwitcher() {
  const switchPill = document.getElementById('langSwitch');
  if (switchPill) {
    switchPill.addEventListener('click', () => {
      const nextLang = currentLanguage === 'it' ? 'en' : 'it';
      setLanguage(nextLang);
    });

    switchPill.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        const nextLang = currentLanguage === 'it' ? 'en' : 'it';
        setLanguage(nextLang);
      }
    });
  }
}

// ===================================================================
// 3. Dynamic Mockup Date
// ===================================================================
function updateMockupDate(lang) {
  const now = new Date();
  const dayNameEl = document.getElementById('heroDayName') || document.getElementById('mockDayName');
  const dayNumEl = document.getElementById('heroDayNum') || document.getElementById('mockDayNum');
  const fullDateEl = document.getElementById('mockFullDate');

  if (dayNumEl) {
    dayNumEl.textContent = now.getDate();
  }

  const locale = lang === 'it' ? 'it-IT' : 'en-US';
  if (dayNameEl) {
    const shortDay = now.toLocaleDateString(locale, { weekday: 'short' }).replace('.', '').toUpperCase();
    dayNameEl.textContent = shortDay;
  }
  if (fullDateEl) {
    const full = now.toLocaleDateString(locale, { weekday: 'long', day: 'numeric', month: 'long' });
    fullDateEl.textContent = full.charAt(0).toUpperCase() + full.slice(1);
  }
}

// ===================================================================
// 4. Latest GitHub Release & Dynamic Download Synchronizer
// ===================================================================
const GITHUB_REPO = "zjncoo/uni";
const GITHUB_LATEST_RELEASE_API = `https://api.github.com/repos/${GITHUB_REPO}/releases/latest`;
const CANONICAL_DMG_URL = `https://github.com/${GITHUB_REPO}/releases/latest/download/uni.dmg`;
const CANONICAL_ZIP_URL = `https://github.com/${GITHUB_REPO}/releases/latest/download/uni-macos.zip`;

async function fetchLatestGitHubRelease() {
  const heroBtn = document.getElementById('heroDownloadBtn');
  const mainBtn = document.getElementById('mainDownloadBtn');
  const zipBtn = document.getElementById('zipDownloadBtn');
  const heroMeta = document.getElementById('heroDmgMeta');
  const mainMeta = document.getElementById('mainDmgMeta');
  const zipMeta = document.getElementById('zipMeta');

  try {
    const res = await fetch(GITHUB_LATEST_RELEASE_API, {
      headers: { 'Accept': 'application/vnd.github.v3+json' }
    });

    if (res.ok) {
      const data = await res.json();
      const tagName = data.tag_name || 'v1.0.0';
      const assets = data.assets || [];

      // Find DMG asset
      const dmgAsset = assets.find(a => a.name.toLowerCase().endsWith('.dmg'));
      if (dmgAsset && dmgAsset.browser_download_url) {
        if (heroBtn) heroBtn.href = dmgAsset.browser_download_url;
        if (mainBtn) mainBtn.href = dmgAsset.browser_download_url;
        const mb = (dmgAsset.size / (1024 * 1024)).toFixed(1);
        const metaStr = `${tagName} • ${mb} MB • Apple Silicon & Intel`;
        if (heroMeta) heroMeta.textContent = metaStr;
        if (mainMeta) mainMeta.textContent = metaStr;
      }

      // Find ZIP asset
      const zipAsset = assets.find(a => a.name.toLowerCase().endsWith('.zip'));
      if (zipAsset && zipAsset.browser_download_url) {
        if (zipBtn) zipBtn.href = zipAsset.browser_download_url;
        const mb = (zipAsset.size / (1024 * 1024)).toFixed(1);
        if (zipMeta) zipMeta.textContent = `${tagName} • ${mb} MB`;
      }
    } else {
      // Fall back directly to the canonical GitHub Release download URL
      console.info("Using canonical GitHub Release URLs.");
      if (heroBtn) heroBtn.href = CANONICAL_DMG_URL;
      if (mainBtn) mainBtn.href = CANONICAL_DMG_URL;
      if (zipBtn) zipBtn.href = CANONICAL_ZIP_URL;
    }
  } catch (err) {
    console.warn("Unable to reach GitHub API; defaulting to canonical release URLs:", err);
    if (heroBtn) heroBtn.href = CANONICAL_DMG_URL;
    if (mainBtn) mainBtn.href = CANONICAL_DMG_URL;
    if (zipBtn) zipBtn.href = CANONICAL_ZIP_URL;
  }
}

let toastTimeout = null;

function showMobileToast(msg) {
  const toast = document.getElementById('mobileToast');
  if (!toast) return;

  const defaultMsg = (i18n[currentLanguage] && i18n[currentLanguage].mobile_toast_msg) || 
    "uni è disponibile esclusivamente per Mac. Apri questo sito dal tuo computer per scaricare l'app.";
  const textSpan = toast.querySelector('.toast-message');
  if (textSpan) textSpan.innerHTML = msg || defaultMsg;

  toast.classList.add('is-visible');
  toast.setAttribute('aria-hidden', 'false');

  clearTimeout(toastTimeout);
  toastTimeout = setTimeout(() => {
    toast.classList.remove('is-visible');
    toast.setAttribute('aria-hidden', 'true');
  }, 3800);
}

function initDownloadButtons() {
  const heroBtn = document.getElementById('heroDownloadBtn');
  const mainBtn = document.getElementById('mainDownloadBtn');
  const zipBtn = document.getElementById('zipDownloadBtn');

  function isMobileContext() {
    return window.innerWidth <= 900 || /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
  }

  [heroBtn, mainBtn, zipBtn].forEach(btn => {
    if (btn) {
      btn.addEventListener('click', (e) => {
        if (isMobileContext()) {
          e.preventDefault();
          showMobileToast();
          return;
        }
      });
    }
  });

  // Query GitHub for live release updates
  fetchLatestGitHubRelease();
}

// ===================================================================
// 7. Screenshot Lightbox Modal
// ===================================================================
function initScreenshotLightbox() {
  const lightbox = document.getElementById('screenshotLightbox');
  const lightboxImg = document.getElementById('lightboxImg');
  const lightboxCaption = document.getElementById('lightboxCaption');
  const closeBtn = document.getElementById('lightboxCloseBtn');
  const backdrop = document.getElementById('lightboxBackdrop');

  if (!lightbox || !lightboxImg) return;

  function openLightbox(src, caption) {
    lightboxImg.src = src;
    if (lightboxCaption) lightboxCaption.textContent = caption || '';
    lightbox.classList.add('active');
    lightbox.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
  }

  function closeLightbox() {
    lightbox.classList.remove('active');
    lightbox.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
  }

  document.querySelectorAll('.bento-screenshot-wrapper').forEach(wrapper => {
    wrapper.addEventListener('click', () => {
      const src = wrapper.getAttribute('data-screenshot');
      const caption = wrapper.getAttribute('data-caption');
      if (src) {
        openLightbox(src, caption);
      }
    });
  });

  if (closeBtn) closeBtn.addEventListener('click', closeLightbox);
  if (backdrop) backdrop.addEventListener('click', closeLightbox);

  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && lightbox.classList.contains('active')) {
      closeLightbox();
    }
  });
}

// ===================================================================
// 8. Mobile Fullscreen Navigation Menu
// ===================================================================
function initMobileMenu() {
  const hamburger = document.getElementById('navHamburger');
  const menuOverlay = document.getElementById('mobileMenu');
  const copyBtn = document.getElementById('btnCopyMacLink');

  if (!hamburger || !menuOverlay) return;

  function toggleMenu(forceOpen) {
    const shouldOpen = typeof forceOpen === 'boolean' ? forceOpen : !menuOverlay.classList.contains('is-open');
    menuOverlay.classList.toggle('is-open', shouldOpen);
    hamburger.classList.toggle('is-open', shouldOpen);
    hamburger.setAttribute('aria-expanded', shouldOpen ? 'true' : 'false');
    menuOverlay.setAttribute('aria-hidden', shouldOpen ? 'false' : 'true');
    document.body.style.overflow = shouldOpen ? 'hidden' : '';
  }

  hamburger.addEventListener('click', () => toggleMenu());

  // Close when clicking internal links
  menuOverlay.querySelectorAll('[data-menu-close]').forEach(link => {
    link.addEventListener('click', () => {
      toggleMenu(false);
    });
  });

  // Close with Escape key
  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && menuOverlay.classList.contains('is-open')) {
      toggleMenu(false);
    }
  });

  // Close if viewport expands to desktop
  window.addEventListener('resize', () => {
    if (window.innerWidth > 900 && menuOverlay.classList.contains('is-open')) {
      toggleMenu(false);
    }
  });

  // Copy Mac link functionality
  if (copyBtn) {
    copyBtn.addEventListener('click', async () => {
      const urlToCopy = window.location.href.split('#')[0];
      try {
        await navigator.clipboard.writeText(urlToCopy);
        const textSpan = copyBtn.querySelector('.copy-text');
        const origText = textSpan ? textSpan.textContent : '';
        const copiedMsg = (i18n[currentLanguage] && i18n[currentLanguage].mobile_link_copied) || 'Link copiato! ✓';
        if (textSpan) textSpan.textContent = copiedMsg;
        copyBtn.classList.add('copied');
        setTimeout(() => {
          if (textSpan) textSpan.textContent = origText;
          copyBtn.classList.remove('copied');
        }, 2200);
      } catch (err) {
        console.warn('Clipboard write error:', err);
      }
    });
  }
}

// ===================================================================
// 9. Back To Top Smooth Scroll
// ===================================================================
function initBackToTop() {
  const btn = document.getElementById('btnBackToTop');
  if (btn) {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }
}

// ===================================================================
// 10. Initialize Application
// ===================================================================
document.addEventListener('DOMContentLoaded', () => {
  const initialLang = detectInitialLanguage();
  setLanguage(initialLang);
  initLanguageSwitcher();
  initDownloadButtons();
  initScreenshotLightbox();
  initMobileMenu();
  initBackToTop();
});


