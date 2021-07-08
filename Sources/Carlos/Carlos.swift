import Combine
import Foundation

public struct CarlosGlobals {
  public static let queueNamePrefix = "com.carlos."
  public static let caches = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
}

/// An abstraction for a generic cache level
public protocol CacheLevel: AnyObject {
  /// A typealias for the key the cache level accepts
  associatedtype KeyType

  /// A typealias for the data the cache returns in the success closure
  associatedtype OutputType

  /// Tries to get a value from the cache level
  ///
  /// - Parameter key: The key of the value you would like to get
  ///
  /// - Returns: A `Publisher` that you can attach success and failure closures to
  func get(_ key: KeyType) -> AnyPublisher<OutputType, Error>

  /// Tries to set a value on the cache level
  ///
  /// - Parameter value: The bytes to set on the cache level
  /// - Parameter key: The key of the value you're trying to set
  ///
  /// - Returns: A `Publisher` that will reflect the status of the set operation
  func set(_ value: OutputType, forKey key: KeyType) -> AnyPublisher<Void, Error>

  /// Remove value from cache for a given key.
  ///
  /// - Parameter key: They key of the value to be removed
  ///
  /// - Returns: A `Publisher` that reflects a status of the remove operation.
  func remove(_ key: KeyType) -> AnyPublisher<Void, Error>

  /// Asks to clear the cache level
  func clear()

  /// Notifies the cache level that a memory warning was thrown, and asks it to do its best to clean some memory
  func onMemoryWarning()
}
