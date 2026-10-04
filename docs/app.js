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
    faq_a4: "Sì, al 100%. I tuoi dati personali e accademici (corsi, orari, appelli, voti, note e file collegati) sono salvati esclusivamente in locale sul tuo Mac. L'app non possiede server proprietari, non fa telemetria né profilazione e interagisce con Outlook solo tramite AppleScript locale. Le uniche connessioni di rete facoltative avvengono solo su tua iniziativa (sincronizzazione iCal ateneo, verifica aggiornamenti GitHub e invio volontario di feedback).",
    faq_q5: "L'app è gratuita e open source?",
    faq_a5: "Sì, uni è completamente gratuita e rilasciata con codice sorgente aperto sotto licenza libera MIT su GitHub, senza abbonamenti né acquisti in-app.",
    faq_q6: "Cosa significa gestione file Zero-Copy con il Finder?",
    faq_a6: "Quando colleghi dispense, slide o PDF a una materia in uni, i file rimangono esattamente nelle loro cartelle originali nel Finder tramite security-scoped bookmarks, senza occupare spazio su disco duplicato.",

    footer_privacy: "Privacy &amp; Cookie Policy",
    footer_terms: "Termini di Servizio",
    nav_home: "← Torna al sito",
    legal_badge: "Informativa Legale &amp; Privacy",
    legal_title: "Privacy Policy &amp; Cookie Policy",
    legal_updated: "Ultimo aggiornamento: 4 Ottobre 2026",
    btn_back_home: "← Torna alla Homepage di uni",

    pol_sec1_title: "1. Titolare del Trattamento (Data Controller)",
    pol_sec1_desc: "Il presente documento descrive le modalità di gestione del sito web <strong>https://uni.zinco.cc/</strong> e dell'applicazione software per macOS denominata <strong>uni</strong> con riferimento al trattamento dei dati personali degli utenti, in conformità al Regolamento Generale sulla Protezione dei Dati dell'Unione Europea (GDPR - Regolamento UE 2016/679), al D.Lgs. 196/2003 (Codice Privacy italiano, come modificato dal D.Lgs. 101/2018) e agli standard internazionali di riservatezza.",
    pol_sec1_contact_title: "Canale di Contatto Ufficiale del Titolare",
    pol_sec1_contact_desc: "Il Titolare del Trattamento è <strong>Francesco Zanchetta</strong> (<a href=\"https://zinco.cc\" target=\"_blank\" rel=\"noopener\">zinco.cc</a>). Per qualsiasi richiesta relativa alla privacy, all'esercizio dei diritti GDPR (accesso, cancellazione, opposizione) o a chiarimenti legali, è possibile contattare direttamente il Titolare all'indirizzo email dedicato: <a href=\"mailto:work@zinco.cc\"><strong>work@zinco.cc</strong></a> oppure tramite issue sulla repository ufficiale di GitHub (<a href=\"https://github.com/zjncoo/uni\" target=\"_blank\" rel=\"noopener\">github.com/zjncoo/uni</a>).",

    pol_sec2_title: "2. Architettura dell'Applicazione macOS: Dati Locali e Comunicazioni di Rete",
    pol_sec2_highlight_title: "Privacy al 100% Locale per i Tuoi Dati Accademici",
    pol_sec2_highlight_desc: "Tutti i tuoi dati personali e accademici (corsi, orari, appelli, voti, scadenze, note e allegati) rimangono archiviati esclusivamente in locale sul tuo Mac. L'applicazione uni non possiede un backend proprietario e non carica, non analizza né vende mai i tuoi contenuti di studio.",
    pol_sec2_p1_title: "Nessun Account né Profilazione:",
    pol_sec2_p1_desc: "L'uso dell'applicazione non richiede registrazione, creazione di account, email né password.",
    pol_sec2_p2_title: "Archiviazione Locale &amp; Sandboxing:",
    pol_sec2_p2_desc: "Il database dei corsi e degli esami risiede unicamente nel file system locale protetto dal sandboxing di macOS (App Sandbox).",
    pol_sec2_p3_title: "Gestione File Zero-Copy:",
    pol_sec2_p3_desc: "Slide, dispense e PDF rimangono nelle cartelle del Finder dell'utente; uni memorizza solo un segnalibro di sicurezza locale (security-scoped bookmark) senza duplicarli né trasmetterli al cloud.",
    pol_sec2_p4_title: "Sincronizzazione Calendario (iCal/webcal):",
    pol_sec2_p4_desc: "Il recupero dei feed del calendario universitario avviene tramite richiesta diretta, cifrata e locale tra il Mac e l'indirizzo del server ateneo specificato dall'utente, senza intermediari o server proxy di terze parti.",
    pol_sec2_p5_title: "Integrazione Microsoft Outlook per Mac:",
    pol_sec2_p5_desc: "La lettura dell'inbox avviene unicamente in locale sul Mac sfruttando lo scripting AppleScript di sistema con specifica autorizzazione AppleEvents. Nessuna credenziale né contenuto email viene mai trasmesso all'esterno.",
    pol_sec2_p6_title: "Assenza di Telemetria Nascosta:",
    pol_sec2_p6_desc: "uni non include SDK pubblicitari, librerie di profilazione, Google Analytics, Firebase o telemetria diagnostica invisibile in background.",
    pol_sec2_network_scope: "<strong>Perimetro delle comunicazioni di rete effettuate dall'app:</strong> Le sole connessioni di rete consentite ed effettuate dall'applicazione desktop sono: (1) il download diretto del file calendario .ics dai server universitari configurati dall'utente; (2) il controllo facoltativo di nuove versioni software tramite le API pubbliche di GitHub Releases; (3) l'invio facoltativo e volontario di segnalazioni di bug o suggerimenti tramite modulo integrato (disciplinato alla Sezione 3).",

    pol_sec3_title: "3. Raccolta Feedback e Segnalazioni di Bug (Google Forms)",
    pol_sec3_intro: "Sia all'interno dell'applicazione per macOS (tramite il pannello <em>Supporto &amp; Feedback</em>) sia attraverso il sito web (alla pagina <a href=\"help.html\">help.html</a>), l'utente ha la facoltà opzionale di inviare segnalazioni tecniche o suggerimenti allo sviluppatore.",
    pol_sec3_fields_title: "Tipologia di Dati Raccolti e Minimizzazione",
    pol_sec3_fields_desc: "In ossequio al principio di <strong>minimizzazione dei dati</strong> (Art. 5, par. 1, lett. c, GDPR), il modulo raccoglie esclusivamente le informazioni strettamente necessarie a comprendere e riprodurre l'anomalia o valutare la richiesta:",
    pol_sec3_f1_title: "Tipologia di invio:",
    pol_sec3_f1_desc: "Segnalazione di un malfunzionamento (Bug Report) o proposta di nuova funzionalità (Feature Request).",
    pol_sec3_f2_title: "Oggetto e Descrizione:",
    pol_sec3_f2_desc: "Testo sintetico e dettagliato relativo alla problematica o all'idea proposta dall'utente.",
    pol_sec3_f3_title: "Valutazione Complessiva:",
    pol_sec3_f3_desc: "Punteggio da 1 a 5 stelline per misurare la soddisfazione complessiva d'uso.",
    pol_sec3_f4_title: "Informazioni Diagnostiche Facoltative:",
    pol_sec3_f4_desc: "Se spuntato dall'utente nell'app Mac, viene allegata unicamente la stringa diagnostica tecnica non identificabile (es. uni v1.5.1 • macOS 15.0 • Apple Silicon). Nessun identificativo hardware univoco, UUID utente o indirizzo MAC viene allegato.",
    pol_sec3_warn_title: "Avvertenza di Non Inserimento Dati Personali o Particolari",
    pol_sec3_warn_desc: "Si raccomanda espressamente all'utente di <strong>non inserire nei campi di testo libero dati personali identificativi</strong> (nome, cognome, numero di telefono), credenziali d'accesso (password), numeri di matricola universitaria né categorie particolari di dati personali (dati sanitari, convinzioni religiose o filosofiche ai sensi dell'Art. 9 GDPR).",
    pol_sec3_legal_basis_title: "Base Giuridica e Consenso Esplicito",
    pol_sec3_legal_basis_desc: "La base giuridica del trattamento è il <strong>consenso esplicito e informato dell'interessato</strong> ai sensi dell'Art. 6, par. 1, lett. a, del GDPR. Il consenso viene prestato dall'utente mediante azione positiva inequivocabile, contrassegnando l'apposita casella di spunta obbligatoria (checkbox) presente nel modulo prima dell'invio.",
    pol_sec3_retention_title: "Tempi di Conservazione (Data Retention) &amp; Cancellazione",
    pol_sec3_retention_desc: "Le segnalazioni inviate vengono conservate su fogli di calcolo Google associati all'infrastruttura di zinco.cc per un periodo massimo di <strong>12 (dodici) mesi</strong> dalla data di ricezione, decorso il quale vengono eliminate definitivamente durante le revisioni semestrali di manutenzione del database.",
    pol_sec3_deletion_workflow: "<strong>Procedura di cancellazione immediata su richiesta:</strong> Ciascun utente ha il diritto di richiedere la cancellazione anticipata della propria segnalazione in qualsiasi momento inviando un'email a work@zinco.cc specificando la data approssimativa e l'oggetto.",

    pol_sec4_title: "4. Trattamento Dati sul Sito Web e Log di Infrastruttura",
    pol_sec4_desc: "Il sito web <strong>https://uni.zinco.cc/</strong> è ospitato sull'infrastruttura di <strong>GitHub Pages</strong>, gestita da GitHub Inc. (Microsoft Corporation, 88 Colin P Kelly Jr St, San Francisco, CA 94107, USA).",
    pol_sec4_logs: "Durante la navigazione sul sito o l'interrogazione delle API di release dall'app (api.github.com), i server di GitHub possono registrare automaticamente dati tecnici di connessione (indirizzo IP, User-Agent, referer, timestamp, file richiesto) sulla base del legittimo interesse a prevenire attacchi informatici e garantire stabilità.",
    pol_sec4_gh_privacy: "Per ulteriori dettagli sulle modalità di trattamento di GitHub, consulta la GitHub General Privacy Statement.",

    pol_sec5_title: "5. Cookie Policy &amp; Tecnologie di Memorizzazione Locale",
    pol_sec5_desc: "Questa sezione illustra le tecnologie di memorizzazione locale e le richieste esterne del sito in ossequio alla Direttiva ePrivacy 2002/58/CE e al Provvedimento del Garante Privacy del 10 giugno 2021.",
    pol_sec5_highlight_title: "Zero Cookie di Profilazione o Tracciamento Pubblicitario",
    pol_sec5_highlight_desc: "Questo sito NON fa uso di cookie di profilazione, NON utilizza pixel di tracciamento commerciale (come Meta Pixel, Google Ads, TikTok Pixel) e NON cede alcun dato ad aggregatori terzi.",
    pol_sec5_table_title: "Dettaglio Strumenti Tecnici &amp; Servizi di Terze Parti:",
    th_tool: "Strumento",
    th_type: "Tipologia",
    th_purpose: "Finalità",
    th_duration: "Durata",
    badge_tech: "Tecnico Locale",
    badge_service: "Servizio Esterno",
    cookie_row1_desc: "Memorizza la lingua scelta (Italiano o Inglese) per offrire la versione corretta nelle visite future. Non contiene identificativi personali.",
    cookie_row1_dur: "Persistente (fino a cancellazione manuale)",
    cookie_row2_desc: "Erogazione dei caratteri tipografici (Inter, JetBrains Mono, IBM Plex Serif) ospitati al 100% in locale sul server del sito. Zero chiamate a server Google e zero trasmissione dell'indirizzo IP a soggetti terzi.",
    cookie_row2_dur: "Sessione / Cache del browser",
    cookie_row3_desc: "Chiamata HTTP client-side anonima verso api.github.com per verificare la versione più recente del pacchetto .dmg per macOS.",
    cookie_row3_dur: "Temporanea (Nessun cookie)",
    cookie_row4_desc: "Invocato unicamente all'atto dell'invio volontario di un feedback da parte dell'utente per trasmettere il testo della segnalazione.",
    cookie_row4_dur: "Transazione singola (Nessun cookie)",
    pol_sec5_nobanner: "Poiché il sito impiega unicamente strumenti tecnici indispensabili e non fa uso di cookie di profilazione o tracciamento incrociato, ai sensi della normativa vigente non è necessaria la richiesta di consenso preventivo tramite banner cookie.",

    pol_sec6_title: "6. Tutela dei Minori e Requisiti di Età",
    pol_sec6_desc: "I servizi di <strong>uni</strong> e i relativi canali web sono concepiti per una platea universitaria, di formazione superiore e professionale. L'accesso è riservato a utenti che abbiano compiuto almeno <strong>16 anni</strong> (o la diversa età minima prevista dallo Stato membro di appartenenza per la prestazione autonoma del consenso digitale, ai sensi dell'Art. 8 GDPR e dell'Art. 2-quinquies del Codice Privacy italiano).",
    pol_sec6_coppa: "uni non raccoglie consapevolmente né richiede dati personali relativi a soggetti minori di anni 16 (o di anni 13 per gli utenti soggetti al Children's Online Privacy Protection Act - COPPA degli Stati Uniti).",
    pol_sec6_parents_title: "Procedura per Genitori ed Esercenti la Responsabilità Genitoriale",
    pol_sec6_parents_desc: "Nel caso in cui un genitore o tutore legale riscontri che un minore ha inviato dati personali tramite il modulo di feedback o canali correlati senza autorizzazione, è pregato di darne tempestiva comunicazione a work@zinco.cc. Il Titolare procederà all'immediata verifica e cancellazione di tali informazioni da tutti gli archivi.",

    pol_sec7_title: "7. Trasferimenti di Dati verso Paesi Terzi (Extra-UE)",
    pol_sec7_desc: "Alcuni dei fornitori terzi di infrastruttura tecnologica utilizzati per l'erogazione del sito e la raccolta feedback (GitHub Inc. per GitHub Pages e Google LLC per Google Fonts e Google Forms) hanno sede legale negli Stati Uniti d'America.",
    pol_sec7_dpf: "Il trasferimento verso tali soggetti avviene nel pieno rispetto del Capo V del GDPR sulla base della Decisione di Adeguatezza della Commissione Europea del 10 luglio 2023 relativa al Data Privacy Framework (DPF) UE-USA, a cui sia Google LLC sia Microsoft/GitHub Inc. sono formalmente certificate, nonché tramite l'adozione di Clausole Contrattuali Standard (Standard Contractual Clauses - SCC).",

    pol_sec8_title: "8. Diritti dell'Interessato (GDPR Artt. 15-22)",
    pol_sec8_desc: "Ciascun utente ha il diritto di esercitare in qualsiasi momento i diritti sanciti dal Regolamento UE 2016/679:",
    pol_sec8_r1: "Diritto di accesso (Art. 15): Ottenere conferma dell'esistenza di dati personali che lo riguardano e riceverne copia;",
    pol_sec8_r2: "Diritto di rettifica (Art. 16): Ottenere la correzione di dati inesatti o l'integrazione di quelli incompleti;",
    pol_sec8_r3: "Diritto alla cancellazione («Diritto all'oblio», Art. 17): Chiedere la cancellazione definitiva dei dati di feedback forniti;",
    pol_sec8_r4: "Diritto di limitazione del trattamento (Art. 18): Richiedere la sospensione del trattamento in presenza delle condizioni di legge;",
    pol_sec8_r5: "Diritto di opposizione e revoca del consenso (Artt. 21 e 7): Revocare il consenso prestato per l'invio del feedback in ogni momento;",
    pol_sec8_r6: "Diritto di reclamo (Art. 77): Presentare formale reclamo all'Autorità Garante per la Protezione dei Dati Personali (www.garanteprivacy.it, Piazza Venezia 11, 00187 Roma).",
    pol_sec8_note: "Per esercitare i propri diritti in relazione ai feedback inviati, è sufficiente scrivere all'indirizzo work@zinco.cc. L'esercizio dei diritti è a titolo del tutto gratuito e verrà riscontrato entro il termine ordinario di 30 giorni. Per tutti i dati accademici memorizzati nell'app Mac, l'utente esercita il controllo totale e istantaneo gestendo o cancellando i dati direttamente dal disco rigido del proprio computer.",

    pol_sec9_title: "9. Modifiche e Revisioni",
    pol_sec9_desc: "Il Titolare si riserva il diritto di apportare modifiche alla presente informativa a seguito di evoluzioni legislative, implementazioni software o aggiornamenti dei servizi terzi. Le modifiche saranno pubblicate su questa pagina con indicazione della data di revisione.",

    // Terms of Use
    terms_badge: "Condizioni Generali • Accordo Legale",
    terms_title: "Termini di Servizio (Terms of Use)",
    terms_updated: "Ultimo aggiornamento: 4 Ottobre 2026",
    terms_sec1_title: "1. Accettazione dei Termini",
    terms_sec1_desc: "I presenti Termini di Servizio regolano l'accesso e l'utilizzo del sito web https://uni.zinco.cc/ e dell'applicazione software per macOS denominata uni, sviluppata e gestita da Francesco Zanchetta / zinco.cc.",
    terms_sec1_callout_title: "Accordo Vincolante",
    terms_sec1_callout_desc: "Scaricando, installando, copiando o utilizzando l'Applicazione, ovvero navigando sul Sito, l'utente dichiara di aver letto, compreso e accettato integralmente i presenti Termini e l'Informativa sulla Privacy. Qualora l'utente non intenda accettare i presenti Termini, deve astenersi dall'utilizzare il Software e il Sito ed eliminare ogni copia del Software in suo possesso.",
    terms_sec2_title: "2. Licenza Software (MIT) &amp; Proprietà Intellettuale",
    terms_sec2_p1: "Il codice sorgente dell'Applicazione è rilasciato come software libero e open-source con licenza MIT License, consultabile pubblicamente nella repository ufficiale su GitHub.",
    terms_sec2_p2: "In base alla licenza MIT, è concesso a chiunque il permesso gratuito di ottenere una copia del software per utilizzarlo, modificarlo, pubblicarlo, distribuirlo e concederlo in sublicenza, a condizione che l'avviso di copyright originario sia incluso in tutte le copie sostanziali.",
    terms_sec2_p3: "La concessione della licenza MIT sul codice sorgente non include il diritto di utilizzare o appropriarsi dei marchi commerciali, loghi distintivi, del brand design ('uni', 'zinco.cc') o dell'iconografia originale dell'app ('///'), che restano di titolarità esclusiva di Francesco Zanchetta / zinco.cc.",
    terms_sec3_title: "3. Uso Consentito e Condotta dell'Utente",
    terms_sec3_p1: "L'Applicazione è uno strumento destinato a fini personali, accademici e di produttività individuale per la gestione di orari delle lezioni, corsi, esami e note universitarie.",
    terms_sec3_p2: "È espressamente vietato all'utente:",
    terms_sec3_r1: "Inviare tramite il modulo di feedback contenuti illeciti, diffamatori, minacciosi, ingiuriosi, discriminatori o che violino diritti di terzi;",
    terms_sec3_r2: "Effettuare tentativi di attacco informatico, iniezione di codice malevolo, spam automatizzato, scraping non autorizzato o sovraccarico dell'infrastruttura del Sito o dei form di feedback;",
    terms_sec3_r3: "Utilizzare il Software per scopi illeciti o in contrasto con i regolamenti universitari e le leggi vigenti;",
    terms_sec3_r4: "Presentare l'Applicazione o se stessi come affiliati, rappresentanti o canali ufficiali di qualsiasi ateneo o ente terzo senza espressa autorizzazione.",
    terms_sec4_title: "4. Marchi di Terze Parti &amp; Clausola di Non Affiliazione (Nominative Fair Use)",
    terms_sec4_p1: "Tutti i nomi di prodotti, loghi, marchi e marchi registrati menzionati nel Sito e nell'Applicazione appartengono ai rispettivi proprietari:",
    terms_sec4_m1: "Apple Inc.: 'macOS', 'Mac', 'AppleScript', 'Finder', 'iCloud', 'Apple Silicon' sono marchi o marchi registrati di Apple Inc. negli Stati Uniti e in altri paesi.",
    terms_sec4_m2: "Microsoft Corporation: 'Microsoft', 'Microsoft Outlook', 'Windows', 'Exchange' sono marchi di Microsoft Corporation.",
    terms_sec4_m3: "Google LLC: 'Google', 'Google Calendar', 'Google Forms', 'Google Fonts' sono marchi di Google LLC.",
    terms_sec4_m4: "GitHub, Inc.: 'GitHub' è un marchio registrato di GitHub, Inc.",
    terms_sec4_m5: "Cineca Consorzio Interuniversitario: 'Esse3' è un marchio o software registrato da Cineca Consorzio Interuniversitario.",
    terms_sec4_disclaimer_title: "Clausola di Non Affiliazione e Uso Descrittivo",
    terms_sec4_disclaimer_desc: "L'uso di tali denominazioni avviene esclusivamente in funzione descrittiva e di compatibilità tecnica (nominative fair use). Né uni né zinco.cc sono sponsorizzati, approvati, affiliati o associati in alcun modo ad Apple Inc., Microsoft Corporation, Google LLC, GitHub Inc., Cineca o a qualsiasi università o istituto accademico menzionato nel software o nella documentazione.",
    terms_sec5_title: "5. Finalità Organizzativa e Indipendenza dalle Segreterie Ufficiali",
    terms_sec5_alert_title: "Avvertenza per gli Studenti: uni è un Ausilio, non un Portale Istituzionale",
    terms_sec5_alert_desc: "uni è un'applicazione indipendente progettata per agevolare l'organizzazione dello studio. Non costituisce in nessun caso il registro ufficiale dell'ateneo.",
    terms_sec5_desc: "Orari delle lezioni, aule, appelli d'esame, scadenze di iscrizione, calcoli della media ponderata (GPA) e stime del voto di base di laurea sono elaborati a scopo meramente indicativo e orientativo. L'Utente ha l'onere esclusivo di verificare sempre date, orari, aule e scadenze sui portali ufficiali del proprio ateneo (es. Esse3, portale studenti, bacheca avvisi del docente o comunicazioni istituzionali). Lo Sviluppatore declina ogni responsabilità per eventuali esami persi, iscrizioni tardive, scadenze mancate, errori nel calcolo dei crediti formativi (CFU) o variazioni di calendario non tempestivamente riflesse nei feed iCal.",
    terms_sec6_title: "6. Esclusione di Garanzie (\"AS IS\" &amp; \"AS AVAILABLE\")",
    terms_sec6_p1: "NELLA MISURA MASSIMA CONSENTITA DALLA LEGGE APPLICABILE, IL SOFTWARE E IL SITO WEB SONO FORNITI 'COSÌ COME SONO' ('AS IS') E 'COME DISPONIBILI' ('AS AVAILABLE'), SENZA GARANZIE DI ALCUN TIPO, ESPLICITE O IMPLICITE, INCLUSE LE GARANZIE IMPLICITE DI COMMERCIABILITÀ, IDONEITÀ PER UNO SCOPO PARTICOLARE, PRECISIONE, TITOLARITÀ E NON VIOLAZIONE DEI DIRITTI DI TERZI.",
    terms_sec6_p2: "LO SVILUPPATORE NON GARANTISCE CHE LE FUNZIONALITÀ DEL SOFTWARE SODDISFINO SPECIFICI REQUISITI DELL'UTENTE, CHE IL FUNZIONAMENTO SIA ININTERROTTO, PRIVO DI ERRORI O IMMUNE DA VULNERABILITÀ, NÉ CHE I FORMATI DEGLI EVENTI ICAL O L'INTERAZIONE CON MICROSOFT OUTLOOK RIMANGANO COMPATIBILI A SEGUITO DI FUTURE MODIFICHE AI SISTEMI OPERATIVI O A SOFTWARE TERZI.",
    terms_sec7_title: "7. Limitazione di Responsabilità",
    terms_sec7_p1: "NELLA MISURA MASSIMA CONSENTITA DALLA LEGGE, IN NESSUN CASO FRANCESCO ZANCHETTA, ZINCO.CC O COLLABORATORI POTRANNO ESSERE RITENUTI RESPONSABILI PER DANNI DIRETTI, INDIRETTI, INCIDENTALI, SPECIALI, ESEMPLARI, PUNITIVI O CONSEQUENZIALI (INCLUSI PERDITA DI DATI, MALFUNZIONAMENTI, ESAMI O SCADENZE PERSE, O DANNI ECONOMICI), DERIVANTI IN QUALSIASI MODO DALL'USO DEL SOFTWARE O DEL SITO.",
    terms_sec7_p2: "QUALORA IN DETERMINATE GIURISDIZIONI NON SIA AMMESSA L'ESCLUSIONE TOTALE DI DETERMINATE RESPONSABILITÀ, LA RESPONSABILITÀ COMPLESSIVA MASSIMA DEL TITOLARE SARÀ IN OGNI CASO LIMITATA ALL'IMPORTO EFFETTIVAMENTE CORRISPOSTO DALL'UTENTE (PARI A €0,00 - ZERO EURO).",
    terms_sec8_title: "8. Requisiti di Età e Minori",
    terms_sec8_desc: "L'Applicazione e il Sito sono rivolti a utenti universitari e a un pubblico maggiorenne o che abbia compiuto almeno 16 anni. Utilizzando il Software o inviando segnalazioni di feedback, l'Utente dichiara e garantisce di possedere l'età richiesta e la piena capacità giuridica di sottoscrivere il presente accordo.",
    terms_sec9_title: "9. Collegamenti a Siti e Servizi di Terze Parti",
    terms_sec9_desc: "Il Sito e l'Applicazione possono contenere link verso piattaforme esterne (GitHub, Google, calendari ateneo). Lo Sviluppatore non esercita alcun controllo su tali siti e declina ogni responsabilità per i loro contenuti o pratiche operative.",
    terms_sec10_title: "10. Legge Applicabile e Foro Competente",
    terms_sec10_desc: "I presenti Termini sono disciplinati dalla legge italiana. Fatti salvi i diritti inderogabili attribuiti agli utenti consumatori, per qualsiasi controversia nascente dai presenti Termini sarà competente in via esclusiva il Foro di Milano (Italia).",
    terms_sec11_title: "11. Clausola Salvatoria e Modifiche ai Termini",
    terms_sec11_desc: "L'eventuale nullità di una clausola non inficia la validità delle restanti disposizioni. Il Titolare si riserva il diritto di modificare i presenti Termini in qualsiasi momento.",
    terms_sec12_title: "12. Contatti Ufficiali",
    terms_sec12_desc: "Per chiarimenti sui presenti Termini o segnalazioni legali, è possibile contattare lo sviluppatore all'indirizzo email: work@zinco.cc.",

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
    help_privacy_box_title: "Privacy &amp; Minimizzazione dei Dati",
    help_privacy_box_desc: "Le segnalazioni inviate tramite questo modulo sono facoltative e vengono trattate su server Google Forms esclusivamente per finalità di supporto tecnico e miglioramento del software, con conservazione massima di 12 mesi. Per la tua sicurezza e privacy, non inserire dati personali riservati, numeri di matricola, password, email o dati sensibili. Per maggiori dettagli o per richiedere la cancellazione, consulta la nostra Privacy &amp; Cookie Policy.",
    help_consent_checkbox_text: "Ho letto l'Informativa sulla Privacy e acconsento all'invio e al trattamento di questo feedback.",
    help_consent_required: "È necessario accettare l'Informativa sulla Privacy per poter inviare il feedback.",
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
    faq_a4: "Yes, 100%. Your academic and personal data (courses, schedules, exams, grades, notes, and linked files) remain strictly local on your Mac. uni has no proprietary backend, performs zero tracking or telemetry, and interacts with Outlook only via local AppleScript. The only optional network connections occur solely on your initiative (university iCal sync, GitHub updates check, and voluntary feedback submissions).",
    faq_q5: "Is uni free and open source?",
    faq_a5: "Yes, uni is completely free and released under the permissive open-source MIT License on GitHub, with no subscriptions or in-app purchases.",
    faq_q6: "What is Zero-Copy linked file management with Finder?",
    faq_a6: "When you link lecture slides or syllabus PDFs to a subject, files remain in their original folders in Finder via security-scoped bookmarks, without wasting duplicate SSD storage space.",

    footer_privacy: "Privacy &amp; Cookie Policy",
    footer_terms: "Terms of Use",
    nav_home: "← Back to Home",
    legal_badge: "Legal &amp; Privacy Notice",
    legal_title: "Privacy Policy &amp; Cookie Policy",
    legal_updated: "Last updated: October 4, 2026",
    btn_back_home: "← Back to uni Homepage",

    pol_sec1_title: "1. Data Controller",
    pol_sec1_desc: "This document describes the privacy practices of the website <strong>https://uni.zinco.cc/</strong> and the macOS application <strong>uni</strong> with respect to the processing of personal data pursuant to the EU General Data Protection Regulation (GDPR 2016/679), the Italian Privacy Code (D.Lgs. 196/2003 as amended), and international privacy standards.",
    pol_sec1_contact_title: "Official Data Controller Contact Channel",
    pol_sec1_contact_desc: "The Data Controller is <strong>Francesco Zanchetta</strong> (<a href=\"https://zinco.cc\" target=\"_blank\" rel=\"noopener\">zinco.cc</a>). For any inquiry regarding privacy, the exercise of GDPR rights (access, erasure, objection), or legal inquiries, please contact the Controller directly at: <a href=\"mailto:work@zinco.cc\"><strong>work@zinco.cc</strong></a> or via the official GitHub repository at <a href=\"https://github.com/zjncoo/uni\" target=\"_blank\" rel=\"noopener\">github.com/zjncoo/uni</a>.",

    pol_sec2_title: "2. macOS Application Architecture: Local Data &amp; Network Communications",
    pol_sec2_highlight_title: "100% Local Privacy for Your Academic Records",
    pol_sec2_highlight_desc: "All your personal academic data (courses, schedules, exam calls, grades, deadlines, notes, and attachments) remain stored exclusively on your local Mac disk. The uni application maintains no proprietary cloud backend and never uploads, inspects, or sells your academic records.",
    pol_sec2_p1_title: "No Account or Sign-up:",
    pol_sec2_p1_desc: "Using the application requires no user registration, profile creation, email address, or password.",
    pol_sec2_p2_title: "Local Storage &amp; Sandboxing:",
    pol_sec2_p2_desc: "The courses and exams database resides exclusively within local storage protected by macOS App Sandboxing.",
    pol_sec2_p3_title: "Zero-Copy File Linking:",
    pol_sec2_p3_desc: "Lecture slides, handouts, and PDFs stay in your chosen Finder directories; uni only stores a local security-scoped bookmark without duplicating or uploading files to any cloud.",
    pol_sec2_p4_title: "Calendar Sync (iCal/webcal):",
    pol_sec2_p4_desc: "Retrieving academic timetable feeds occurs via direct, encrypted local HTTPS requests between your Mac and your university's server URL, without third-party proxies or intermediaries.",
    pol_sec2_p5_title: "Microsoft Outlook for Mac Integration:",
    pol_sec2_p5_desc: "Reading inbox messages occurs strictly locally on your Mac via system AppleScript scripting with explicit user AppleEvents authorization. No credentials or email bodies are ever transmitted externally.",
    pol_sec2_p6_title: "Zero Hidden Telemetry:",
    pol_sec2_p6_desc: "uni contains zero advertising SDKs, profiling libraries, Google Analytics, Firebase, or hidden background telemetry.",
    pol_sec2_network_scope: "<strong>Scope of Network Communications:</strong> The only network connections made by the desktop application are: (1) direct download of university .ics timetable files from user-configured endpoints; (2) optional checks for new app updates via the public GitHub Releases API; (3) voluntary user-submitted bug reports or feature requests via the integrated modal (detailed in Section 3).",

    pol_sec3_title: "3. Feedback &amp; Bug Report Submissions (Google Forms)",
    pol_sec3_intro: "Within both the macOS app (via the <em>Support &amp; Feedback</em> panel) and the official website (<a href=\"help.html\">help.html</a>), users may optionally submit technical reports or feature requests to the developer.",
    pol_sec3_fields_title: "Data Collected &amp; Data Minimization",
    pol_sec3_fields_desc: "In compliance with the <strong>data minimization principle</strong> (GDPR Art. 5(1)(c)), the form collects only information strictly necessary to reproduce issues or evaluate suggestions:",
    pol_sec3_f1_title: "Submission Type:",
    pol_sec3_f1_desc: "Bug Report or Feature Request.",
    pol_sec3_f2_title: "Subject and Description:",
    pol_sec3_f2_desc: "Concise summary and detailed description of the encountered issue or feature suggestion.",
    pol_sec3_f3_title: "Overall Rating:",
    pol_sec3_f3_desc: "1 to 5 star rating measuring overall satisfaction.",
    pol_sec3_f4_title: "Optional Diagnostics Info:",
    pol_sec3_f4_desc: "If checked in the Mac app, only an anonymous technical string is attached (e.g. uni v1.5.1 • macOS 15.0 • Apple Silicon). No unique hardware identifiers, user UUIDs, or MAC addresses are attached.",
    pol_sec3_warn_title: "Advisory: Do Not Include Personal or Sensitive Data",
    pol_sec3_warn_desc: "Users are expressly advised <strong>not to include personally identifiable data</strong> (full name, phone number), login credentials (passwords), university student IDs, or special categories of personal data (health data, religious beliefs under GDPR Art. 9) in free-text fields.",
    pol_sec3_legal_basis_title: "Legal Basis &amp; Explicit Consent",
    pol_sec3_legal_basis_desc: "Processing is based on the <strong>explicit, informed consent of the data subject</strong> (GDPR Art. 6(1)(a)). Consent is provided via an affirmative action by checking the mandatory consent checkbox prior to submission.",
    pol_sec3_retention_title: "Data Retention &amp; Deletion Schedule",
    pol_sec3_retention_desc: "Feedback submissions are stored on Google Sheets linked to zinco.cc for a maximum period of <strong>12 (twelve) months</strong> from receipt, after which they are permanently deleted during semi-annual database maintenance reviews.",
    pol_sec3_deletion_workflow: "<strong>Immediate deletion upon request:</strong> Users have the right to request deletion of their feedback entry at any time by emailing work@zinco.cc with the approximate date and subject of the submission.",

    pol_sec4_title: "4. Website Data Processing &amp; Infrastructure Logs",
    pol_sec4_desc: "The website <strong>https://uni.zinco.cc/</strong> is hosted on <strong>GitHub Pages</strong>, operated by GitHub Inc. (Microsoft Corporation, 88 Colin P Kelly Jr St, San Francisco, CA 94107, USA).",
    pol_sec4_logs: "During website visits or GitHub Release API queries (api.github.com), GitHub servers may automatically record standard technical connection logs (IP address, User-Agent, referer, timestamp, requested URI) based on legitimate interest to secure networks and prevent abuse.",
    pol_sec4_gh_privacy: "For full details regarding GitHub processing, please consult the GitHub General Privacy Statement.",

    pol_sec5_title: "5. Cookie Policy &amp; Local Storage Technologies",
    pol_sec5_desc: "This section details local storage and external network requests under the ePrivacy Directive 2002/58/EC and Italian Data Protection Authority guidelines.",
    pol_sec5_highlight_title: "Zero Profiling or Advertising Tracking Cookies",
    pol_sec5_highlight_desc: "This website DOES NOT use profiling cookies, DOES NOT use tracking pixels (such as Meta Pixel or Google Ads), and DOES NOT sell or share data with third-party data brokers.",
    pol_sec5_table_title: "Technical Storage &amp; Third-Party Services Overview:",
    th_tool: "Tool",
    th_type: "Category",
    th_purpose: "Purpose",
    th_duration: "Duration",
    badge_tech: "Local Technical",
    badge_service: "External Service",
    cookie_row1_desc: "Stores user's chosen language preference (Italian or English) to display the website in the requested language on subsequent visits. Contains no personal identifiers.",
    cookie_row1_dur: "Persistent (until browser data is cleared)",
    cookie_row2_desc: "Website typography delivery (Inter, JetBrains Mono, IBM Plex Serif) 100% self-hosted locally on the website server. Zero requests to external Google servers and zero transmission of IP addresses to third parties.",
    cookie_row2_dur: "Session / Browser cache",
    cookie_row3_desc: "Anonymous client-side HTTP request to api.github.com to query the latest available macOS .dmg release assets.",
    cookie_row3_dur: "Temporary (No cookies)",
    cookie_row4_desc: "Invoked only upon voluntary submission of user feedback to transmit bug/suggestion details.",
    cookie_row4_dur: "Single transaction (No cookies)",
    pol_sec5_nobanner: "Because this site exclusively utilizes essential technical storage and operates without profiling or cross-site tracking cookies, prior cookie banner consent is not required under applicable law.",

    pol_sec6_title: "6. Children's Privacy &amp; Age Eligibility",
    pol_sec6_desc: "The services of <strong>uni</strong> and related web channels are intended for university students, higher education learners, and adult users. Access is restricted to individuals at least <strong>16 years of age</strong> (or the digital age of consent in the user's jurisdiction under GDPR Art. 8).",
    pol_sec6_coppa: "uni does not knowingly collect or solicit personal data from children under 16 (or under 13 under the United States Children's Online Privacy Protection Act - COPPA).",
    pol_sec6_parents_title: "Notice for Parents and Legal Guardians",
    pol_sec6_parents_desc: "If a parent or legal guardian discovers that a child has submitted personal data via the feedback form without consent, please notify work@zinco.cc promptly. We will immediately verify and permanently delete such data from all records.",

    pol_sec7_title: "7. International Data Transfers (Non-EU / USA)",
    pol_sec7_desc: "To guarantee user privacy, all website fonts and media assets are <strong>self-hosted locally</strong>: browsing the website makes zero third-party font requests. The only US-based third-party providers with whom data may be exchanged are: (1) GitHub Inc. for secure static hosting (GitHub Pages); (2) Google LLC for voluntary feedback submissions (Google Forms).",
    pol_sec7_dpf: "Transfers to these entities comply with GDPR Chapter V based on the European Commission's Adequacy Decision for the EU-U.S. Data Privacy Framework (DPF), under which both Google LLC and Microsoft/GitHub Inc. are certified, supplemented by Standard Contractual Clauses (SCCs).",

    pol_sec8_title: "8. User Rights (GDPR Articles 15-22)",
    pol_sec8_desc: "Under EU Regulation 2016/679, users hold the following rights:",
    pol_sec8_r1: "Right of Access (Art. 15): Confirm whether personal data is processed and receive a copy;",
    pol_sec8_r2: "Right to Rectification (Art. 16): Request correction of inaccurate or incomplete data;",
    pol_sec8_r3: "Right to Erasure ('Right to be Forgotten', Art. 17): Request permanent deletion of submitted feedback data;",
    pol_sec8_r4: "Right to Restriction of Processing (Art. 18): Restrict processing under statutory conditions;",
    pol_sec8_r5: "Right to Object &amp; Withdraw Consent (Arts. 21 &amp; 7): Revoke consent previously given for feedback processing at any time;",
    pol_sec8_r6: "Right to Lodge a Complaint (Art. 77): File a formal complaint with the competent supervisory authority (e.g., Italian Garante Privacy at www.garanteprivacy.it).",
    pol_sec8_note: "To exercise rights regarding submitted feedback, email work@zinco.cc. Rights are exercised free of charge within 30 days. For all academic data stored in the Mac app, users retain direct control by managing or deleting files directly on their own computer storage.",

    pol_sec9_title: "9. Changes &amp; Updates",
    pol_sec9_desc: "The Data Controller reserves the right to update this policy to reflect legal or technical revisions. The latest version will always be published on this page with the revision date.",

    // Terms of Use
    terms_badge: "General Conditions • Legal Agreement",
    terms_title: "Terms of Use",
    terms_updated: "Last updated: October 4, 2026",
    terms_sec1_title: "1. Acceptance of Terms",
    terms_sec1_desc: "These Terms of Use govern access to and use of the website https://uni.zinco.cc/ and the macOS application uni, developed and maintained by Francesco Zanchetta / zinco.cc.",
    terms_sec1_callout_title: "Binding Agreement",
    terms_sec1_callout_desc: "By downloading, installing, copying, or using the Application, or by browsing the Site, you represent that you have read, understood, and agree to be bound by these Terms and the Privacy Policy. If you do not agree, you must refrain from using the Software or Site and delete all copies of the Software.",
    terms_sec2_title: "2. Software License (MIT) &amp; Intellectual Property",
    terms_sec2_p1: "The Application source code is released as free and open-source software under the MIT License, publicly accessible in the official GitHub repository.",
    terms_sec2_p2: "Under the MIT license, permission is granted to any person obtaining a copy to deal in the Software without restriction, subject to including the original copyright notice and permission notice in all copies.",
    terms_sec2_p3: "The MIT license does NOT grant rights to trademarks, brand names ('uni', 'zinco.cc'), the original app icon ('///'), or site visual assets, which remain the exclusive intellectual property of Francesco Zanchetta / zinco.cc.",
    terms_sec3_title: "3. Permitted Use &amp; User Conduct",
    terms_sec3_p1: "The Application is intended for personal, educational, and individual productivity purposes to organize course timetables, exam sessions, and academic notes.",
    terms_sec3_p2: "Users are expressly prohibited from:",
    terms_sec3_r1: "Submitting unlawful, defamatory, harassing, discriminatory, or infringing content via the feedback modal or support channels;",
    terms_sec3_r2: "Attempting security attacks, malicious code injection, automated spam, unauthorized scraping, or infrastructure overburdening;",
    terms_sec3_r3: "Using the Software for unlawful purposes or in violation of academic regulations and applicable laws;",
    terms_sec3_r4: "Misrepresenting the Application or oneself as an official representative or affiliate of any university or third party without authorization.",
    terms_sec4_title: "4. Third-Party Trademarks &amp; Non-Affiliation (Nominative Fair Use)",
    terms_sec4_p1: "All product names, logos, brands, and registered trademarks mentioned on the Site and within the Application belong to their respective owners:",
    terms_sec4_m1: "Apple Inc.: 'macOS', 'Mac', 'AppleScript', 'Finder', 'iCloud', 'Apple Silicon' are trademarks of Apple Inc. in the US and other countries.",
    terms_sec4_m2: "Microsoft Corporation: 'Microsoft', 'Microsoft Outlook', 'Windows', 'Exchange' are trademarks of Microsoft Corporation.",
    terms_sec4_m3: "Google LLC: 'Google', 'Google Calendar', 'Google Forms', 'Google Fonts' are trademarks of Google LLC.",
    terms_sec4_m4: "GitHub, Inc.: 'GitHub' is a registered trademark of GitHub, Inc.",
    terms_sec4_m5: "Cineca Consorzio Interuniversitario: 'Esse3' is a trademark of Cineca Consorzio Interuniversitario.",
    terms_sec4_disclaimer_title: "Nominative Fair Use &amp; Non-Affiliation Disclaimer",
    terms_sec4_disclaimer_desc: "All third-party trademarks are used solely for descriptive and technical compatibility purposes (nominative fair use). Neither uni nor zinco.cc is endorsed, sponsored, affiliated with, or vetted by Apple Inc., Microsoft Corporation, Google LLC, GitHub Inc., Cineca, or any mentioned educational institution.",
    terms_sec5_title: "5. Organizational Purpose &amp; Academic Independence",
    terms_sec5_alert_title: "Student Notice: uni is a Personal Aid, Not an Official Portal",
    terms_sec5_alert_desc: "uni is an independent utility designed to aid study planning. It does NOT constitute an official university registrar record.",
    terms_sec5_desc: "Timetable schedules, lecture rooms, exam dates, registration deadlines, GPA calculations, and graduation grade estimates are computed for indicative purposes only. Users bear sole responsibility for verifying all dates and deadlines on official university systems (e.g. Esse3, official student portals, faculty announcements). The Developer assumes no liability for missed exams, missed registration deadlines, GPA calculation discrepancies, or timetable errors.",
    terms_sec6_title: "6. Disclaimer of Warranties (\"AS IS\" &amp; \"AS AVAILABLE\")",
    terms_sec6_p1: "TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE SOFTWARE AND WEBSITE ARE PROVIDED 'AS IS' AND 'AS AVAILABLE', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.",
    terms_sec6_p2: "THE DEVELOPER DOES NOT WARRANT THAT THE SOFTWARE WILL MEET SPECIFIC REQUIREMENTS, OPERATE UNINTERRUPTED OR ERROR-FREE, OR REMAIN COMPATIBLE WITH FUTURE OS UPDATES OR THIRD-PARTY FORMATS.",
    terms_sec7_title: "7. Limitation of Liability",
    terms_sec7_p1: "TO THE FULLEST EXTENT PERMITTED BY LAW, IN NO EVENT SHALL FRANCESCO ZANCHETTA, ZINCO.CC, OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, PUNITIVE, OR CONSEQUENTIAL DAMAGES (INCLUDING LOSS OF DATA, MISSED EXAMS, MISSED DEADLINES, OR FINANCIAL LOSSES) ARISING FROM USE OR INABILITY TO USE THE SOFTWARE.",
    terms_sec7_p2: "WHERE APPLICABLE LAW RESTRICTS LIABILITY EXCLUSIONS, TOTAL AGGREGATE LIABILITY SHALL NOT EXCEED THE AMOUNT PAID BY YOU FOR THE SOFTWARE (WHICH IS €0.00 / ZERO EUROS).",
    terms_sec8_title: "8. Age Requirements &amp; Minors",
    terms_sec8_desc: "The Application and Site are intended for university students and individuals aged 16 or older. By using the Software or submitting feedback, you represent and warrant that you meet this age threshold and possess full legal capacity to enter into these Terms.",
    terms_sec9_title: "9. Third-Party Links &amp; Services",
    terms_sec9_desc: "The Site and Application may link to external platforms (GitHub, Google, university feeds). The Developer exercises no control over third-party platforms and assumes no responsibility for their content or practices.",
    terms_sec10_title: "10. Governing Law &amp; Jurisdiction",
    terms_sec10_desc: "These Terms are governed by Italian law. Subject to mandatory consumer protection regulations, any disputes shall be submitted to the exclusive jurisdiction of the Courts of Milan, Italy.",
    terms_sec11_title: "11. Severability &amp; Amendments",
    terms_sec11_desc: "If any provision is held invalid, remaining provisions remain in full force. The Developer reserves the right to modify these Terms at any time; continued use constitutes acceptance.",
    terms_sec12_title: "12. Official Inquiries &amp; Notice",
    terms_sec12_desc: "For questions or legal notices, contact: work@zinco.cc.",

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
    help_privacy_box_title: "Privacy &amp; Data Minimization",
    help_privacy_box_desc: "Feedback submitted through this form is voluntary and processed via Google Forms solely for technical support and software quality improvement, with a maximum 12-month retention period. For your security and privacy, do not include confidential personal information, student IDs, passwords, emails, or sensitive data. For more details or deletion requests, see our Privacy &amp; Cookie Policy.",
    help_consent_checkbox_text: "I have read the Privacy Policy and consent to the transmission and processing of this feedback.",
    help_consent_required: "You must accept the Privacy Policy before submitting feedback.",
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


