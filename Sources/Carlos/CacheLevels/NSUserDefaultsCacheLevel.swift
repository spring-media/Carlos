import Combine
import Foundation

/**
 Default name for the persistent domain used by the NSUserDefaultsCacheLevel

 Keep in mind that using this domain for multiple cache levels at the same time could lead to undesired results!
 For example, if one of the cache levels get cleared, also the other will be affected unless they save something before leaving the app.
 The behavior is not 100% certain and this possibility is discouraged.
 */
public let DefaultUserDefaultsDomainName = "CarlosPersistentDomain"

/// This class is a NSUserDefaults cache level. It has a configurable domain name so that multiple levels can be included in the same sandboxed app.
public final class NSUserDefaultsCacheLevel<K: StringConvertible, T: NSCoding>: CacheLevel {
  /// The key type of the cache, should be convertible to String values
  public typealias KeyType = K

  /// The output type of the cache, should conform to NSCoding
  public typealias OutputType = T

  private let domainName: String
  private let lock: UnfairLock
  private let userDefaults: UserDefaults
  private var internalDomain: [String: Data]?
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
    domainName = name

    lock = UnfairLock()
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
  public func set(_ value: OutputType, forKey key: KeyType) -> AnyPublisher<Void, Error> {
    AnyPublisher.create { [weak self] promise in
      guard let self = self else {
        return
      }

      var softCache = self.safeInternalDomain

      Logger.log("Setting a value for the key \(key.toString()) on the user defaults cache \(self)")

      if let data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false) {
        softCache[key.toString()] = data
        self.internalDomain = softCache
        self.userDefaults.setPersistentDomain(softCache, forName: self.domainName)

        promise(.success(()))
      } else {
        Logger.log("Failed setting a value for the key \(key.toString()) on the user defaults cache \(self)")

        promise(.failure(FetchError.invalidCachedData))
      }
    }
    .eraseToAnyPublisher()
  }

  /**
   Fetches a value on the persistent domain for the given key

   - parameter key: The key you want to fetch

   - returns: The result of this fetch on the cache

   A soft-cache is used to avoid hitting the persistent domain everytime. This operation is thread-safe
   */
  public func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    AnyPublisher.create { [weak self] promise in
      guard let self = self else {
        return
      }

      if let cachedValue = self.safeInternalDomain[key.toString()] {
        if let unencodedObject = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cachedValue) as? T {
          Logger.log("Fetched \(key.toString()) on user defaults level (domain \(self.domainName)")
          promise(.success(unencodedObject))
        } else {
          Logger.log("Failed fetching \(key.toString()) on the user defaults cache (domain \(self.domainName), corrupted data")
          promise(.failure(FetchError.invalidCachedData))
        }
      } else {
        Logger.log("Failed fetching \(key.toString()) on the user defaults cache (domain \(self.domainName), no data")
        promise(.failure(FetchError.valueNotInCache))
      }
    }
    .eraseToAnyPublisher()
  }

  public func remove(_ key: K) -> AnyPublisher<Void, Error> {
    AnyPublisher.create { [weak self] promise in
      self?.userDefaults.removeObject(forKey: key.toString())
      promise(.success(()))
    }
  }

  /**
   Completely clears the contents of this cache

   Please keep in mind that if the same name is used for multiple cache levels, the contents of these caches will also be cleared, at least from a persistence point of view.
   The soft caches of the other levels will still contain consistent values, though, so setting a value on one of these levels will result in the whole previous content of the cache to be persisted on NSUserDefaults, even this may or may not be the desired behavior.
   The conclusion is that you should only use the same name for multiple cache levels if you are aware of the consequences. In general the behavior may not be the expected one.

   The operation is thread-safe
   */
  public func clear() {
    lock.locked {
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
    lock.locked {
      internalDomain = nil
    }
  }
}
