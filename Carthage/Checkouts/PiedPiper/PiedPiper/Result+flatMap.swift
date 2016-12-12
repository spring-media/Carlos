extension Result {
  /**
   Flat maps this Result with the given handler returning a Future
   
   - parameter handler: The flat mapping handler that takes the boxed value of this Result and returns a Future
   
   - returns: A Future that will behave as this Result w.r.t. cancellation and failure, but will behave as the future obtained by calling the handler with the boxed value if this Result is .Success
   */
  public func flatMap<U>(_ handler: (T) -> Future<U>) -> Future<U> {
    return _map { value, flatMapped in
      flatMapped.mimic(handler(value))
    }
  }
  
  /**
   Flat maps this Result with the given handler returning another Result
   
   - parameter handler: The flat mapping handler that takes the boxed value of this Result and returns another Result
   
   - returns: A new Result that will behave as this Result w.r.t. cancellation and failure, but will behave as the Result obtained by calling the handler with the boxed value if this Result is .Success
   */
  public func flatMap<U>(_ handler: (T) -> Result<U>) -> Result<U> {
    return _map(handler)
  }
  
  /**
   Flat maps this Result with the given handler returning an optional U
   
   - parameter handler: The flat mapping handler that takes the boxed value of this Result and returns an optional U
   
   - returns: A new Result that will behave as this Result w.r.t. cancellation and failure, but will succeed with a value of type U obtained by calling the handler with the boxed value if this Result is .Success, unless the value is nil, in which case it will fail with a ResultMappingError.CantMapValue error
   */
  public func flatMap<U>(_ handler: (T) -> U?) -> Result<U> {
    return _map { value in
      if let mappedValue = handler(value) {
        return .success(mappedValue)
      } else {
        return .error(ResultMappingError.cantMapValue)
      }
    }
  }
}
