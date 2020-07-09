import Foundation

public enum FetchError: Error {
  /// Used when a cache level doesn't have a value in the cache
  case valueNotInCache
  
  /// Used when no cache level did find the key
  case noCacheLevelsRemaining
  
  /// Used when the specified key was invalid
  case invalidKey
  
  /// Used when some cached data was found but was likely corrupted
  case invalidCachedData
  
  /// Used when the key doesn't satisfy the cache condition
  case conditionNotSatisfied
  
  /// Used when a key transformation failed and the cache level had to skip a get operation
  case keyTransformationFailed
  
  /// Used when a value transformation failed and the cache level had to skip a get operation
  case valueTransformationFailed
}
