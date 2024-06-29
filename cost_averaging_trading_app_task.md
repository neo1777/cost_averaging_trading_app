1. Configurazione del progetto
   - [x] 1.1. Crea una nuova cartella per il progetto "cost_averaging_trading_app"
   - [x] 1.2. Apri la cartella in un IDE (es. Android Studio, VS Code)
   - [x] 1.3. Crea un nuovo progetto Flutter nella cartella
   - [x] 1.4. Configura il file `pubspec.yaml` con le dipendenze necessarie (bloc, equatable, http, intl, fl_chart, mockito, ecc.)
   - [x] 1.5. Esegui `flutter pub get` per scaricare le dipendenze

2. Creazione dei file principali
   - [x] 2.1. Crea il file `lib/main.dart`
      - [x] 2.1.1. Implementa la funzione `main()` che esegue `runApp(App())`
   - [x] 2.2. Crea il file `lib/app.dart`
      - [x] 2.2.1. Implementa la classe `App` che estende `StatelessWidget`
      - [x] 2.2.2. Configura il `MaterialApp` con il tema, il titolo e le rotte iniziali
   - [x] 2.3. Crea il file `lib/routes.dart`
      - [x] 2.3.1. Definisci una classe `Routes` con metodi statici per le rotte nominali (es. `static const home = '/'`)
      - [x] 2.3.2. Crea una mappa `routeMap` che associa le rotte alle pagine corrispondenti

3. Implementazione del layout principale
   - [x] 3.1. Crea la cartella `lib/ui/layouts`
   - [x] 3.2. Crea il file `lib/ui/layouts/main_layout.dart`
      - [x] 3.2.1. Implementa la classe `MainLayout` che estende `StatefulWidget`
      - [x] 3.2.2. Crea la classe `_MainLayoutState` che estende `State<MainLayout>`
      - [x] 3.2.3. Implementa il metodo `build` che costruisce lo scheletro del layout principale
         - [x] 3.2.3.1. Utilizza un `Scaffold` con un `AppBar`, un `Drawer` per il menu laterale e un `Expanded` per l'area principale
         - [x] 3.2.3.2. Implementa il menu laterale con un `ListView` e i `ListTile` per le voci di menu
         - [x] 3.2.3.3. Utilizza un `Navigator` nell'area principale per gestire la navigazione tra le pagine
   - [x] 3.3. Aggiorna il file `lib/routes.dart` per utilizzare il `MainLayout` come widget principale per tutte le rotte

4. Implementazione delle funzionalità principali
   - [x] 4.1. Dashboard
      - [x] 4.1.1. Crea la cartella `lib/features/dashboard`
      - [x] 4.1.2. Implementa i file necessari per la dashboard seguendo l'architettura proposta
         - [x] 4.1.2.1. Crea i file `dashboard_bloc.dart`, `dashboard_event.dart` e `dashboard_state.dart` nella cartella `blocs`
         - [x] 4.1.2.2. Crea il file `dashboard_model.dart` nella cartella `models`
         - [x] 4.1.2.3. Crea il file `dashboard_repository.dart` nella cartella `repositories`
         - [x] 4.1.2.4. Crea i file `dashboard_page.dart`, `portfolio_overview.dart`, `performance_chart.dart` e `notifications.dart` nella cartella `ui/pages/components`
         - [x] 4.1.2.5. Crea il file `custom_widgets.dart` nella cartella `ui/widgets`
      - [x] 4.1.3. Implementa la logica di business nel `DashboardBloc`
      - [x] 4.1.4. Implementa la pagina `DashboardPage` che utilizza i componenti `PortfolioOverview`, `PerformanceChart` e `Notifications`
      - [x] 4.1.5. Aggiungi la rotta per la dashboard in `lib/routes.dart`
   - [x] 4.2. Strategia di trading
      - [x] 4.2.1. Crea la cartella `lib/features/strategy`
      - [x] 4.2.2. Implementa i file necessari per la strategia di trading seguendo l'architettura proposta
         - [x] 4.2.2.1. Crea i file `strategy_bloc.dart`, `strategy_event.dart` e `strategy_state.dart` nella cartella `blocs`
         - [x] 4.2.2.2. Crea il file `strategy_model.dart` nella cartella `models`
         - [x] 4.2.2.3. Crea il file `strategy_repository.dart` nella cartella `repositories`
         - [x] 4.2.2.4. Crea i file `strategy_page.dart`, `configuration_panel.dart`, `strategy_status.dart`, `trading_controls.dart` e `charts.dart` nella cartella `ui/pages/components`
         - [x] 4.2.2.5. Crea il file `custom_widgets.dart` nella cartella `ui/widgets`
      - [x] 4.2.3. Implementa la logica di business nel `StrategyBloc`
      - [x] 4.2.4. Implementa la pagina `StrategyPage` che utilizza i componenti `ConfigurationPanel`, `StrategyStatus`, `TradingControls` e `Charts`
      - [x] 4.2.5. Aggiungi la rotta per la strategia di trading in `lib/routes.dart`
   - [x] 4.3. Portafoglio
      - [x] 4.3.1. Crea la cartella `lib/features/portfolio`
      - [x] 4.3.2. Implementa i file necessari per il portafoglio seguendo l'architettura proposta
         - [x] 4.3.2.1. Crea i file `portfolio_bloc.dart`, `portfolio_event.dart` e `portfolio_state.dart` nella cartella `blocs`
         - [x] 4.3.2.2. Crea il file `portfolio_model.dart` nella cartella `models`
         - [x] 4.3.2.3. Crea il file `portfolio_repository.dart` nella cartella `repositories`
         - [x] 4.3.2.4. Crea i file `portfolio_page.dart`, `asset_overview.dart`, `transaction_history.dart` e `portfolio_chart.dart` nella cartella `ui/pages/components`
         - [x] 4.3.2.5. Crea il file `custom_widgets.dart` nella cartella `ui/widgets`
      - [x] 4.3.3. Implementa la logica di business nel `PortfolioBloc`
      - [x] 4.3.4. Implementa la pagina `PortfolioPage` che utilizza i componenti `AssetOverview`, `TransactionHistory` e `PortfolioChart`
      - [x] 4.3.5. Aggiungi la rotta per il portafoglio in `lib/routes.dart`
   - [x] 4.4. Cronologia dei trade
      - [x] 4.4.1. Crea la cartella `lib/features/trade_history`
      - [x] 4.4.2. Implementa i file necessari per la cronologia dei trade seguendo l'architettura proposta
         - [x] 4.4.2.1. Crea i file `trade_history_bloc.dart`, `trade_history_event.dart` e `trade_history_state.dart` nella cartella `blocs`
         - [x] 4.4.2.2. Crea il file `trade_history_model.dart` nella cartella `models`
         - [x] 4.4.2.3. Crea il file `trade_history_repository.dart` nella cartella `repositories`
         - [x] 4.4.2.4. Crea i file `trade_history_page.dart`, `trade_list.dart`, `filters.dart` e `statistics.dart` nella cartella `ui/pages/components`
         - [x] 4.4.2.5. Crea il file `custom_widgets.dart` nella cartella `ui/widgets`
      - [x] 4.4.3. Implementa la logica di business nel `TradeHistoryBloc`
      - [x] 4.4.4. Implementa la pagina `TradeHistoryPage` che utilizza i componenti `TradeList`, `Filters` e `Statistics`
      - [x] 4.4.5. Aggiungi la rotta per la cronologia dei trade in `lib/routes.dart`
   - [x] 4.5. Impostazioni
      - [x] 4.5.1. Crea la cartella `lib/features/settings`
      - [x] 4.5.2. Implementa i file necessari per le impostazioni seguendo l'architettura proposta
         - [x] 4.5.2.1. Crea i file `settings_bloc.dart`, `settings_event.dart` e `settings_state.dart` nella cartella `blocs`
         - [x] 4.5.2.2. Crea il file `settings_model.dart` nella cartella `models`
         - [x] 4.5.2.3. Crea il file `settings_repository.dart` nella cartella `repositories`
         - [x] 4.5.2.4. Crea i file `settings_page.dart`, `api_configuration.dart`, `backtesting.dart`, `risk_management.dart` e `mode_toggle.dart` nella cartella `ui/pages/components`
         - [x] 4.5.2.5. Crea il file `custom_widgets.dart` nella cartella `ui/widgets`
      - [x] 4.5.3. Implementa la logica di business nel `SettingsBloc`
      - [x] 4.5.4. Implementa la pagina `SettingsPage` che utilizza i componenti `ApiConfiguration`, `Backtesting`, `RiskManagement` e `ModeToggle`
      - [x] 4.5.5. Aggiungi la rotta per le impostazioni in `lib/routes.dart`

5. Implementazione dei servizi e delle risorse condivise
   - [x] 5.1. Crea la cartella `lib/core`
   - [x] 5.2. Implementa i file necessari per i servizi e le risorse condivise
      - [x] 5.2.1. Crea i file `api_service.dart` e `database_service.dart` nella cartella `services`
      - [x] 5.2.2. Crea i file `trade_dto.dart` e `portfolio_dto.dart` nella cartella `dtos`
      - [x] 5.2.3. Crea i file `trade_mapper.dart` e `portfolio_mapper.dart` nella cartella `mappers`
      - [x] 5.2.4. Crea i file `trade.dart` e `portfolio.dart` nella cartella `models`
      - [x] 5.2.5. Crea i file `portfolio_repository.dart`, `portfolio_repository_impl.dart`, `trading_repository.dart` e `trading_repository_impl.dart` nella cartella `repositories`
      - [x] 5.2.6. Crea il file `shared_widgets.dart` nella cartella `widgets`
      - [x] 5.2.7. Crea i file `trade_entity.dart` e `portfolio_entity.dart` nella cartella `domain/entities`
      - [x] 5.2.8. Crea il file `trading_enums.dart` nella cartella `domain/enums`
   - [x] 5.3. Implementa la logica dei servizi (`ApiService` e `DatabaseService`)
   - [x] 5.4. Implementa i DTO (`TradeDTO` e `PortfolioDTO`)
   - [x] 5.5. Implementa i mapper (`TradeMapper` e `PortfolioMapper`)
   - [x] 5.6. Implementa i modelli di dominio (`Trade` e `Portfolio`)
   - [x] 5.7. Implementa i repository (`PortfolioRepository`, `PortfolioRepositoryImpl`, `TradingRepository` e `TradingRepositoryImpl`)

6. Integrazione con le API di Binance
   - [x] 6.1. Crea un account di sviluppo su Binance e ottieni le chiavi API
   - [x] 6.2. Configura le chiavi API nell'`ApiService`
   - [x] 6.3. Implementa i metodi nell'`ApiService` per effettuare le chiamate alle API di Binance (es. recupero dei prezzi, invio degli ordini)
   - [x] 6.4. Gestisci la sicurezza e l'autenticazione delle chiamate API

7. Implementazione delle funzionalità avanzate
   - [x] 7.1. Gestione del rischio
      - [x] 7.1.1. Implementa la logica per il calcolo e l'applicazione dei limiti di volatilità
      - [x] 7.1.2. Implementa la logica per il limite massimo di riacquisti
      - [x] 7.1.3. Implementa la logica per gli stop loss
   - [x] 7.2. Backtesting
      - [x] 7.2.1. Implementa la logica per eseguire il backtesting della strategia su dati storici
      - [x] 7.2.2. Visualizza i risultati del backtesting nell'interfaccia utente
   - [x] 7.3. Modalità demo
      - [x] 7.3.1. Implementa la logica per la modalità demo che utilizza dati simulati
      - [x] 7.3.2. Aggiungi un'opzione nell'interfaccia utente per attivare/disattivare la modalità demo

8. Test e debug
   - [x] 8.1. Crea la cartella `test`
   - [x] 8.2. Implementa i test unitari per i bloc, i modelli, i repository e i servizi
   - [x] 8.3. Implementa i test di integrazione per verificare il flusso end-to-end dell'applicazione
   - [ ] 8.4. Esegui i test e correggi eventuali errori o problemi riscontrati
   - [ ] 8.5. Esegui il debug dell'applicazione su diversi dispositivi e simulatori
   - [ ] 8.6. Ottimizza le prestazioni dell'applicazione, se necessario

9. Rifinitura dell'interfaccia utente
   - [ ] 9.1. Applica uno stile coerente e accattivante all'interfaccia utente
   - [ ] 9.2. Verifica la responsività dell'interfaccia utente su diversi dispositivi e orientamenti
   - [ ] 9.3. Aggiungi animazioni e transizioni per migliorare l'esperienza utente
   - [ ] 9.4. Implementa la localizzazione per supportare diverse lingue, se necessario

10. Documentazione
    - [ ] 10.1. Scrivi la documentazione per l'utilizzo dell'applicazione
    - [ ] 10.2. Scrivi la documentazione tecnica per gli sviluppatori (architettura, flusso di dati, API)
    - [ ] 10.3. Aggiungi commenti al codice per facilitare la manutenzione futura

11. Preparazione per il rilascio
    - [ ] 11.1. Configura la firma del codice per la release build
    - [ ] 11.2. Crea un'icona dell'applicazione accattivante
    - [ ] 11.3. Configura i metadati dell'applicazione (nome, descrizione, screenshot) per gli app store
    - [ ] 11.4. Esegui una build di release dell'applicazione
    - [ ] 11.5. Testa accuratamente la build di release su dispositivi reali

12. Pubblicazione
    - [ ] 12.1. Crea un account sviluppatore su Google Play Store e Apple App Store
    - [ ] 12.2. Prepara i materiali di marketing (descrizione, screenshot, video) per gli app store
    - [ ] 12.3. Invia l'applicazione per la revisione agli app store
    - [ ] 12.4. Gestisci eventuali feedback o richieste di modifiche da parte degli app store
    - [ ] 12.5. Pubblica l'applicazione sugli app store una volta approvata

13. Manutenzione e aggiornamenti
    - [ ] 13.1. Monitora i feedback degli utenti e i rapporti di crash
    - [ ] 13.2. Risolvi eventuali problemi o bug segnalati dagli utenti
    - [ ] 13.3. Pianifica e implementa nuove funzionalità o miglioramenti in base al feedback degli utenti
    - [ ] 13.4. Rilascia aggiornamenti regolari dell'applicazione con correzioni di bug e nuove funzionalità

