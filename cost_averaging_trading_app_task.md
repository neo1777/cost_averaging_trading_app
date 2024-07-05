# Implementazione della Strategia di Trading Aggiornata

## 1. Aggiornamento del modello StrategyParameters
File: `lib/features/strategy/models/strategy_parameters.dart`
- [ ] Aggiungi nuovi campi:
  - [ ] `useAutoMinTradeAmount` (bool)
  - [ ] `manualMinTradeAmount` (double)
  - [ ] `isVariableInvestmentAmount` (bool)
  - [ ] `variableInvestmentPercentage` (double)
  - [ ] `reinvestProfits` (bool)
- [ ] Aggiorna il costruttore per includere i nuovi campi
- [ ] Aggiorna il metodo `copyWith` con i nuovi campi
- [ ] Aggiorna il metodo `fromJson` per deserializzare i nuovi campi
- [ ] Aggiorna il metodo `toJson` per serializzare i nuovi campi
- [ ] Aggiorna la lista `props` di Equatable con i nuovi campi

## 2. Aggiornamento dell'interfaccia utente della pagina Strategia
File: `lib/features/strategy/ui/pages/strategy_page.dart`
- [ ] Aggiungi nuovi campi di input:
  - [ ] Switch per `useAutoMinTradeAmount`
  - [ ] TextField per `manualMinTradeAmount` (visibile solo se `useAutoMinTradeAmount` è false)
  - [ ] Switch per `isVariableInvestmentAmount`
  - [ ] TextField per `variableInvestmentPercentage` (visibile solo se `isVariableInvestmentAmount` è true)
  - [ ] Switch per `reinvestProfits`
- [ ] Implementa la logica per mostrare/nascondere campi:
  - [ ] Usa un `Visibility` widget per `manualMinTradeAmount`
  - [ ] Usa un `Visibility` widget per `variableInvestmentPercentage`
- [ ] Aggiorna la logica di validazione del form per includere i nuovi campi
- [ ] Aggiorna il metodo di salvataggio dei parametri per includere i nuovi campi
- [ ] Aggiorna la visualizzazione dei parametri correnti nella UI

## 3. Aggiornamento del widget StrategyParametersForm
File: `lib/features/strategy/ui/widgets/strategy_parameters_form.dart`
- [ ] Aggiungi nuovi controller per i nuovi campi:
  - [ ] `useAutoMinTradeAmountController`
  - [ ] `manualMinTradeAmountController`
  - [ ] `isVariableInvestmentAmountController`
  - [ ] `variableInvestmentPercentageController`
  - [ ] `reinvestProfitsController`
- [ ] Implementa la validazione per i nuovi campi:
  - [ ] `manualMinTradeAmount` deve essere > 0 quando `useAutoMinTradeAmount` è false
  - [ ] `variableInvestmentPercentage` deve essere tra 0 e 100 quando `isVariableInvestmentAmount` è true
- [ ] Aggiorna il metodo `onParametersChanged` per includere i nuovi parametri
- [ ] Implementa la logica di abilitazione/disabilitazione dei campi basata sugli switch
- [ ] Aggiorna il metodo `dispose` per rilasciare i nuovi controller

## 4. Aggiornamento del StrategyBloc
File: `lib/features/strategy/blocs/strategy_bloc.dart`
- [ ] Aggiungi nuovi eventi:
  - [ ] `UpdateUseAutoMinTradeAmount`
  - [ ] `UpdateManualMinTradeAmount`
  - [ ] `UpdateIsVariableInvestmentAmount`
  - [ ] `UpdateVariableInvestmentPercentage`
  - [ ] `UpdateReinvestProfits`
- [ ] Aggiorna lo stato `StrategyState` per includere i nuovi parametri
- [ ] Implementa handler per i nuovi eventi:
  - [ ] `_onUpdateUseAutoMinTradeAmount`
  - [ ] `_onUpdateManualMinTradeAmount`
  - [ ] `_onUpdateIsVariableInvestmentAmount`
  - [ ] `_onUpdateVariableInvestmentPercentage`
  - [ ] `_onUpdateReinvestProfits`
- [ ] Aggiorna il metodo `_loadStrategyParameters` per caricare i nuovi parametri
- [ ] Aggiorna il metodo `_saveStrategyParameters` per salvare i nuovi parametri

## 5. Aggiornamento del TradingService
File: `lib/core/services/trading_service.dart`
- [ ] Aggiorna il metodo `executeStrategy` per utilizzare i nuovi parametri:
  - [ ] Implementa la logica per determinare l'importo minimo di trading (auto o manuale)
  - [ ] Aggiungi logica per calcolare la variazione percentuale del prezzo
  - [ ] Implementa la logica di acquisto quando il prezzo scende
  - [ ] Implementa la logica di vendita quando il prezzo sale
  - [ ] Aggiungi logica per il reinvestimento dei profitti
- [ ] Aggiorna i metodi `_buy` e `_sell`:
  - [ ] Implementa la logica per l'importo variabile di acquisto
  - [ ] Gestisci il reinvestimento dei profitti
- [ ] Aggiorna il metodo `startStrategy` per utilizzare i nuovi parametri
- [ ] Implementa un nuovo metodo `_calculateBuyAmount` per determinare l'importo di acquisto
- [ ] Aggiorna il metodo `sellEntirePortfolio` per considerare il reinvestimento dei profitti

## 6. Aggiornamento dell'ApiService
File: `lib/core/services/api_service.dart`
- [ ] Aggiungi metodo `getMinimumTradeAmount(String symbol)`:
  - [ ] Implementa chiamata all'API Binance per ottenere il minimo importo negoziabile
  - [ ] Gestisci eventuali errori e restituisci un valore di fallback se necessario
- [ ] Aggiorna il metodo `getPriceStream` per gestire disconnessioni e riconnessioni
- [ ] Aggiorna i metodi di creazione degli ordini per supportare importi variabili:
  - [ ] `createMarketBuyOrder`
  - [ ] `createMarketSellOrder`
  - [ ] `createLimitBuyOrder`
  - [ ] `createLimitSellOrder`

## 7. Aggiornamento del DatabaseService
File: `lib/core/services/database_service.dart`
- [ ] Aggiorna lo schema del database per includere i nuovi campi della strategia
- [ ] Aggiorna il metodo `saveStrategyParameters` per includere i nuovi campi
- [ ] Aggiorna il metodo `getStrategyParameters` per recuperare i nuovi campi
- [ ] Aggiorna i metodi relativi agli ordini per supportare importi variabili:
  - [ ] `saveOrder`
  - [ ] `getOrders`
- [ ] Implementa un nuovo metodo `getStrategyPerformance` per recuperare le statistiche di performance

## 8. Aggiornamento del BacktestingService
File: `lib/core/services/backtesting_service.dart`
- [ ] Aggiorna il metodo `runBacktest` per utilizzare i nuovi parametri della strategia
- [ ] Implementa la simulazione del nuovo algoritmo di trading:
  - [ ] Aggiungi logica per simulare l'uso di `useAutoMinTradeAmount` e `manualMinTradeAmount`
  - [ ] Implementa la logica per `isVariableInvestmentAmount` e `variableInvestmentPercentage`
  - [ ] Simula il reinvestimento dei profitti se l'opzione è attivata
- [ ] Aggiorna il calcolo delle metriche di performance per includere nuovi indicatori
- [ ] Implementa la generazione di un report dettagliato del backtest

## 9. Aggiornamento della pagina dei risultati del backtest
File: `lib/features/strategy/ui/widgets/backtest_results.dart`
- [ ] Aggiorna la visualizzazione per includere le nuove metriche:
  - [ ] Aggiungi grafico per mostrare la variazione dell'importo di investimento nel tempo
  - [ ] Mostra statistiche sul numero di operazioni con importo variabile vs fisso
  - [ ] Visualizza l'impatto del reinvestimento dei profitti (se attivato)
- [ ] Implementa una vista dettagliata delle singole operazioni simulate
- [ ] Aggiorna la logica di rendering per gestire i nuovi dati del backtest

## 10. Implementazione del monitoraggio in tempo reale della strategia
File: `lib/features/strategy/ui/widgets/strategy_monitor.dart`
- [ ] Crea un nuovo widget `StrategyMonitor`
- [ ] Implementa la visualizzazione in tempo reale di:
  - [ ] Totale investito
  - [ ] Profitto/Perdita corrente
  - [ ] Numero di operazioni eseguite
  - [ ] Prezzo medio di acquisto
  - [ ] Prezzo corrente del mercato
- [ ] Aggiungi un grafico in tempo reale dell'andamento del prezzo
- [ ] Implementa la logica per aggiornare i dati in tempo reale utilizzando i nuovi parametri della strategia

## 11. Aggiornamento del RiskManagementService
File: `lib/core/services/risk_management_service.dart`
- [ ] Aggiorna il metodo `isTradeAllowed` per considerare i nuovi parametri:
  - [ ] Verifica che l'importo di trading rispetti i limiti impostati
  - [ ] Implementa la logica per gestire l'investimento variabile
- [ ] Aggiungi un metodo `calculateRisk` per valutare il rischio complessivo della strategia
- [ ] Implementa controlli aggiuntivi per prevenire perdite eccessive:
  - [ ] Aggiungi un limite giornaliero di perdita
  - [ ] Implementa una logica di "cooling off" dopo una serie di perdite
- [ ] Aggiorna il metodo `isStrategySafe` per utilizzare i nuovi parametri della strategia

## 12. Aggiornamento dello StrategyRepository
File: `lib/features/strategy/repositories/strategy_repository.dart`
- [ ] Aggiorna i metodi per salvare e recuperare i parametri della strategia
- [ ] Implementa nuovi metodi per gestire le statistiche della strategia con i nuovi parametri
- [ ] Aggiorna la logica di persistenza dei dati della strategia per includere i nuovi campi