/// Typical Result enumeration (aka Either)
public enum Result<T> {
  /// The result contains a Success value
  case success(T)
  
  /// The result contains an error
  case error(Error)
  
  /// The result was cancelled
  case cancelled
  
  /// The success value of this result, if any
  public var value: T? {
    if case .success(let result) = self {
      return result
    } else {
      return nil
    }
  }
  
  /// The error of this result, if any
  public var error: Error? {
    if case .error(let issue) = self {
      return issue
    } else {
      return nil
    }
  }
}
