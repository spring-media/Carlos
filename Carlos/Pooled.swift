import Foundation

/**
Wraps a CacheLevel with a requests pool

:param: cache The cache level you want to decorate

:returns: A PoolCache that will pool requests coming to the decorated cache. This means that multiple requests for the same fetchable will be pooled and only one will be actually done (so that expensive operations like network or file system fetches will only be done once). All onSuccess and onFailure callbacks will be done on the pooled request.
*/
public func pooled<A: CacheLevel where A.KeyType: Hashable>(cache: A) -> PoolCache<A> {
  return PoolCache<A>(internalCache: cache)
}
