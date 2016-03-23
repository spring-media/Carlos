import Foundation
import PiedPiper

extension CacheLevel where KeyType: Hashable {
  
  /**
  Wraps the CacheLevel with a requests pool
  
  - returns: A PoolCache that will pool requests coming to the decorated cache. This means that multiple requests for the same key will be pooled and only one will be actually done (so that expensive operations like network or file system fetches will only be done once). All onSuccess and onFailure callbacks will be done on the pooled request.
  */
  public func pooled() -> PoolCache<Self> {
    return PoolCache(internalCache: self)
  }
}

/**
Wraps a CacheLevel with a requests pool

- parameter cache: The cache level you want to decorate

- returns: A PoolCache that will pool requests coming to the decorated cache. This means that multiple requests for the same key will be pooled and only one will be actually done (so that expensive operations like network or file system fetches will only be done once). All onSuccess and onFailure callbacks will be done on the pooled request.
*/
@available(*, deprecated=0.5)
public func pooled<A: CacheLevel where A.KeyType: Hashable>(cache: A) -> PoolCache<A> {
  return cache.pooled()
}

/**
Wraps a fetcher closure with a requests pool

- parameter fetcherClosure: The fetcher closure you want to decorate

- returns: A PoolCache that will pool requests coming to the closure. This means that multiple requests for the same key will be pooled and only one will be actually done (so that expensive operations like network or file system fetches will only be done once). All onSuccess and onFailure callbacks will be done on the pooled request.
*/
@available(*, deprecated=0.5)
public func pooled<A, B>(fetcherClosure: (key: A) -> Future<B>) -> PoolCache<BasicFetcher<A, B>> {
  return wrapClosureIntoFetcher(fetcherClosure).pooled()
}

/**
A CacheLevel that pools incoming get requests. This means that multiple requests for the same key will be pooled and only one will be actually executed (so that expensive operations like network or file system fetches will only be done once).
*/
public final class PoolCache<C: CacheLevel where C.KeyType: Hashable>: CacheLevel {
  public typealias KeyType = C.KeyType
  public typealias OutputType = C.OutputType
  
  private let internalCache: C
  private let lock: ReadWriteLock = PThreadReadWriteLock()
  private var requestsPool: [C.KeyType: Future<C.OutputType>] = [:]
  
  /**
  Creates a new instance of a pooled cache
  
  - parameter internalCache: The CacheLevel instance that this pooled cache will manage
  */
  public init(internalCache: C) {
    self.internalCache = internalCache
  }
  
  /**
  Asks the cache to get the value for the given key
  
  - parameter key: The key for the value
  
  - returns: A Future that could either have been just created or it could have been reused from a pool of pending Futures if there is a Future for the same key going on at the moment.
  */
  public func get(key: KeyType) -> Future<OutputType> {
    let request: Future<OutputType>
    
    if let pooledRequest = lock.withReadLock ({ self.requestsPool[key] }) {
      Logger.log("Using pooled request \(pooledRequest) for key \(key)")
      request = pooledRequest
    } else {
      request = internalCache.get(key)
      
      lock.withWriteLock {
        self.requestsPool[key] = request
      }
      
      Logger.log("Creating a new request \(request) for key \(key)")
      
      request
        .onCompletion { _ in
          self.lock.withWriteLock {
            self.requestsPool[key] = nil
          }
        }
    }
    
    return request
  }
  
  /**
  Sets a value for the given key on the managed cache
  
  - parameter value: The value to set
  - parameter key: The key for the value
  */
  public func set(value: C.OutputType, forKey key: C.KeyType) {
    internalCache.set(value, forKey: key)
  }
  
  /**
  Clears the managed cache
  */
  public func clear() {
    internalCache.clear()
  }
  
  /**
  Notifies the managed cache that a memory warning event was thrown
  */
  public func onMemoryWarning() {
    internalCache.onMemoryWarning()
  }
}