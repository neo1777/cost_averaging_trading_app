# Implementazione della Strategia di Trading Aggiornata

## 1. Aggiornamento del modello StrategyParameters
File: `lib/features/strategy/models/strategy_parameters.dart`
- [x] Aggiungi nuovi campi:
  - [x] `useAutoMinTradeAmount` (bool)
  - [x] `manualMinTradeAmount` (double)
  - [x] `isVariableInvestmentAmount` (bool)
  - [x] `variableInvestmentPercentage` (double)
  - [x] `reinvestProfits` (bool)
- [x] Aggiorna il costruttore per includere i nuovi campi
- [x] Aggiorna il metodo `copyWith` con i nuovi campi
- [x] Aggiorna il metodo `fromJson` per deserializzare i nuovi campi
- [x] Aggiorna il metodo `toJson` per serializzare i nuovi campi
- [x] Aggiorna la lista `props` di Equatable con i nuovi campi

## 2. Aggiornamento dell'interfaccia utente della pagina Strategia
File: `lib/features/strategy/ui/pages/strategy_page.dart`
- [x] Aggiungi nuovi campi di input:
  - [x] Switch per `useAutoMinTradeAmount`
  - [x] TextField per `manualMinTradeAmount` (visibile solo se `useAutoMinTradeAmount` è false)
  - [x] Switch per `isVariableInvestmentAmount`
  - [x] TextField per `variableInvestmentPercentage` (visibile solo se `isVariableInvestmentAmount` è true)
  - [x] Switch per `reinvestProfits`
- [x] Implementa la logica per mostrare/nascondere campi:
  - [x] Usa un `Visibility` widget per `manualMinTradeAmount`
  - [x] Usa un `Visibility` widget per `variableInvestmentPercentage`
- [x] Aggiorna la logica di validazione del form per includere i nuovi campi
- [x] Aggiorna il metodo di salvataggio dei parametri per includere i nuovi campi
- [x] Aggiorna la visualizzazione dei parametri correnti nella UI

## 3. Aggiornamento del widget StrategyParametersForm
File: `lib/features/strategy/ui/widgets/strategy_parameters_form.dart`
- [x] Aggiungi nuovi controller per i nuovi campi:
  - [x] `useAutoMinTradeAmountController`
  - [x] `manualMinTradeAmountController`
  - [x] `isVariableInvestmentAmountController`
  - [x] `variableInvestmentPercentageController`
  - [x] `reinvestProfitsController`
- [x] Implementa la validazione per i nuovi campi:
  - [x] `manualMinTradeAmount` deve essere > 0 quando `useAutoMinTradeAmount` è false
  - [x] `variableInvestmentPercentage` deve essere tra 0 e 100 quando `isVariableInvestmentAmount` è true
- [x] Aggiorna il metodo `onParametersChanged` per includere i nuovi parametri
- [x] Implementa la logica di abilitazione/disabilitazione dei campi basata sugli switch
- [x] Aggiorna il metodo `dispose` per rilasciare i nuovi controller

## 4. Aggiornamento del StrategyBloc
File: `lib/features/strategy/blocs/strategy_bloc.dart`
- [x] Aggiungi nuovi eventi:
  - [x] `UpdateUseAutoMinTradeAmount`
  - [x] `UpdateManualMinTradeAmount`
  - [x] `UpdateIsVariableInvestmentAmount`
  - [x] `UpdateVariableInvestmentPercentage`
  - [x] `UpdateReinvestProfits`
- [x] Aggiorna lo stato `StrategyState` per includere i nuovi parametri
- [x] Implementa handler per i nuovi eventi:
  - [x] `_onUpdateUseAutoMinTradeAmount`
  - [x] `_onUpdateManualMinTradeAmount`
  - [x] `_onUpdateIsVariableInvestmentAmount`
  - [x] `_onUpdateVariableInvestmentPercentage`
  - [x] `_onUpdateReinvestProfits`
- [x] Aggiorna il metodo `_loadStrategyParameters` per caricare i nuovi parametri
- [x] Aggiorna il metodo `_saveStrategyParameters` per salvare i nuovi parametri

## 5. Aggiornamento del TradingService
File: `lib/core/services/trading_service.dart`
- [x] Aggiorna il metodo `executeStrategy` per utilizzare i nuovi parametri:
  - [x] Implementa la logica per determinare l'importo minimo di trading (auto o manuale)
  - [x] Aggiungi logica per calcolare la variazione percentuale del prezzo
  - [x] Implementa la logica di acquisto quando il prezzo scende
  - [x] Implementa la logica di vendita quando il prezzo sale
  - [x] Aggiungi logica per il reinvestimento dei profitti
- [x] Aggiorna i metodi `_buy` e `_sell`:
  - [x] Implementa la logica per l'importo variabile di acquisto
  - [x] Gestisci il reinvestimento dei profitti
- [x] Aggiorna il metodo `startStrategy` per utilizzare i nuovi parametri
- [x] Implementa un nuovo metodo `_calculateBuyAmount` per determinare l'importo di acquisto
- [x] Aggiorna il metodo `sellEntirePortfolio` per considerare il reinvestimento dei profitti

## 6. Aggiornamento dell'ApiService
File: `lib/core/services/api_service.dart`
- [x] Aggiungi metodo `getMinimumTradeAmount(String symbol)`:
  - [x] Implementa chiamata all'API Binance per ottenere il minimo importo negoziabile
  - [x] Gestisci eventuali errori e restituisci un valore di fallback se necessario
- [x] Aggiorna il metodo `getPriceStream` per gestire disconnessioni e riconnessioni
- [x] Aggiorna i metodi di creazione degli ordini per supportare importi variabili:
  - [x] `createMarketBuyOrder`
  - [x] `createMarketSellOrder`
  - [x] `createLimitBuyOrder`
  - [x] `createLimitSellOrder`

## 7. Aggiornamento del DatabaseService
File: `lib/core/services/database_service.dart`
- [x] Aggiorna lo schema del database per includere i nuovi campi della strategia
- [x] Aggiorna il metodo `saveStrategyParameters` per includere i nuovi campi
- [x] Aggiorna il metodo `getStrategyParameters` per recuperare i nuovi campi
- [x] Aggiorna i metodi relativi agli ordini per supportare importi variabili:
  - [x] `saveOrder`
  - [x] `getOrders`
- [x] Implementa un nuovo metodo `getStrategyPerformance` per recuperare le statistiche di performance

## 8. Aggiornamento del BacktestingService
File: `lib/core/services/backtesting_service.dart`
- [x] Aggiorna il metodo `runBacktest` per utilizzare i nuovi parametri della strategia
- [x] Implementa la simulazione del nuovo algoritmo di trading:
  - [x] Aggiungi logica per simulare l'uso di `useAutoMinTradeAmount` e `manualMinTradeAmount`
  - [x] Implementa la logica per `isVariableInvestmentAmount` e `variableInvestmentPercentage`
  - [x] Simula il reinvestimento dei profitti se l'opzione è attivata
- [x] Aggiorna il calcolo delle metriche di performance per includere nuovi indicatori
- [x] Implementa la generazione di un report dettagliato del backtest

## 9. Aggiornamento della pagina dei risultati del backtest
File: `lib/features/strategy/ui/widgets/backtest_results.dart`
- [x] Aggiorna la visualizzazione per includere le nuove metriche:
  - [x] Aggiungi grafico per mostrare la variazione dell'importo di investimento nel tempo
  - [x] Mostra statistiche sul numero di operazioni con importo variabile vs fisso
  - [x] Visualizza l'impatto del reinvestimento dei profitti (se attivato)
- [x] Implementa una vista dettagliata delle singole operazioni simulate
- [x] Aggiorna la logica di rendering per gestire i nuovi dati del backtest

## 10. Implementazione del monitoraggio in tempo reale della strategia
File: `lib/features/strategy/ui/widgets/strategy_monitor.dart`
- [x] Crea un nuovo widget `StrategyMonitor`
- [x] Implementa la visualizzazione in tempo reale di:
  - [x] Totale investito
  - [x] Profitto/Perdita corrente
  - [x] Numero di operazioni eseguite
  - [x] Prezzo medio di acquisto
  - [x] Prezzo corrente del mercato
- [x] Aggiungi un grafico in tempo reale dell'andamento del prezzo
- [x] Implementa la logica per aggiornare i dati in tempo reale utilizzando i nuovi parametri della strategia

## 11. Aggiornamento del RiskManagementService
File: `lib/core/services/risk_management_service.dart`
- [x] Aggiorna il metodo `isTradeAllowed` per considerare i nuovi parametri:
  - [x] Verifica che l'importo di trading rispetti i limiti impostati
  - [x] Implementa la logica per gestire l'investimento variabile
- [x] Aggiungi un metodo `calculateRisk` per valutare il rischio complessivo della strategia
- [x] Implementa controlli aggiuntivi per prevenire perdite eccessive:
  - [x] Aggiungi un limite giornaliero di perdita
  - [x] Implementa una logica di "cooling off" dopo una serie di perdite
- [x] Aggiorna il metodo `isStrategySafe` per utilizzare i nuovi parametri della strategia

## 12. Aggiornamento dello StrategyRepository
File: `lib/features/strategy/repositories/strategy_repository.dart`
- [ ] Aggiorna i metodi per salvare e recuperare i parametri della strategia
- [ ] Implementa nuovi metodi per gestire le statistiche della strategia con i nuovi parametri
- [ ] Aggiorna la logica di persistenza dei dati della strategia per includere i nuovi campi