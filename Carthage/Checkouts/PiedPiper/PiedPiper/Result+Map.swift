/// Errors that can arise when mapping Results
public enum ResultMappingError: Error {
  /// When the boxed value can't be mapped
  case cantMapValue
}

extension Result {
  func _map<U>(_ handler: (T, Promise<U>) -> Void) -> Future<U> {
    let mapped = Promise<U>()
    
    switch self {
    case .success(let value):
      handler(value, mapped)
    case .error(let error):
      mapped.fail(error)
    case .cancelled:
      mapped.cancel()
    }
    
    return mapped.future
  }
  
  func _map<U>(_ handler: (T) -> Result<U>) -> Result<U> {
    switch self {
    case .success(let value):
      return handler(value)
    case .error(let error):
      return .error(error)
    case .cancelled:
      return .cancelled
    }
  }
  
  /**
   Maps this Result using a simple transformation closure
   
   - parameter handler: The closure to use to map the boxed value of this Result
   
   - returns: A new Result that will behave as this Result w.r.t. cancellation and failure, but will succeed with a value of type U obtained through the given closure
   */
  public func map<U>(_ handler: (T) -> U) -> Result<U> {
    return _map {
      .success(handler($0))
    }
  }
  
  /**
   Maps this Result using a simple transformation closure
   
   - parameter handler: The closure to use to map the boxed value of this Result
   
   - returns: A new Result that will behave as this Result w.r.t. cancellation and failure, but will succeed with a value of type U obtained through the given closure, unless the latter throws. In this case, the new Result will fail
   */
  public func map<U>(_ handler: (T) throws -> U) -> Result<U> {
    return _map { value in
      do {
        let mappedValue = try handler(value)
        return .success(mappedValue)
      } catch {
        return .error(error)
      }
    }
  }
}
