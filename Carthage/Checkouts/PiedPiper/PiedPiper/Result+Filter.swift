import Foundation

/// Errors that can arise when filtering Results
public enum ResultFilteringError: Error {
  /// When the filter condition is not satisfied
  case conditionUnsatisfied
}

extension Result {
  /**
   Filters this Result with the given condition
   
   - parameter condition: The condition you want to apply to the boxed value of this Result
   
   - returns: A new Result that will behave as this Result w.r.t. cancellation and failure, but will succeed if the boxed value satisfies the given condition, and fail with ResultFilteringError.ConditionUnsatisfied if the condition is not satisfied
   */
  public func filter(_ condition: (T) -> Bool) -> Result<T> {
    return _map { value in
      if condition(value) {
        return .success(value)
      } else {
        return .error(ResultFilteringError.conditionUnsatisfied)
      }
    }
  }
}
