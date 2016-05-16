extension Future {
  func _map<U>(handler: (T, Promise<U>) -> Void) -> Future<U> {
    let mapped = Promise<U>()
    
    self.onCompletion { result in
      switch result {
      case .Success(let value):
        handler(value, mapped)
      case .Error(let error):
        mapped.fail(error)
      case .Cancelled:
        mapped.cancel()
      }
    }

    mapped.onCancel(cancel)
    
    return mapped.future
  }
  
  /**
  Maps a Future<T> into a Future<U> through a function that takes a value of type T and returns a value of type U
   
  - parameter f: The closure that takes a value of type T and returns a value of type U
  
  - returns: A new Future<U> that will behave as the original one w.r.t. cancelation and failure, but will succeed with a value of type U obtained through the given closure
  */
  public func map<U>(f: T -> U) -> Future<U> {
    return _map { value, mapped in
      mapped.succeed(f(value))
    }
  }
  
  /**
   Maps a Future<T> into a Future<U> through a function that takes a value of type T and returns a value of type U
   
   - parameter f: The closure that takes a value of type T and returns a value of type U. Please note the closure can throw
   
   - returns: A new Future<U> that will behave as the original one w.r.t. cancelation and failure, but will succeed with a value of type U obtained through the given closure, unless the latter throws. In this case, the new Future will fail
   */
  public func map<U>(f: T throws -> U) -> Future<U> {
    return _map { value, mapped in
      do {
        mapped.succeed(try f(value))
      } catch {
        mapped.fail(error)
      }
    }
  }
}