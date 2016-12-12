import Foundation
import PiedPiper

/// A wrapper cache that explicitly takes get, set, clear and memory warning closures
public final class BasicCache<A, B>: CacheLevel {
  public typealias KeyType = A
  public typealias OutputType = B
  
  private let getClosure: (_ key: A) -> Future<B>
  private let setClosure: (_ value: B, _ key: A) -> Future<()>
  private let clearClosure: () -> Void
  private let memoryClosure: () -> Void
  
  /**
  Initializes a new instance of a BasicCache specifying closures for get, set, clear and onMemoryWarning, thus determining the behavior of the cache level as a whole
  
  - parameter getClosure: The closure to execute when you call get(key) on this instance
  - parameter setClosure: The closure to execute when you call set(value, key) on this instance
  - parameter clearClosure: The closure to execute when you call clear() on this instance
  - parameter memoryClosure: The closure to execute when you call onMemoryWarning() on this instance, or when a memory warning is thrown by the system and the cache level is listening for memory pressure events
  */
  public init(getClosure: @escaping (_ key: A) -> Future<B>, setClosure: @escaping (_ value: B, _ key: A) -> Future<()>, clearClosure: @escaping () -> Void, memoryClosure: @escaping () -> Void) {
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
  public func get(_ key: KeyType) -> Future<OutputType> {
    return getClosure(key)
  }
  
  /**
  Asks the cache to set a value for the given key
  
  - parameter value: The value to set on the cache
  - parameter key: The key to use for the given value
  
  This call executes the setClosure specified when initializing the instance
  */
  public func set(_ value: B, forKey key: A) -> Future<()> {
    return setClosure(value, key)
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
