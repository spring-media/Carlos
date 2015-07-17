import Foundation

internal struct CarlosGlobals {
  static let QueueNamePrefix = "com.carlos."
  static let Caches = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
}

internal func wrapClosureIntoCacheLevel<A, B>(closure: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return BasicCache(getClosure: { key in
    return closure(key: key)
  }, setClosure: { (_, _) in }, clearClosure: { }, memoryClosure: { })
}

internal func wrapClosureIntoOneWayTransformer<A, B>(transformerClosure: A -> B) -> OneWayTransformationBox<A, B> {
  return OneWayTransformationBox(transform: transformerClosure)
}

infix operator =>> { associativity left }

/// An abstraction for a generic cache level
public protocol CacheLevel {
  /// A typealias for the key the cache level accepts
  typealias KeyType
  
  /// A typealias for the data the cache returns in the success closure
  typealias OutputType
  
  /**
  Tries to get a value from the cache level
  
  :param: key The key of the value you would like to get
  
  :returns: a CacheRequest that you can attach success and failure closures to
  */
  func get(key: KeyType) -> CacheRequest<OutputType>
  
  /**
  Tries to set a value on the cache level
  
  :param: value The bytes to set on the cache level
  :param: key The key of the value you're trying to set
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