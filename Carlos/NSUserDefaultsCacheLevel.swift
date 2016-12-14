import Foundation
import PiedPiper

/** 
Default name for the persistent domain used by the NSUserDefaultsCacheLevel

Keep in mind that using this domain for multiple cache levels at the same time could lead to undesired results!
For example, if one of the cache levels get cleared, also the other will be affected unless they save something before leaving the app.
The behavior is not 100% certain and this possibility is discouraged.
*/
private let DefaultUserDefaultsDomainName = "CarlosPersistentDomain"

/// This class is a NSUserDefaults cache level. It has a configurable domain name so that multiple levels can be included in the same sandboxed app.
public final class NSUserDefaultsCacheLevel<K: StringConvertible, T: NSCoding>: CacheLevel {
  /// The key type of the cache, should be convertible to String values
  public typealias KeyType = K
  
  /// The output type of the cache, should conform to NSCoding
  public typealias OutputType = T
  
  private let domainName: String
  private let lock: ReadWriteLock
  private let userDefaults: UserDefaults
  private var internalDomain: [String: Data]? = nil
  private var safeInternalDomain: [String: Data] {
    if let internalDomain = internalDomain {
      return internalDomain
    } else {
      let fetchedDomain = (userDefaults.persistentDomain(forName: domainName) as? [String: Data]) ?? [:]
      internalDomain = fetchedDomain
      return fetchedDomain
    }
  }
  
  /**
  Creates a new instance of this NSUserDefaults-based cache level.
   
  - parameter name: The name to use for the persistent domain on NSUserDefaults. Should be unique in your sandboxed app
  */
  public init(name: String = DefaultUserDefaultsDomainName) {
    self.domainName = name
    
    lock = PThreadReadWriteLock()
    userDefaults = UserDefaults.standard
    internalDomain = safeInternalDomain
  }
  
  /**
  Sets a new value for the given key
   
  - parameter value: The value to set for the given key
  - parameter key: The key you want to set
   
  This method will convert the value to NSData by using NSCoding and save the data on the persistent domain.
   
  A soft-cache is used to avoid hitting the persistent domain everytime you are going to fetch values from this cache. The operation is thread-safe
  */
  public func set(_ value: OutputType, forKey key: KeyType) -> Future<()> {
    var softCache = safeInternalDomain
    let result = Promise<()>()
    
    Logger.log("Setting a value for the key \(key.toString()) on the user defaults cache \(self)")
    lock.withWriteLock {
      softCache[key.toString()] = NSKeyedArchiver.archivedData(withRootObject: value)
      internalDomain = softCache
      userDefaults.setPersistentDomain(softCache, forName: domainName)
      
      result.succeed()
    }
    
    return result.future
  }
  
  /**
  Fetches a value on the persistent domain for the given key
   
  - parameter key: The key you want to fetch
  
  - returns: The result of this fetch on the cache
   
  A soft-cache is used to avoid hitting the persistent domain everytime. This operation is thread-safe
  */
  public func get(_ key: KeyType) -> Future<OutputType> {
    let result = Promise<OutputType>()
    
    if let cachedValue = lock.withReadLock({ safeInternalDomain[key.toString()] }) {
      if let unencodedObject = NSKeyedUnarchiver.su_unarchiveObject(with: cachedValue) as? T {
        Logger.log("Fetched \(key.toString()) on user defaults level (domain \(domainName)")
        result.succeed(unencodedObject)
      } else {
        Logger.log("Failed fetching \(key.toString()) on the user defaults cache (domain \(domainName), corrupted data")
        result.fail(FetchError.invalidCachedData)
      }
    } else {
      Logger.log("Failed fetching \(key.toString()) on the user defaults cache (domain \(domainName), no data")
      result.fail(FetchError.valueNotInCache)
    }
    
    return result.future
  }
  
  /**
  Completely clears the contents of this cache
   
  Please keep in mind that if the same name is used for multiple cache levels, the contents of these caches will also be cleared, at least from a persistence point of view. 
  The soft caches of the other levels will still contain consistent values, though, so setting a value on one of these levels will result in the whole previous content of the cache to be persisted on NSUserDefaults, even this may or may not be the desired behavior.
  The conclusion is that you should only use the same name for multiple cache levels if you are aware of the consequences. In general the behavior may not be the expected one.
   
  The operation is thread-safe
  */
  public func clear() {
    lock.withWriteLock {
      userDefaults.removePersistentDomain(forName: domainName)
      internalDomain = [:]
    }
  }
  
  /**
  Clears the contents of the soft cache for this cache level.
   
  Fetching or setting a value after this call is safe, since the content will be pre-fetched from the disk immediately before.
   
  The operation is thread-safe
  */
  public func onMemoryWarning() {
    lock.withWriteLock {
      internalDomain = nil
    }
  }
}
