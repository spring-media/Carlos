import Foundation

/// Abstracts a Future computation so that it's easier to extend SequenceType
public protocol Async {
  /// The generic parameter in the Future implementation
  associatedtype Value

  /// Accessor to the Future instance
  var future: Future<Value> { get }
}

public enum FutureInitializationError: Error {
  case closureReturnedNil
}

/// This class is a read-only Promise.
open class Future<T>: Async {
  public typealias Value = T
  
  public var future: Future<T> {
    return self
  }
  
  private let promise: Promise<T>
  
  init(promise: Promise<T>) {
    self.promise = promise
  }
  
  /**
   Initializes a new Future and makes it immediately succeed with the given value
   
   - parameter value: The success value of the Future
   */
  public convenience init(_ value: T) {
    self.init(promise: Promise(value))
  }
  
  /**
   Initializes a new Future and makes it succeed (or fail) with the result of the given closure
   
   - parameter closure: The closure that will be evaluated on a background thread
   
   The initialized future will succeed if the result of the closure is .Some, and will fail with a FutureInitializationError.ClosureReturnedNil if it's .None. The future will report on the main queue
   */
  public convenience init(closure: @escaping (Void) -> T?) {
    let promise = Promise<T>()
    
    self.init(promise: promise)
    
    GCD.background {
      closure()
    }.main { result in
      if let result = result {
        promise.succeed(result)
      } else {
        promise.fail(FutureInitializationError.closureReturnedNil)
      }
    }
  }
  
  /**
   Initializes a new Future and makes it immediately succeed or fail depending on the value
   
   - parameter value: The success value of the Future, if not .None
   - parameter error: The error of the Future, if value is .None
   */
  public convenience init(value: T?, error: Error) {
    self.init(promise: Promise(value: value, error: error))
  }
  
  /**
   Initializes a new Future and makes it immediately fail with the given error
   
   - parameter error: The error of the Future
   */
  public convenience init(_ error: Error) {
    self.init(promise: Promise(error))
  }
  
  /**
   Cancels the Future
   
   Calling this method makes all the listeners get the onCancel callback (but not the onFailure callback)
   */
  public func cancel() {
    promise.cancel()
  }
  
  /**
   Adds a listener for the cancel event of this Future
   
   - parameter cancel: The closure that should be called when the Future is canceled
   
   - returns: The updated Future
   */
  @discardableResult
  public func onCancel(_ callback: @escaping (Void) -> Void) -> Future<T> {
    promise.onCancel(callback)
    
    return self
  }
  
  /**
   Adds a listener for the success event of this Future
   
   - parameter success: The closure that should be called when the Future succeeds, taking the value as a parameter
   
   - returns: The updated Future
   */
  @discardableResult
  public func onSuccess(_ callback: @escaping (T) -> Void) -> Future<T> {
    promise.onSuccess(callback)
    
    return self
  }
  
  /**
   Adds a listener for the failure event of this Future
   
   - parameter success: The closure that should be called when the Future fails, taking the error as a parameter
   
   - returns: The updated Future
   */
  @discardableResult
  public func onFailure(_ callback: @escaping (Error) -> Void) -> Future<T> {
    promise.onFailure(callback)
    
    return self
  }
  
  /**
   Adds a listener for both success and failure events of this Future
   
   - parameter completion: The closure that should be called when the Future completes (succeeds or fails), taking a Result<T> with value .Success in case the Future succeeded and .error in case the Future failed as parameter. If the Future is canceled, the result will be .Cancelled
   
   - returns: The updated Future
   */
  @discardableResult
  public func onCompletion(_ completion: @escaping (Result<T>) -> Void) -> Future<T> {
    promise.onCompletion(completion)
    
    return self
  }
}
