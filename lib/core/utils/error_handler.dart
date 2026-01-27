import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

class ErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
          return 'Network error. Please check your connection.';
        case 'permission-denied':
          return 'You do not have permission to perform this action.';
        case 'not-found':
          return 'The requested resource was not found.';
        case 'already-exists':
          return 'This record already exists.';
        case 'aborted':
          return 'The operation was cancelled.';
        case 'invalid-argument':
          return 'Invalid data provided.';
        case 'unauthenticated':
          return 'Please log in again.';
        default:
          return 'Server error: ${error.message ?? "Something went wrong."}';
      }
    }

    if (error is PlatformException) {
      if (error.code == 'network_error') {
        return 'Network error. Please check your connection.';
      }
      return 'App error: ${error.message ?? "Something went wrong."}';
    }

    // Handle generic exceptions with clean messages if possible
    final String errorString = error.toString();
    if (errorString.contains('SocketException') ||
        errorString.contains('Network is unreachable')) {
      return 'Network error. Please check your connection.';
    }

    // Fallback for unknown errors - sanitize in production, but Keep it simple
    // "Something went wrong" is often too vague, but "Exception: ..." is too technical.
    // Let's try to be helpful but safe.
    if (errorString.length < 100) {
      return errorString.replaceAll('Exception:', '').trim();
    }

    return 'Something went wrong. Please try again.';
  }
}
