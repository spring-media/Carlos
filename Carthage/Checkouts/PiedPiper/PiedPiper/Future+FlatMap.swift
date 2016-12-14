/// Errors that can arise when mapping Futures
public enum FutureMappingError: Error {
  /// When the value can't be mapped
  case cantMapValue
}

extension Future {
  /**
   Maps a Future<T> into a Future<U> through a function that takes a value of type T and returns a value of type U?
   
   - parameter f: The closure that takes a value of type T and returns a value of type U?
   
   - returns: A new Future<U> that will behave as the original one w.r.t. cancelation and failure, but will succeed with a value of type U obtained through the given closure, unless the latter returns nil. In this case, the new Future will fail
   */
  public func flatMap<U>(_ f: @escaping (T) -> U?) -> Future<U> {
    return _map { value, mapped in
      if let mappedValue = f(value) {
        mapped.succeed(mappedValue)
      } else {
        mapped.fail(FutureMappingError.cantMapValue)
      }
    }
  }
  
  /**
   Maps a Future<T> into a Future<U> through a function that takes a value of type T and returns a Result<U>
   
   - parameter f: The closure that takes a value of type T and returns a Result<U>
   
   - returns: A new Future<U> that will behave as the original one w.r.t. cancelation and failure, but will succeed with a value of type U obtained through the given closure if the returned Result is a success. Otherwise, the new Future will fail or get canceled depending on the state of the returned Result
   */
  public func flatMap<U>(_ f: @escaping (T) -> Result<U>) -> Future<U> {
    return _map { value, mapped in
      mapped.mimic(f(value))
    }
  }
  
  /**
   Maps a Future<T> into a Future<U> through a function that takes a value of type T and returns a Future<U>
   
   - parameter f: The closure that takes a value of type T and returns a Future<U>
   
   - returns: A new Future<U> that will behave as the original one w.r.t. cancelation and failure, but will succeed with a value of type U when the given Future will succeed. If the given Future fails or is canceled, the new Future will do so too.
   */
  public func flatMap<U>(_ f: @escaping (T) -> Future<U>) -> Future<U> {
    return _map { value, mapped in
      mapped.mimic(f(value))
    }
  }
}
