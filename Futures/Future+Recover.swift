extension Future {
  private func _recover(handler: Promise<T> -> Void) -> Future<T> {
    let recovered = Promise<T>()
    
    onCompletion { result in
      switch result {
      case .Success(let value):
        recovered.succeed(value)
      case .Error:
        handler(recovered)
      case .Cancelled:
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
  public func recover(handler: Void -> T) -> Future<T> {
    return _recover { recovered in
      recovered.succeed(handler())
    }
  }
  
  /**
   Recovers this Future so that if it fails it can actually use the "rescue value"
   
   - parameter handler: The rescue value
   
   - returns: A new Future that will behave as this Future, except when this Future fails. In that case, it will succeed with the rescue value
   */
  public func recover(value: T) -> Future<T> {
    return recover({ value })
  }
  
  /**
   Recovers this Future so that if it fails it can actually use a "rescue value"
   
   - parameter handler: The closure that provides a Future that will try to provide a rescue value
   
   - returns: A new Future that will behave as this Future, except when this Future fails. In that case, it will mimic the outcome of the Future provided by the handler
   */
  public func recover(handler: Void -> Future<T>) -> Future<T> {
    return _recover { recovered in
      recovered.mimic(handler())
    }
  }
  
  /**
   Recovers this Future so that if it fails it can actually use a "rescue value"
   
   - parameter handler: The closure that provides a Result that will try to provide a rescue value
   
   - returns: A new Future that will behave as this Future, except when this Future fails. In that case, it will mimic the outcome of the Result provided by the handler
   */
  public func recover(handler: Void -> Result<T>) -> Future<T> {
    return _recover { recovered in
      recovered.mimic(handler())
    }
  }
}