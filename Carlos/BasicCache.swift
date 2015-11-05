import Foundation

/// A wrapper cache that explicitly takes get, set, clear and memory warning closures
public final class BasicCache<A, B>: CacheLevel {
  public typealias KeyType = A
  public typealias OutputType = B
  
  private let getClosure: (key: A) -> Future<B>
  private let setClosure: (value: B, key: A) -> Void
  private let clearClosure: () -> Void
  private let memoryClosure: () -> Void
  
  /**
  Initializes a new instance of a BasicCache specifying closures for get, set, clear and onMemoryWarning, thus determining the behavior of the cache level as a whole
  
  - parameter getClosure: The closure to execute when you call get(key) on this instance
  - parameter setClosure: The closure to execute when you call set(value, key) on this instance
  - parameter clearClosure: The closure to execute when you call clear() on this instance
  - parameter memoryClosure: The closure to execute when you call onMemoryWarning() on this instance, or when a memory warning is thrown by the system and the cache level is listening for memory pressure events
  */
  public init(getClosure: (key: A) -> Future<B>, setClosure: (value: B, key: A) -> Void, clearClosure: () -> Void, memoryClosure: () -> Void) {
    self.getClosure = getClosure
    self.setClosure = setClosure
    self.clearClosure = clearClosure
    self.memoryClosure = memoryClosure
  }
  
  /**
  Asks the cache to get the value for a given key
  
  - parameter key: The key you want to get the value for
  
  - returns: The result of the getClosure specified when initializing the instance
  */
  public func get(key: KeyType) -> Future<OutputType> {
    return getClosure(key: key)
  }
  
  /**
  Asks the cache to set a value for the given key
  
  - parameter value: The value to set on the cache
  - parameter key: The key to use for the given value
  
  This call executes the setClosure specified when initializing the instance
  */
  public func set(value: B, forKey key: A) {
    setClosure(value: value, key: key)
  }
  
  /**
  Asks the cache to clear its contents
  
  This call executes the clearClosure specified when initializing the instance
  */
  public func clear() {
    clearClosure()
  }
  
  /**
  Tells the cache that a memory warning event was received
  
  This call executes the memoryClosure specified when initializing the instance
  */
  public func onMemoryWarning() {
    memoryClosure()
  }
}