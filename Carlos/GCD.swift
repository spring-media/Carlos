import Foundation

/// Internal struct for easy GCD usage
internal struct GCD {
  /// The main queue
  static let main = dispatch_get_main_queue()
  
  /// The background queue, default priority
  static let background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
  
  /// Returns a new serial queue with the given name
  static func serial(name: String) -> dispatch_queue_t {
    return dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL)
  }
}

infix operator <~ { }

/**
Dispatches a given closure on a given queue asynchronously
 
- parameter lhs: The queue you want to use for the given closure
- parameter rhs: The closure you want to dispatch on the queue
*/
internal func <~(lhs: dispatch_queue_t, rhs: Void -> Void) {
  dispatch_async(lhs, rhs)
}