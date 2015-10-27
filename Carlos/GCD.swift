import Foundation

/// Internal struct for easy GCD usage
internal struct GCD: GCDQueue {
  
  /**
  Asynchronously dispatches a closure on the main queue
   
  - parameter closure: The closure you want to dispatch on the queue
   
  - returns: The result of the execution of the closure
  */
  static func main(closure: (Void -> Void)) {
    mainQueue.async(closure)
  }
  
  /**
   Asynchronously dispatches a closure on the default priority background queue
   
  - parameter closure: The closure you want to dispatch on the queue
   
  - returns: The result of the execution of the closure
  */
  static func background(closure: (Void -> Void)) {
    backgroundQueue.async(closure)
  }
  
  private static let mainQueue = GCD(queue: dispatch_get_main_queue())
  private static let backgroundQueue = GCD(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
  
  /**
  Creates a new serial queue with the given name
   
  - parameter name: The name for the new queue
   
  - returns: The newly created GCDQueue
  */
  static func serial(name: String) -> GCDQueue {
    return GCD(queue: dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL))
  }
  
  let queue: dispatch_queue_t
}

/// Abstracts a GCD queue
internal protocol GCDQueue {
  /// The underlying dispatch_queue_t
  var queue: dispatch_queue_t { get }
}

internal enum GCDError: ErrorType {
  case AsyncReturnedNil
}

extension GCDQueue {
  
  /**
  Dispatches a given closure on the queue asynchronously
   
  - parameter closure: The closure you want to dispatch on the queue
  */
  internal func async(closure: Void -> Void) {
    dispatch_async(queue, closure)
  }
}