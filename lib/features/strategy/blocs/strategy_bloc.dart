import 'package:cost_averaging_trading_app/core/services/trading_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_event.dart';
import 'package:cost_averaging_trading_app/features/strategy/blocs/strategy_state.dart';
import 'package:cost_averaging_trading_app/features/strategy/repositories/strategy_repository.dart';
import 'package:cost_averaging_trading_app/core/services/risk_management_service.dart';
import 'package:cost_averaging_trading_app/core/services/backtesting_service.dart';

class StrategyBloc extends Bloc<StrategyEvent, StrategyState> {
  final StrategyRepository _strategyRepository;
  final RiskManagementService _riskManagementService;
  final BacktestingService _backtestingService;
  final TradingService _tradingService;

  StrategyBloc(
    this._strategyRepository,
    this._riskManagementService,
    this._backtestingService,
    this._tradingService,
  ) : super(StrategyInitial()) {
    on<LoadStrategyData>(_onLoadStrategyData);
    on<UpdateStrategyParameters>(_onUpdateStrategyParameters);
    on<StartStrategyEvent>(_onStartStrategy);
    on<StopStrategy>(_onStopStrategy);
    on<RunBacktestEvent>(_onRunBacktest);
    on<StartDemoStrategy>(_onStartDemoStrategy);
    on<StartLiveStrategy>(_onStartLiveStrategy);
    on<ForceStartStrategy>(_onForceStartStrategy);
    on<SellEntirePortfolio>(_onSellEntirePortfolio);
    on<UpdateUseAutoMinTradeAmount>(_onUpdateUseAutoMinTradeAmount);
    on<UpdateManualMinTradeAmount>(_onUpdateManualMinTradeAmount);
    on<UpdateIsVariableInvestmentAmount>(_onUpdateIsVariableInvestmentAmount);
    on<UpdateVariableInvestmentPercentage>(
        _onUpdateVariableInvestmentPercentage);
    on<UpdateReinvestProfits>(_onUpdateReinvestProfits);
    on<StartMonitoring>(_onStartMonitoring);
    on<StopMonitoring>(_onStopMonitoring);
    on<UpdateMonitoringData>(_onUpdateMonitoringData);
    // Carica i dati iniziali automaticamente
    add(LoadStrategyData());
  }

  Future<void> _onLoadStrategyData(
    LoadStrategyData event,
    Emitter<StrategyState> emit,
  ) async {
    try {
      emit(StrategyLoading());
      final parameters = await _strategyRepository.getStrategyParameters();
      final status = await _strategyRepository.getStrategyStatus();
      final chartData = await _strategyRepository.getStrategyChartData();
      final riskManagementSettings =
          await _riskManagementService.getRiskManagementSettings();
      final statistics = await _strategyRepository.getStrategyStatistics();
      final recentTrades = await _strategyRepository.getRecentTrades(10);

      emit(StrategyLoaded(
        parameters: parameters,
        status: status,
        chartData: chartData,
        riskManagementSettings: riskManagementSettings,
        totalInvested: statistics['totalInvested'] ?? 0,
        currentProfit: statistics['totalProfit'] ?? 0,
        tradeCount: statistics['totalTrades'] ?? 0,
        averageBuyPrice: statistics['averageBuyPrice'] ?? 0,
        currentMarketPrice:
            await _tradingService.getCurrentPrice(parameters.symbol),
        recentTrades: recentTrades,
      ));
    } catch (e) {
      emit(StrategyError('Failed to load strategy data: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStrategyParameters(
    UpdateStrategyParameters event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        await _strategyRepository.saveStrategyParameters(event.parameters);
        emit(currentState.copyWith(parameters: event.parameters));
      } catch (e) {
        emit(StrategyError(
            'Failed to update strategy parameters: ${e.toString()}'));
      }
    }
  }

  Future<void> _onStartStrategy(
    StartStrategyEvent event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        final isStrategySafe = await _riskManagementService
            .isStrategySafe(currentState.parameters);
        if (isStrategySafe) {
          await _strategyRepository
              .updateStrategyStatus(StrategyStateStatus.active);
          emit(currentState.copyWith(status: StrategyStateStatus.active));
        } else {
          emit(StrategyUnsafe(
            message:
                'Strategy is not safe to start based on current risk management settings.',
            parameters: currentState.parameters,
            status: currentState.status,
            chartData: currentState.chartData,
            riskManagementSettings: currentState.riskManagementSettings,
            isNowDemo: false,
          ));
        }
      } catch (e) {
        emit(StrategyError('Failed to start strategy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onStopStrategy(
    StopStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        await _strategyRepository
            .updateStrategyStatus(StrategyStateStatus.inactive);
        emit(currentState.copyWith(status: StrategyStateStatus.inactive));
      } catch (e) {
        emit(StrategyError('Failed to stop strategy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onRunBacktest(
      RunBacktestEvent event, Emitter<StrategyState> emit) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      emit(BacktestInProgress());

      try {
        final backtestResult = await _backtestingService.runBacktest(
          currentState.parameters.symbol,
          event.startDate,
          event.endDate,
          currentState.parameters,
          (progress, currentInvestmentOverTime) {
            emit(BacktestProgressUpdate(progress, currentInvestmentOverTime));
          },
        );
        emit(BacktestCompleted(backtestResult));
      } catch (e) {
        emit(BacktestError('Failed to run backtest: $e'));
      }
    } else {
      emit(BacktestError('Strategy not loaded'));
    }
  }

  Future<void> _onStartDemoStrategy(
    StartDemoStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        await _strategyRepository
            .updateStrategyStatus(StrategyStateStatus.active);
        // Implementa la logica specifica per la modalità demo
        emit(currentState.copyWith(
            status: StrategyStateStatus.active, isDemo: true));
      } catch (e) {
        emit(StrategyError('Failed to start demo strategy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onStartLiveStrategy(
    StartLiveStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        final isStrategySafe = await _riskManagementService
            .isStrategySafe(currentState.parameters);
        if (isStrategySafe) {
          await _strategyRepository
              .updateStrategyStatus(StrategyStateStatus.active);
          emit(currentState.copyWith(
              status: StrategyStateStatus.active, isDemo: false));
        } else {
          emit(StrategyUnsafe(
            message:
                'Strategy is not safe to start in live mode based on current risk management settings.',
            parameters: currentState.parameters,
            status: currentState.status,
            chartData: currentState.chartData,
            riskManagementSettings: currentState.riskManagementSettings,
            isNowDemo: false,
          ));
        }
      } catch (e) {
        emit(StrategyError('Failed to start live strategy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onForceStartStrategy(
    ForceStartStrategy event,
    Emitter<StrategyState> emit,
  ) async {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      try {
        await _strategyRepository
            .updateStrategyStatus(StrategyStateStatus.active);
        emit(currentState.copyWith(status: StrategyStateStatus.active));
      } catch (e) {
        emit(StrategyError('Failed to force start strategy: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSellEntirePortfolio(
    SellEntirePortfolio event,
    Emitter<StrategyState> emit,
  ) async {
    try {
      emit(StrategyLoading()); // Emettiamo uno stato di caricamento

      await _strategyRepository.sellEntirePortfolio(
        event.symbol,
        event.targetProfit,
        _tradingService,
      );

      // Otteniamo le statistiche aggiornate dopo la vendita
      final updatedStatistics =
          await _strategyRepository.getStrategyStatistics();

      // Emettiamo lo stato appropriato dopo la vendita
      emit(StrategyLoaded(
        parameters: (state as StrategyLoaded).parameters,
        status: StrategyStateStatus
            .inactive, // Assumiamo che la strategia sia ora inattiva
        chartData: (state as StrategyLoaded).chartData,
        riskManagementSettings:
            (state as StrategyLoaded).riskManagementSettings,
        totalInvested:
            0, // Il portafoglio è stato venduto, quindi l'investimento è 0
        currentProfit: updatedStatistics['totalProfit'] ?? 0,
        tradeCount: updatedStatistics['totalTrades'] ?? 0,
        averageBuyPrice: 0, // Non c'è più un prezzo medio di acquisto
        currentMarketPrice: await _tradingService.getCurrentPrice(event.symbol),
        recentTrades: await _strategyRepository
            .getRecentTrades(10), // Aggiorniamo le trade recenti
      ));

      // Potremmo anche voler emettere un evento di successo o mostrare una notifica
      // all'utente che la vendita è stata completata con successo
    } catch (e) {
      // Gestiamo l'errore e emettiamo lo stato appropriato
      emit(StrategyError('Failed to sell entire portfolio: ${e.toString()}'));

      // Potremmo anche voler loggare l'errore o mostrare una notifica all'utente
    }
  }

  void _onUpdateUseAutoMinTradeAmount(
    UpdateUseAutoMinTradeAmount event,
    Emitter<StrategyState> emit,
  ) {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      final updatedParameters = currentState.parameters.copyWith(
        useAutoMinTradeAmount: event.useAutoMinTradeAmount,
      );
      emit(currentState.copyWith(parameters: updatedParameters));
    }
  }

  void _onUpdateManualMinTradeAmount(
    UpdateManualMinTradeAmount event,
    Emitter<StrategyState> emit,
  ) {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      final updatedParameters = currentState.parameters.copyWith(
        manualMinTradeAmount: event.manualMinTradeAmount,
      );
      emit(currentState.copyWith(parameters: updatedParameters));
    }
  }

  void _onUpdateIsVariableInvestmentAmount(
    UpdateIsVariableInvestmentAmount event,
    Emitter<StrategyState> emit,
  ) {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      final updatedParameters = currentState.parameters.copyWith(
        isVariableInvestmentAmount: event.isVariableInvestmentAmount,
      );
      emit(currentState.copyWith(parameters: updatedParameters));
    }
  }

  void _onUpdateVariableInvestmentPercentage(
    UpdateVariableInvestmentPercentage event,
    Emitter<StrategyState> emit,
  ) {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      final updatedParameters = currentState.parameters.copyWith(
        variableInvestmentPercentage: event.variableInvestmentPercentage,
      );
      emit(currentState.copyWith(parameters: updatedParameters));
    }
  }

  void _onUpdateReinvestProfits(
    UpdateReinvestProfits event,
    Emitter<StrategyState> emit,
  ) {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      final updatedParameters = currentState.parameters.copyWith(
        reinvestProfits: event.reinvestProfits,
      );
      emit(currentState.copyWith(parameters: updatedParameters));
    }
  }

  Future<void> _onStartMonitoring(
    StartMonitoring event,
    Emitter<StrategyState> emit,
  ) async {
    // Implementa la logica per iniziare il monitoraggio
  }

  Future<void> _onStopMonitoring(
    StopMonitoring event,
    Emitter<StrategyState> emit,
  ) async {
    // Implementa la logica per fermare il monitoraggio
  }

  void _onUpdateMonitoringData(
    UpdateMonitoringData event,
    Emitter<StrategyState> emit,
  ) {
    if (state is StrategyLoaded) {
      final currentState = state as StrategyLoaded;
      emit(currentState.copyWith(
        totalInvested: event.totalInvested ?? currentState.totalInvested,
        currentProfit: event.currentProfit ?? currentState.currentProfit,
        tradeCount: event.tradeCount ?? currentState.tradeCount,
        averageBuyPrice: event.averageBuyPrice ?? currentState.averageBuyPrice,
        currentMarketPrice:
            event.currentMarketPrice ?? currentState.currentMarketPrice,
        recentTrades: event.recentTrades ?? currentState.recentTrades,
      ));
    }
  }
}

class BacktestProgressUpdate extends StrategyState {
  final double progress;
  final List<Map<String, dynamic>> currentInvestmentOverTime;

  BacktestProgressUpdate(this.progress, this.currentInvestmentOverTime);

  @override
  List<Object?> get props => [progress, currentInvestmentOverTime];
}
