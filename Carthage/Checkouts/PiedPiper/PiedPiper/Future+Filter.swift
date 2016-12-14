/// Errors that can arise when filtering Futures
public enum FutureFilteringError: Error {
  /// When the filter condition is not satisfied
  case conditionUnsatisfied
}

extension Future {
  /**
  Filters the Future with a condition
   
  - parameter filter: The condition closure that determines whether the result of the Future is valid or not
   
  - result: A new Future that only succeeds if the original Future succeeds with a value that passes the given condition
  */
  public func filter(_ filter: @escaping (T) -> Bool) -> Future<T> {
    return _map { value, mapped in
      if filter(value) {
        mapped.succeed(value)
      } else {
        mapped.fail(FutureFilteringError.conditionUnsatisfied)
      }
    }
  }
  
  /**
  Filters the Future with a condition Future
   
  - parameter filter: The condition Future that determines whether the result of the Future is valid or not
   
  - result: A new Future that only succeeds if the original Future succeeds with a value that succeeds the Future returned by the given condition
  */
  public func filter(_ filter: @escaping (T) -> Future<Bool>) -> Future<T> {
    return _map { value, mapped in
      filter(value).onCompletion { filterResult in
        switch filterResult {
        case .success(let result):
          if result {
            mapped.succeed(value)
          } else {
            mapped.fail(FutureFilteringError.conditionUnsatisfied)
          }
        case .error(let error):
          mapped.fail(error)
        case .cancelled:
          mapped.cancel()
        }
      }
    }
  }
}
