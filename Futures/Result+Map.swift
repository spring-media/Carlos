/// Errors that can arise when mapping Results
public enum ResultMappingError: ErrorType {
  /// When the boxed value can't be mapped
  case CantMapValue
}

extension Result {
  func _map<U>(handler: (T, Promise<U>) -> Void) -> Future<U> {
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
  
  func _map<U>(handler: T -> Result<U>) -> Result<U> {
    switch self {
    case .Success(let value):
      return handler(value)
    case .Error(let error):
      return .Error(error)
    case .Cancelled:
      return .Cancelled
    }
  }
  
  /**
   Maps this Result using a simple transformation closure
   
   - parameter handler: The closure to use to map the boxed value of this Result
   
   - returns: A new Result that will behave as this Result w.r.t. cancellation and failure, but will succeed with a value of type U obtained through the given closure
   */
  public func map<U>(handler: T -> U) -> Result<U> {
    return _map {
      .Success(handler($0))
    }
  }
  
  /**
   Maps this Result using a simple transformation closure
   
   - parameter handler: The closure to use to map the boxed value of this Result
   
   - returns: A new Result that will behave as this Result w.r.t. cancellation and failure, but will succeed with a value of type U obtained through the given closure, unless the latter throws. In this case, the new Result will fail
   */
  public func map<U>(handler: T throws -> U) -> Result<U> {
    return _map { value in
      do {
        let mappedValue = try handler(value)
        return .Success(mappedValue)
      } catch {
        return .Error(error)
      }
    }
  }
}