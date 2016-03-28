import Foundation

/// Abstracts a Future computation so that it's easier to extend SequenceType
public protocol Async {
  /// The generic parameter in the Future implementation
  associatedtype Value

  /// Accessor to the Future instance
  var future: Future<Value> { get }
}

/// This class is a read-only Promise.
public class Future<T>: Async {
  public typealias Value = T
  
  public var future: Future<T> {
    return self
  }
  
  private let promise: Promise<T>
  
  public init(promise: Promise<T>) {
    self.promise = promise
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
  public func onCancel(callback: Void -> Void) -> Future<T> {
    promise.onCancel(callback)
    
    return self
  }
  
  /**
   Adds a listener for the success event of this Future
   
   - parameter success: The closure that should be called when the Future succeeds, taking the value as a parameter
   
   - returns: The updated Future
   */
  public func onSuccess(callback: (T) -> Void) -> Future<T> {
    promise.onSuccess(callback)
    
    return self
  }
  
  /**
   Adds a listener for the failure event of this Future
   
   - parameter success: The closure that should be called when the Future fails, taking the error as a parameter
   
   - returns: The updated Future
   */
  public func onFailure(callback: (ErrorType) -> Void) -> Future<T> {
    promise.onFailure(callback)
    
    return self
  }
  
  /**
   Adds a listener for both success and failure events of this Future
   
   - parameter completion: The closure that should be called when the Future completes (succeeds or fails), taking a Result<T> with value .Success in case the Future succeeded and .Error in case the Future failed as parameter. If the Future is canceled, the result will be .Cancelled
   
   - returns: The updated Future
   */
  public func onCompletion(completion: (result: Result<T>) -> Void) -> Future<T> {
    promise.onCompletion(completion)
    
    return self
  }
}