import Foundation

public class PoolCache<C: CacheLevel where C.KeyType: Hashable>: CacheLevel {
  public typealias KeyType = C.KeyType
  public typealias OutputType = C.OutputType
  
  private let internalCache: C
  private var requestsPool: [C.KeyType: CacheRequest<C.OutputType>] = [:]
  
  public init(internalCache: C) {
    self.internalCache = internalCache
  }
  
  public func get(fetchable: KeyType) -> CacheRequest<OutputType> {
    let request: CacheRequest<OutputType>
    
    if let pooledRequest = requestsPool[fetchable] {
      Logger.log("Using pooled request \(pooledRequest) for fetchable \(fetchable)")
      request = pooledRequest
    } else {
      request = internalCache.get(fetchable)
      requestsPool[fetchable] = request
      
      Logger.log("Creating a new request \(request) for fetchable \(fetchable)")
      
      request
        .onSuccess({ result in
          self.requestsPool[fetchable] = nil
        })
        .onFailure({ error in
          self.requestsPool[fetchable] = nil
        })
    }
    
    return request
  }
  
  public func set(value: C.OutputType, forKey fetchable: C.KeyType) {
    internalCache.set(value, forKey: fetchable)
  }
  
  public func clear() {
    internalCache.clear()
  }
  
  public func onMemoryWarning() {
    internalCache.onMemoryWarning()
  }
}