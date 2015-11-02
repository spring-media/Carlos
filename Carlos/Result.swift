import Foundation

/// This class wraps a cache request future, where you can attach failure and success callbacks.
public class Promise<T> {
  private var failureListeners: [(ErrorType) -> Void] = []
  private var successListeners: [(T) -> Void] = []
  private var cancelListeners: [Void -> Void] = []
  private var error: ErrorType?
  private var value: T?
  private var canceled = false
  
  /**
  Creates a new Promise
  */
  public init() {
  }
  
  /**
  Initializes a new Promise and makes it immediately succeed with the given value
  
  - parameter value: The success value of the request
  */
  public convenience init(value: T) {
    self.init()
    
    succeed(value)
  }
  
  /**
  Initializes a new Promise and makes it immediately succeed or fail depending on the value
   
  - parameter value: The success value of the request, if not .None
  - parameter error: The error of the request, if value is .None
  */
  public convenience init(value: T?, error: ErrorType) {
    self.init()
    
    if let value = value {
      succeed(value)
    } else {
      fail(error)
    }
  }
  
  /**
  Initializes a new Promise and makes it immediately fail with the given error
  
  - parameter error: The error of the request
  */
  public convenience init(error: ErrorType) {
    self.init()
    
    fail(error)
  }
  
  /**
  Mimics the given Promise, so that it fails or succeeds when the stamps does so (in addition to its pre-existing behavior)
  Moreover, if the mimiced request is canceled, the request will also cancel itself
   
  - parameter stamp: The Promise to mimic
   
  - returns: The Promise itself
  */
  public func mimic(stamp: Promise<T>) -> Promise<T> {
    stamp
      .onSuccess(self.succeed)
      .onFailure(self.fail)
      .onCancel(self.cancel)
    
    return self
  }
  
  /**
  Makes the request succeed with a value
  
  - parameter value: The value found for the request
  
  Calling this method makes all the listeners get the onSuccess callback
  */
  public func succeed(value: T) {
    guard self.error == nil else { return }
    guard self.value == nil else { return }
    guard self.canceled == false else { return }
    
    self.value = value
    
    for listener in successListeners {
      listener(value)
    }
  }
  
  /**
  Makes the request fail with an error
  
  - parameter error: The optional error that caused the request to fail
  
  Calling this method makes all the listeners get the onFailure callback
  */
  public func fail(error: ErrorType) {
    guard self.error == nil else { return }
    guard self.value == nil else { return }
    guard self.canceled == false else { return }
    
    self.error = error
    
    for listener in failureListeners {
      listener(error)
    }
  }
  
  /**
  Cancels the request
  
  Calling this method makes all the listeners get the onCancel callback (but not the onFailure callback)
  */
  public func cancel() {
    guard self.error == nil else { return }
    guard self.value == nil else { return }
    guard self.canceled == false else { return }
    
    canceled = true
    
    for listener in cancelListeners {
      listener()
    }
  }
  
  /**
  Adds a listener for the cancel event of this request
   
  - parameter cancel: The closure that should be called when the request is canceled
   
  - returns: The updated request
  */
  public func onCancel(callback: Void -> Void) -> Promise<T> {
    if canceled {
      callback()
    } else {
      cancelListeners.append(callback)
    }
    
    return self
  }
  
  /**
  Adds a listener for the success event of this request
  
  - parameter success: The closure that should be called when the request succeeds, taking the value as a parameter
  
  - returns: The updated request
  */
  public func onSuccess(callback: (T) -> Void) -> Promise<T> {
    if let value = value {
      callback(value)
    } else {
      successListeners.append(callback)
    }
    
    return self
  }
  
  /**
  Adds a listener for the failure event of this request
  
  - parameter success: The closure that should be called when the request fails, taking the error as a parameter
  
  - returns: The updated request
  */
  public func onFailure(callback: (ErrorType) -> Void) -> Promise<T> {
    if let error = error {
      callback(error)
    } else {
      failureListeners.append(callback)
    }
    
    return self
  }
  
  /**
  Adds a listener for both success and failure events of this request
  
  - parameter completion: The closure that should be called when the request completes (succeeds or fails), taking both an optional value in case the request succeeded and an optional error in case the request failed as parameters. If the request is canceled, both values will be nil
  
  - returns: The updated request
  */
  public func onCompletion(completion: (value: T?, error: ErrorType?) -> Void) -> Promise<T> {
    if let error = error {
      completion(value: nil, error: error)
    } else if let value = value {
      completion(value: value, error: nil)
    } else if canceled {
      completion(value: nil, error: nil)
    } else {
      onSuccess { completion(value: $0, error: nil) }
      onFailure { completion(value: nil, error: $0) }
      onCancel { completion(value: nil, error: nil) }
    }
    
    return self
  }
}
