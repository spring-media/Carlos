import Foundation
import PiedPiper

/// This class is a memory cache level. It internally uses NSCache, and has a configurable total cost limit that defaults to 50 MB.
public final class MemoryCacheLevel<K: StringConvertible, T: AnyObject where T: ExpensiveObject>: CacheLevel {
  /// At the moment the memory cache level only accepts String keys
  public typealias KeyType = K
  public typealias OutputType = T
  
  private let internalCache: NSCache
  
  /**
  Initializes a new memory cache level

  - parameter cost: The total cost limit for the memory cache. Defaults to 50 MB
  */
  public init(capacity: Int = 50 * 1024 * 1024) {
    internalCache = NSCache()
    internalCache.totalCostLimit = capacity
  }
  
  /**
  Synchronously gets a value for the given key
  
  - parameter key: The key for the value
  
  - returns: A Future where you can call onSuccess and onFailure to be notified of the result of the fetch
  */
  public func get(key: KeyType) -> Future<OutputType> {
    let request = Promise<T>()
    if let result = internalCache.objectForKey(key.toString()) as? T {
      Logger.log("Fetched \(key.toString()) on memory level")
      request.succeed(result)
    } else {
      Logger.log("Failed fetching \(key.toString()) on the memory cache")
      request.fail(FetchError.ValueNotInCache)
    }
    
    return request.future
  }
  
  /**
  Clears the contents of the cache
  */
  public func onMemoryWarning() {
    clear()
  }
  
  /**
  Sets a value for the given key
  
  - parameter value: The value to set
  - parameter key: The key for the value
  */
  public func set(value: T, forKey key: K) {
    Logger.log("Setting a value for the key \(key.toString()) on the memory cache \(self)")
    internalCache.setObject(value, forKey: key.toString(), cost: value.cost)
  }
  
  /**
  Clears the contents of the cache
  */
  public func clear() {
    internalCache.removeAllObjects()
  }
}