/// Typical Result enumeration (aka Either)
public enum Result<T> {
  /// The result contains a Success value
  case Success(T)
  
  /// The result contains an error
  case Error(ErrorType)
  
  /// The result was cancelled
  case Cancelled
  
  private func _map<U>(handler: (T, Promise<U>) -> Void) -> Future<U> {
    let mapped = Promise<U>()
    
    switch self {
    case .Success(let value):
      handler(value, mapped)
    case .Error(let error):
      mapped.fail(error)
    case .Cancelled:
      mapped.cancel()
    }
    
    return mapped.future
  }
  
  //TODO: Expose in a later version
  func map<U>(handler: T -> U) -> Future<U> {
    return _map { value, mapped in
      mapped.succeed(handler(value))
    }
  }
  
  //TODO: Expose in a later version
  func flatMap<U>(handler: T -> Future<U>) -> Future<U> {
    return _map { value, flatMapped in
      flatMapped.mimic(handler(value))
    }
  }
}