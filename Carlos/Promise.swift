import Foundation

/// This class is a Future computation, where you can attach failure and success callbacks.
public class Promise<T> {
  private var failureListeners: [(ErrorType) -> Void] = []
  private var successListeners: [(T) -> Void] = []
  private var cancelListeners: [Void -> Void] = []
  private var error: ErrorType?
  private var value: T?
  private var canceled = false
  
  /// The Future associated to this Promise
  public lazy var future: Future<T> = {
    return Future(promise: self)
  }()
  
  /**
  Creates a new Promise
  */
  public init() {
  }
  
  /**
  Initializes a new Promise and makes it immediately succeed with the given value
  
  - parameter value: The success value of the Promise
  */
  public convenience init(value: T) {
    self.init()
    
    succeed(value)
  }
  
  /**
  Initializes a new Promise and makes it immediately succeed or fail depending on the value
   
  - parameter value: The success value of the Promise, if not .None
  - parameter error: The error of the Promise, if value is .None
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
  
  - parameter error: The error of the Promise
  */
  public convenience init(error: ErrorType) {
    self.init()
    
    fail(error)
  }
  
  /**
  Mimics the given Future, so that it fails or succeeds when the stamps does so (in addition to its pre-existing behavior)
  Moreover, if the mimiced Future is canceled, the Promise will also cancel itself
   
  - parameter stamp: The Future to mimic
   
  - returns: The Promise itself
  */
  public func mimic(stamp: Future<T>) -> Promise<T> {
    stamp
      .onSuccess(self.succeed)
      .onFailure(self.fail)
      .onCancel(self.cancel)
    
    return self
  }
  
  /**
  Makes the Promise succeed with a value
  
  - parameter value: The value found for the Promise
  
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
  Makes the Promise fail with an error
  
  - parameter error: The optional error that caused the Promise to fail
  
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
  Cancels the Promise
  
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
  Adds a listener for the cancel event of this Promise
   
  - parameter cancel: The closure that should be called when the Promise is canceled
   
  - returns: The updated Promise
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
  Adds a listener for the success event of this Promise
  
  - parameter success: The closure that should be called when the Promise succeeds, taking the value as a parameter
  
  - returns: The updated Promise
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
  Adds a listener for the failure event of this Promise
  
  - parameter success: The closure that should be called when the Promise fails, taking the error as a parameter
  
  - returns: The updated Promise
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
  Adds a listener for both success and failure events of this Promise
  
  - parameter completion: The closure that should be called when the Promise completes (succeeds or fails), taking both an optional value in case the Promise succeeded and an optional error in case the Promise failed as parameters. If the Promise is canceled, both values will be nil
  
  - returns: The updated Promise
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
