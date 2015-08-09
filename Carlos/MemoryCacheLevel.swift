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
public final class MemoryCacheLevel<K: StringConvertible, T: AnyObject where T: ExpensiveObject>: CacheLevel {
  /// At the moment the memory cache level only accepts String keys
  public typealias KeyType = K
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
  
  /**
  Synchronously gets a value for the given key
  
  :param: key The key for the value
  
  :returns: A CacheRequest where you can call onSuccess and onFailure to be notified of the result of the fetch
  */
  public func get(key: KeyType) -> CacheRequest<OutputType> {
    let request = CacheRequest<T>()
    if let result = internalCache.objectForKey(key.toString()) as? T {
      Logger.log("Fetched \(key.toString()) on memory level")
      request.succeed(result)
    } else {
      Logger.log("Failed fetching \(key.toString()) on the memory cache")
      request.fail(errorWithCode(FetchError.ValueNotInCache.rawValue))
    }
    
    return request
  }
  
  /**
  Clears the contents of the cache
  */
  public func onMemoryWarning() {
    clear()
  }
  
  /**
  Sets a value for the given key
  
  :param: value The value to set
  :param: key The key for the value
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