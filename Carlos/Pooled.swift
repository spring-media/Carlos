import Foundation

/**
Wraps a CacheLevel with a requests pool

:param: cache The cache level you want to decorate

:returns: A PoolCache that will pool requests coming to the decorated cache. This means that multiple requests for the same fetchable will be pooled and only one will be actually done (so that expensive operations like network or file system fetches will only be done once). All onSuccess and onFailure callbacks will be done on the pooled request.
*/
public func pooled<A: CacheLevel where A.KeyType: Hashable>(cache: A) -> PoolCache<A.KeyType, A.OutputType, A> {
  return PoolCache<A.KeyType, A.OutputType, A>(internalCache: cache)
}

/// An abstraction for a generic cache level
public protocol CacheLevel {
  /// A typealias for the key the cache level accepts
  typealias KeyType
  
  /// A typealias for the data the cache returns in the success closure
  typealias OutputType
  
  /**
  Tries to get a value from the cache level
  
  :param: fetchable The key of the value you would like to get
  
  :returns: a CacheRequest that you can attach success and failure closures to
  */
  func get(fetchable: KeyType) -> CacheRequest<OutputType>
  
  /**
  Tries to set a value on the cache level
  
  :param: value The bytes to set on the cache level
  :param: fetchable The key of the value you're trying to set
  */
  func set(value: OutputType, forKey fetchable: KeyType)
  
  /**
  Asks to clear the cache level
  */
  func clear()
  
  /**
  Notifies the cache level that a memory warning was thrown, and asks it to do its best to clean some memory
  */
  func onMemoryWarning()
}