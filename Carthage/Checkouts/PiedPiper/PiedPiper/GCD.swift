import Foundation

/// Internal struct for easy GCD usage
public struct GCD: GCDQueue {
  fileprivate static let mainQueue = GCD(queue: DispatchQueue.main)
  fileprivate static let backgroundQueue = GCD(queue: DispatchQueue.global(qos: .default))
  
  /**
  Asynchronously dispatches a closure on the main queue
   
  - parameter closure: The closure you want to dispatch on the queue
   
  - returns: The result of the execution of the closure
  */
  @discardableResult
  public static func main<T>(_ closure: @escaping ((Void) -> T)) -> AsyncDispatch<T> {
    return mainQueue.async(closure)
  }
  
  /**
   Asynchronously dispatches a closure on the default priority background queue
   
  - parameter closure: The closure you want to dispatch on the queue
   
  - returns: The result of the execution of the closure
  */
  @discardableResult
  static public func background<T>(_ closure: @escaping ((Void) -> T)) -> AsyncDispatch<T> {
    return backgroundQueue.async(closure)
  }
  
  /**
  Creates a new serial queue with the given name
   
  - parameter name: The name for the new queue
   
  - returns: The newly created GCDQueue
  */
  public static func serial(_ name: String) -> GCDQueue {
    return GCD(queue: DispatchQueue(label: name))
  }
  
  static func delay(_ time: TimeInterval) -> Future<()> {
    return delay(time) { () }
  }
  
  @discardableResult
  static func delay<T>(_ time: TimeInterval, closure: @escaping (Void) -> T) -> Future<T> {
    let result = Promise<T>()
    
    let time = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time, execute: {
      result.succeed(closure())
    })
    
    return result.future
  }
  
  /**
  Instantiates a new GCD value with a custom dispatch queue
   
  - parameter queue: The custom dispatch queue you want to use with this GCD value
  */
  public init(queue: DispatchQueue) {
    self.queue = queue
  }
  
  /// The GCD queue associated to this GCD value
  public let queue: DispatchQueue
}

/// An async dispatch operation
open class AsyncDispatch<T> {
  /// The inner async operation
  private(set) open var future: Future<T>
  
  init(operation: Future<T>) {
    self.future = operation
  }
  
  private func dispatchClosureAsync<O>(_ closure: @escaping (T) -> O, queue: GCDQueue) -> AsyncDispatch<O> {
    let innerResult = Promise<O>()
    let result = AsyncDispatch<O>(operation: innerResult.future)
    
    future.onSuccess { value in
      queue.async {
        innerResult.succeed(closure(value))
      }
    }
    
    return result
  }
  
  /**
  Chains a closure taking a T input and returning an O output on the main queue 
  
  - parameter closure: The closure you want to dispatch on the main queue
   
  - returns: An AsyncDispatch object. You can keep chaining async calls on this object
  */
  @discardableResult
  public func main<O>(_ closure: @escaping (T) -> O) -> AsyncDispatch<O> {
    return dispatchClosureAsync(closure, queue: GCD.mainQueue)
  }
  
  /**
  Chains a closure taking a T input and returning an O output on a background queue
   
  - parameter closure: The closure you want to dispatch on the background queue
   
  - returns: An AsyncDispatch object. You can keep chaining async calls on this object
  */
  @discardableResult
  public func background<O>(_ closure: @escaping (T) -> O) -> AsyncDispatch<O> {
    return dispatchClosureAsync(closure, queue: GCD.backgroundQueue)
  }
}

/// Abstracts a GCD queue
public protocol GCDQueue {
  /// The underlying dispatch_queue_t
  var queue: DispatchQueue { get }
}

extension GCDQueue {
  
  /**
  Dispatches a given closure on the queue asynchronously
   
  - parameter closure: The closure you want to dispatch on the queue
   
  - returns: An AsyncDispatch object. You can keep chaining async calls on this object
  */
  @discardableResult
  public func async<T>(_ closure: @escaping (Void) -> T) -> AsyncDispatch<T> {
    let innerResult = Promise<T>()
    let result = AsyncDispatch<T>(operation: innerResult.future)
    
    queue.async {
      innerResult.succeed(closure())
    }
    
    return result
  }
}
