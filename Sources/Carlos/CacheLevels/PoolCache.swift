import Combine
import Foundation

extension CacheLevel where KeyType: Hashable {
  /// Wraps the CacheLevel with a requests pool
  ///
  /// - Returns: A `PoolCache` that will pool requests coming to the decorated cache.
  ///            This means that multiple requests for the same key will be pooled and only one will be actually done
  ///            (so that expensive operations like network or file system fetches will only be done once).
  public func pooled() -> PoolCache<Self> {
    PoolCache(internalCache: self)
  }
}

/// A CacheLevel that pools incoming get requests.
///
/// This means that multiple requests for the same key will be pooled and only one will be actually executed
/// (so that expensive operations like network or file system fetches will only be done once).
public final class PoolCache<C: CacheLevel>: CacheLevel where C.KeyType: Hashable {
  public typealias KeyType = C.KeyType
  public typealias OutputType = C.OutputType

  private let internalCache: C
  private let lock: UnfairLock
  private var requestsPool: [C.KeyType: AnyPublisher<C.OutputType, Error>] = [:]

  /// Creates a new instance of a pooled cache
  ///
  /// - Parameter internalCache: The CacheLevel instance that this pooled cache will manage
  public init(internalCache: C) {
    self.internalCache = internalCache
    lock = UnfairLock()
  }

  /// Asks the cache to get the value for the given key
  ///
  ///  - Parameter key: The key for the value
  ///
  /// - Returns: A `Publisher` that could either have been just created or it could have been reused from a pool of pending Publishers
  ///            if there is a Publisher for the same key going on at the moment.
  public func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    if let pooledRequest = lock.locked({ self.requestsPool[key] }) {
      Logger.log("Using pooled request \(pooledRequest) for key \(key)")
      return pooledRequest
    }

    let request = internalCache.get(key)

    lock.locked {
      self.requestsPool[key] = request
    }

    Logger.log("Creating a new request \(request) for key \(key)")

    return request
      .handleEvents(receiveCompletion: { [weak self] _ in
        self?.lock.locked {
          self?.requestsPool[key] = nil
        }
      })
      .eraseToAnyPublisher()
  }

  /// Sets a value for the given key on the managed cache
  ///
  /// - Parameter value: The value to set
  /// - Parameter key: The key for the value
  public func set(_ value: C.OutputType, forKey key: C.KeyType) -> AnyPublisher<Void, Error> {
    internalCache.set(value, forKey: key)
  }

  public func remove(_ key: C.KeyType) -> AnyPublisher<Void, Error> {
    internalCache.remove(key)
  }

  /// Clears the managed cache
  public func clear() {
    internalCache.clear()
  }

  /// Notifies the managed cache that a memory warning event was thrown
  public func onMemoryWarning() {
    internalCache.onMemoryWarning()
  }
}
