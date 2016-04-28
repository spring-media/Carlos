import Foundation

/// Errors that can arise when filtering Results
public enum ResultFilteringError: ErrorType {
  /// When the filter condition is not satisfied
  case ConditionUnsatisfied
}

extension Result {
  /**
   Filters this Result with the given condition
   
   - parameter condition: The condition you want to apply to the boxed value of this Result
   
   - returns: A new Result that will behave as this Result w.r.t. cancellation and failure, but will succeed if the boxed value satisfies the given condition, and fail with ResultFilteringError.ConditionUnsatisfied if the condition is not satisfied
   */
  public func filter(condition: T -> Bool) -> Result<T> {
    return _map { value in
      if condition(value) {
        return .Success(value)
      } else {
        return .Error(ResultFilteringError.ConditionUnsatisfied)
      }
    }
  }
}