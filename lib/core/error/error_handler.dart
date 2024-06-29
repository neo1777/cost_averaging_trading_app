// lib/core/error/error_handler.dart


class ErrorHandler {
  static void logError(String message, dynamic error, StackTrace stackTrace) {
    // In un'applicazione reale, qui potresti inviare l'errore a un servizio di logging remoto
  }

  static String getUserFriendlyErrorMessage(dynamic error) {
    if (error is NetworkError) {
      return 'Si è verificato un problema di connessione. Controlla la tua connessione internet e riprova.';
    } else if (error is AuthenticationError) {
      return 'Si è verificato un problema di autenticazione. Per favore, effettua nuovamente il login.';
    } else if (error is ValidationError) {
      return 'Si è verificato un problema con i dati inseriti. Per favore, controlla i tuoi input e riprova.';
    } else if (error is ApiError) {
      return 'Si è verificato un errore durante la comunicazione con il server. Per favore, riprova più tardi.';
    } else {
      return 'Si è verificato un errore imprevisto. Per favore, riprova più tardi.';
    }
  }
}

class NetworkError implements Exception {}

class AuthenticationError implements Exception {}

class ValidationError implements Exception {}

class ApiError implements Exception {
  final String message;
  ApiError(this.message);
}
