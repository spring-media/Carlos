import Foundation

/// Abstracts objects that have a cost (useful for the MemoryCacheLevel)
public protocol ExpensiveObject {
  /// The cost of the object
  var cost: Int { get }
}

extension NSData: ExpensiveObject {
  /// The number of bytes of the data block
  public var cost: Int {
    return self.length
  }
}

extension String: ExpensiveObject {
  /// The number of characters of the string
  public var cost: Int {
    return count(self)
  }
}

extension NSString: ExpensiveObject {
  /// The number of characters of the NSString
  public var cost: Int {
    return self.length
  }
}

extension UIImage: ExpensiveObject {
  /// The size of the image in pixels (W x H)
  public var cost: Int {
    return Int(size.width * size.height)
  }
}

extension NSURL: ExpensiveObject {
  /// The size of the URL 
  public var cost: Int {
    return absoluteString!.cost
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
  
  public func get(key: KeyType) -> CacheRequest<OutputType> {
    let request = CacheRequest<T>()
    if let result = internalCache.objectForKey(key) as? T {
      Logger.log("Fetched \(key) on memory level")
      request.succeed(result)
    } else {
      Logger.log("Failed fetching \(key) on the memory cache")
      request.fail(errorWithCode(FetchError.ValueNotInCache.rawValue))
    }
    
    return request
  }
  
  public func onMemoryWarning() {
    clear()
  }
  
  public func set(value: T, forKey key: String) {
    Logger.log("Setting a value for the key \(key) on the memory cache \(self)")
    internalCache.setObject(value, forKey: key, cost: value.cost)
  }
  
  public func clear() {
    internalCache.removeAllObjects()
  }
}