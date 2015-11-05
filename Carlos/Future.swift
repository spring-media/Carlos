import Foundation

/// This class is a read-only Promise.
public class Future<T> {
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
   
   - parameter completion: The closure that should be called when the Future completes (succeeds or fails), taking both an optional value in case the Future succeeded and an optional error in case the Future failed as parameters. If the Future is canceled, both values will be nil
   
   - returns: The updated Future
   */
  public func onCompletion(completion: (value: T?, error: ErrorType?) -> Void) -> Future<T> {
    promise.onCompletion(completion)
    
    return self
  }
}