import Foundation

public protocol ExpensiveObject {
  var cost: Int { get }
}

extension NSData: ExpensiveObject {
  public var cost: Int {
    return self.length
  }
}

extension String: ExpensiveObject {
  public var cost: Int {
    return count(self)
  }
}

extension NSString: ExpensiveObject {
  public var cost: Int {
    return self.length
  }
}

/// This class is a memory cache level. It internally uses NSCache, and has a configurable total cost limit that defaults to 50 MB.
public final class MemoryCacheLevel<T: AnyObject where T: ExpensiveObject>: CacheLevel {
  public typealias KeyType = String
  public typealias OutputType = T
  
  private let internalCache: NSCache
  
  /**
  Initializes a new memory cache level

  :param: cost The total cost limit for the memory cache. Defaults to 50 MB
  */
  public init(capacity: Int = 50 * 1024 * 1024) {
    internalCache = NSCache()
    internalCache.totalCostLimit = capacity
  }
  
  public func get(fetchable: KeyType) -> CacheRequest<OutputType> {
    let request = CacheRequest<T>()
    if let result = internalCache.objectForKey(fetchable) as? T {
      Logger.log("Fetched \(fetchable) on memory level")
      request.succeed(result)
    } else {
      Logger.log("Failed fetching \(fetchable) on the memory cache")
      request.fail(errorWithCode(FetchError.ValueNotInCache.rawValue))
    }
    
    return request
  }
  
  public func onMemoryWarning() {
    clear()
  }
  
  public func set(value: T, forKey fetchable: String) {
    Logger.log("Setting a value for the key \(fetchable) on the memory cache \(self)")
    internalCache.setObject(value, forKey: fetchable, cost: value.cost)
  }
  
  public func clear() {
    internalCache.removeAllObjects()
  }
}