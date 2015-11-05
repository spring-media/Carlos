import Foundation

internal struct CarlosGlobals {
  static let QueueNamePrefix = "com.carlos."
  static let Caches = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] 
}

internal func wrapClosureIntoCacheLevel<A, B>(closure: (key: A) -> Future<B>) -> BasicCache<A, B> {
  return BasicCache(
    getClosure: closure,
    setClosure: { (_, _) in },
    clearClosure: { },
    memoryClosure: { }
  )
}

internal func wrapClosureIntoFetcher<A, B>(closure: (key: A) -> Future<B>) -> BasicFetcher<A, B> {
  return BasicFetcher(getClosure: closure)
}

internal func wrapClosureIntoOneWayTransformer<A, B>(transformerClosure: A -> Future<B>) -> OneWayTransformationBox<A, B> {
  return OneWayTransformationBox(transform: transformerClosure)
}

infix operator =>> { associativity left }

/// An abstraction for an object that can perform an operation asynchronously
public protocol AsyncComputation {
  /// The input type of the computation
  typealias Input
  
  /// The output type of the computation
  typealias Output
  
  /**
  Performs the asynchronous computation
  
  - parameter input: The input for the computation
   
  - returns: A Future that will contain the result of the computation or an error
  */
  func perform(input: Input) -> Future<Output>
}

/// An abstraction for a generic cache level
public protocol CacheLevel: AsyncComputation {
  /// A typealias for the key the cache level accepts
  typealias KeyType
  
  /// A typealias for the data the cache returns in the success closure
  typealias OutputType
  
  /**
  Tries to get a value from the cache level
  
  - parameter key: The key of the value you would like to get
  
  - returns: a Future that you can attach success and failure closures to
  */
  func get(key: KeyType) -> Future<OutputType>
  
  /**
  Tries to set a value on the cache level
  
  - parameter value: The bytes to set on the cache level
  - parameter key: The key of the value you're trying to set
  */
  func set(value: OutputType, forKey key: KeyType)
  
  /**
  Asks to clear the cache level
  */
  func clear()
  
  /**
  Notifies the cache level that a memory warning was thrown, and asks it to do its best to clean some memory
  */
  func onMemoryWarning()
}

// Cache levels are AsyncComputation by default!
extension CacheLevel {
  /// The input type of the asynchronous computation for a CacheLevel is the key type
  public typealias Input = KeyType
  
  /// The output type of the asynchronous computation for a CacheLevel is the output type
  public typealias Output = OutputType

  /**
  Performs a get request
  
  - parameter input: The key for the get request
   
  - returns: a Future containing the result of the get request
  */
  public func perform(input: KeyType) -> Future<OutputType> {
    return get(input)
  }
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
  public func set(value: OutputType, forKey key: KeyType) {}
}