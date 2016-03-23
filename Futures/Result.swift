import Foundation

/// Typical Result enumeration (aka Either)
public enum Result<T> {
  /// The result contains a Success value
  case Success(T)
  
  /// The result contains an error
  case Error(ErrorType)
  
  /// The result was cancelled
  case Cancelled
}