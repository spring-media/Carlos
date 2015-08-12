import Foundation

/// The error domain used for Carlos errors
public let CarlosErrorDomain = "CarlosErrorDomain"

public enum FetchError: Int {
  /// Used when a cache level doesn't have a value in the cache
  case ValueNotInCache = 10100
  
  /// Used when no cache level did find the key
  case NoCacheLevelsRemaining = 9900
  
  /// Used when the specified key was invalid
  case InvalidKey = 8900
  
  /// Used when the key doesn't satisfy the cache condition
  case ConditionNotSatisfied = 8901
  
  /// Used when a key transformation failed and the cache level had to skip a get operation
  case KeyTransformationFailed = 8902
  
  /// Used when a value transformation failed and the cache level had to skip a get operation
  case ValueTransformationFailed = 8903
}

internal func errorWithCode(code: Int) -> NSError {
  return NSError(domain: CarlosErrorDomain, code: code, userInfo: nil)
}

/**
Builds a convenience NSError with error code FetchError.ValueNotInCache

:returns: An initialized NSError with the Carlos error domain and the ValueNotInCache error code.

:discussion: The userInfo dictionary is empty
*/
public func valueNotInCacheError() -> NSError {
  return errorWithCode(FetchError.ValueNotInCache.rawValue)
}