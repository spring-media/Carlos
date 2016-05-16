/// Typical Result enumeration (aka Either)
public enum Result<T> {
  /// The result contains a Success value
  case Success(T)
  
  /// The result contains an error
  case Error(ErrorType)
  
  /// The result was cancelled
  case Cancelled
  
  /// The success value of this result, if any
  public var value: T? {
    if case .Success(let result) = self {
      return result
    } else {
      return nil
    }
  }
  
  /// The error of this result, if any
  public var error: ErrorType? {
    if case .Error(let issue) = self {
      return issue
    } else {
      return nil
    }
  }
}