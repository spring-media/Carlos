import Foundation

public enum FetchError: ErrorType {
  /// Used when a cache level doesn't have a value in the cache
  case ValueNotInCache
  
  /// Used when no cache level did find the key
  case NoCacheLevelsRemaining
  
  /// Used when the specified key was invalid
  case InvalidKey
  
  /// Used when some cached data was found but was likely corrupted
  case InvalidCachedData
  
  /// Used when the key doesn't satisfy the cache condition
  case ConditionNotSatisfied
  
  /// Used when a key transformation failed and the cache level had to skip a get operation
  case KeyTransformationFailed
  
  /// Used when a value transformation failed and the cache level had to skip a get operation
  case ValueTransformationFailed
}
