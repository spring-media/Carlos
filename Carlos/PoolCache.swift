import Foundation

/**
Wraps a CacheLevel with a requests pool

:param: cache The cache level you want to decorate

:returns: A PoolCache that will pool requests coming to the decorated cache. This means that multiple requests for the same key will be pooled and only one will be actually done (so that expensive operations like network or file system fetches will only be done once). All onSuccess and onFailure callbacks will be done on the pooled request.
*/
public func pooled<A: CacheLevel where A.KeyType: Hashable>(cache: A) -> PoolCache<A> {
  return PoolCache(internalCache: cache)
}

/**
Wraps a fetcher closure with a requests pool

:param: fetcherClosure The fetcher closure you want to decorate

:returns: A PoolCache that will pool requests coming to the closure. This means that multiple requests for the same key will be pooled and only one will be actually done (so that expensive operations like network or file system fetches will only be done once). All onSuccess and onFailure callbacks will be done on the pooled request.
*/
public func pooled<A, B>(fetcherClosure: (key: A) -> CacheRequest<B>) -> PoolCache<BasicCache<A, B>> {
  return pooled(wrapClosureIntoCacheLevel(fetcherClosure))
}

public final class PoolCache<C: CacheLevel where C.KeyType: Hashable>: CacheLevel {
  public typealias KeyType = C.KeyType
  public typealias OutputType = C.OutputType
  
  private let internalCache: C
  private var requestsPool: [C.KeyType: CacheRequest<C.OutputType>] = [:]
  
  public init(internalCache: C) {
    self.internalCache = internalCache
  }
  
  public func get(key: KeyType) -> CacheRequest<OutputType> {
    let request: CacheRequest<OutputType>
    
    if let pooledRequest = requestsPool[key] {
      Logger.log("Using pooled request \(pooledRequest) for key \(key)")
      request = pooledRequest
    } else {
      request = internalCache.get(key)
      requestsPool[key] = request
      
      Logger.log("Creating a new request \(request) for key \(key)")
      
      request
        .onSuccess({ result in
          self.requestsPool[key] = nil
        })
        .onFailure({ error in
          self.requestsPool[key] = nil
        })
    }
    
    return request
  }
  
  public func set(value: C.OutputType, forKey key: C.KeyType) {
    internalCache.set(value, forKey: key)
  }
  
  public func clear() {
    internalCache.clear()
  }
  
  public func onMemoryWarning() {
    internalCache.onMemoryWarning()
  }
}