import Foundation

public class PoolCache<C: CacheLevel where C.KeyType: Hashable>: CacheLevel {
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