/// Typical Result enumeration (aka Either)
public enum Result<T> {
  /// The result contains a Success value
  case Success(T)
  
  /// The result contains an error
  case Error(ErrorType)
  
  /// The result was cancelled
  case Cancelled
  
  //TODO: Expose in a later version
  func map<U>(handler: T -> U) -> Future<U> {
    let mapped = Promise<U>()
    
    switch self {
    case .Success(let value):
      mapped.succeed(handler(value))
    case .Error(let error):
      mapped.fail(error)
    case .Cancelled:
      mapped.cancel()
    }
    
    return mapped.future
  }
}