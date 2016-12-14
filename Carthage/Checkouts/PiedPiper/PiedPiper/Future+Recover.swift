extension Future {
  private func _recover(_ handler: @escaping (Promise<T>) -> Void) -> Future<T> {
    let recovered = Promise<T>()
    
    onCompletion { result in
      switch result {
      case .success(let value):
        recovered.succeed(value)
      case .error:
        handler(recovered)
      case .cancelled:
        recovered.cancel()
      }
    }
    
    return recovered.future
  }
  
  /**
  Recovers this Future so that if it fails it can actually use the "rescue value"
   
  - parameter handler: The closure that provides the rescue value
   
  - returns: A new Future that will behave as this Future, except when this Future fails. In that case, it will succeed with the rescue value
  */
  public func recover(_ handler: @escaping (Void) -> T) -> Future<T> {
    return _recover { recovered in
      recovered.succeed(handler())
    }
  }
  
  /**
   Recovers this Future so that if it fails it can actually use the "rescue value"
   
   - parameter handler: The rescue value
   
   - returns: A new Future that will behave as this Future, except when this Future fails. In that case, it will succeed with the rescue value
   */
  public func recover(_ value: T) -> Future<T> {
    return recover({ value })
  }
  
  /**
   Recovers this Future so that if it fails it can actually use a "rescue value"
   
   - parameter handler: The closure that provides a Future that will try to provide a rescue value
   
   - returns: A new Future that will behave as this Future, except when this Future fails. In that case, it will mimic the outcome of the Future provided by the handler
   */
  public func recover(_ handler: @escaping (Void) -> Future<T>) -> Future<T> {
    return _recover { recovered in
      recovered.mimic(handler())
    }
  }
  
  /**
   Recovers this Future so that if it fails it can actually use a "rescue value"
   
   - parameter handler: The closure that provides a Result that will try to provide a rescue value
   
   - returns: A new Future that will behave as this Future, except when this Future fails. In that case, it will mimic the outcome of the Result provided by the handler
   */
  public func recover(_ handler: @escaping (Void) -> Result<T>) -> Future<T> {
    return _recover { recovered in
      recovered.mimic(handler())
    }
  }
}
