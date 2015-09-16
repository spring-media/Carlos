import Foundation

/// This class wraps a cache request future, where you can attach failure and success callbacks.
public class CacheRequest<T> {
  private var failureListeners: [(ErrorType) -> Void] = []
  private var successListeners: [(T) -> Void] = []
  private var error: ErrorType?
  private var value: T?
  
  /// Creates a new CacheRequest
  public init() {}
  
  /**
  Initializes a new CacheRequest and makes it immediately succeed with the given value
  
  - parameter value: The success value of the request
  */
  public init(value: T) {
    succeed(value)
  }
  
  /**
  Initializes a new CacheRequest and makes it immediately fail with the given error
  
  - parameter error: The error of the request
  */
  public init(error: ErrorType) {
    fail(error)
  }
  
  /**
  Makes the request succeed with a value
  
  - parameter value: The value found for the request
  
  :discussion: Calling this method makes all the listeners get the onSuccess callback
  */
  public func succeed(value: T) {
    guard self.error == nil else { return }
    guard self.value == nil else { return }
    
    self.value = value
    
    for listener in successListeners {
      listener(value)
    }
  }
  
  /**
  Makes the request fail with an error
  
  - parameter error: The optional error that caused the request to fail
  
  :discussion: Calling this method makes all the listeners get the onFailure callback
  */
  public func fail(error: ErrorType) {
    guard self.error == nil else { return }
    guard self.value == nil else { return }
    
    self.error = error
    
    for listener in failureListeners {
      listener(error)
    }
  }
  
  /**
  Adds a listener for the success event of this request
  
  - parameter success: The closure that should be called when the request succeeds, taking the value as a parameter
  
  - returns: The updated request
  */
  public func onSuccess(success: (T) -> Void) -> CacheRequest<T> {
    if let value = value {
      success(value)
    } else {
      successListeners.append(success)
    }
    
    return self
  }
  
  /**
  Adds a listener for the failure event of this request
  
  - parameter success: The closure that should be called when the request fails, taking the error as a parameter
  
  - returns: The updated request
  */
  public func onFailure(failure: (ErrorType) -> Void) -> CacheRequest<T> {
    if let error = error {
      failure(error)
    } else {
      failureListeners.append(failure)
    }
    
    return self
  }
  
  /**
  Adds a listener for both success and failure events of this request
  
  - parameter completion: The closure that should be called when the request completes (succeeds or fails), taking both an optional value in case the request succeeded and an optional error in case the request failed as parameters
  
  - returns: The updated request
  */
  public func onCompletion(completion: (value: T?, error: (ErrorType)?) -> Void) -> CacheRequest<T> {
    if let error = error {
      completion(value: nil, error: error)
    } else if let value = value {
      completion(value: value, error: nil)
    } else {
      onSuccess { value in
        completion(value: value, error: nil)
      }
      
      onFailure { error in
        completion(value: nil, error: error)
      }
    }
    
    return self
  }
}