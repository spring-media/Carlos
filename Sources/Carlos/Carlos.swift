import Foundation
import OpenCombine

public struct CarlosGlobals {
  public static let QueueNamePrefix = "com.carlos."
  public static let Caches = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] 
}

internal func wrapClosureIntoFetcher<A, B>(_ closure: @escaping (_ key: A) -> AnyPublisher<B, Error>) -> BasicFetcher<A, B> {
  return BasicFetcher(getClosure: closure)
}

internal func wrapClosureIntoOneWayTransformer<A, B>(_ transformerClosure: @escaping (A) -> AnyPublisher<B, Error>) -> OneWayTransformationBox<A, B> {
  return OneWayTransformationBox(transform: transformerClosure)
}

/// An abstraction for a generic cache level
public protocol CacheLevel: class {
  /// A typealias for the key the cache level accepts
  associatedtype KeyType
  
  /// A typealias for the data the cache returns in the success closure
  associatedtype OutputType
  
  /**
  Tries to get a value from the cache level
  
  - parameter key: The key of the value you would like to get
  
  - returns: a Future that you can attach success and failure closures to
  */
  func get(_ key: KeyType) -> AnyPublisher<OutputType, Error>
  
  /**
  Tries to set a value on the cache level
  
  - parameter value: The bytes to set on the cache level
  - parameter key: The key of the value you're trying to set
   
  - returns: A Future that will reflect the status of the set operation
  */
  @discardableResult func set(_ value: OutputType, forKey key: KeyType) -> AnyPublisher<Void, Error>
  
  /**
  Asks to clear the cache level
  */
  func clear()
  
  /**
  Notifies the cache level that a memory warning was thrown, and asks it to do its best to clean some memory
  */
  func onMemoryWarning()
}

/// An abstraction for a generic cache level that can only fetch values but not store them
public protocol Fetcher: CacheLevel {}

/// Extending the Fetcher protocol to have a default no-op implementation for clear, onMemoryWarning and set
extension Fetcher {
  /// No-op
  public func clear() {}
  
  /// No-op
  public func onMemoryWarning() {}
  
  /// No-op
  public func set(_ value: OutputType, forKey key: KeyType) -> AnyPublisher<Void, Error> {
    return Just(())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
  }
}
