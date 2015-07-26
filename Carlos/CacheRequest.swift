import Foundation

/// This class wraps a cache request future
public class CacheRequest<T> {
  private var failureListeners: [(NSError?) -> Void] = []
  private var successListeners: [(T) -> Void] = []
  private var didSucceed = false
  private var didFail = false
  private var error: NSError?
  private var value: T?
  
  /// Creates a new CacheRequest
  public init() {}
  
  /**
  Initializes a new CacheRequest and makes it immediately succeed with the given value
  
  :param: value The success value of the request
  */
  public init(value: T) {
    succeed(value)
  }
  
  /**
  Initializes a new CacheRequest and makes it immediately fail with the given error
  
  :param: error The error of the request
  */
  public init(error: NSError?) {
    fail(error)
  }
  
  /**
  Makes the request succeed with a value
  
  :param: value The value found for the request
  
  :discussion: Calling this method makes all the listeners get the onSuccess callback
  */
  public func succeed(value: T) {
    didSucceed = true
    self.value = value
    
    for listener in successListeners {
      listener(value)
    }
  }
  
  /**
  Makes the request fail with an error
  
  :param: error The optional error that caused the request to fail
  
  :discussion: Calling this method makes all the listeners get the onFailure callback
  */
  public func fail(error: NSError?) {
    didFail = true
    self.error = error
    
    for listener in failureListeners {
      listener(error)
    }
  }
  
  /**
  Adds a listener for the success event of this request
  
  :param: success The closure that should be called when the request succeeds, taking the value as a parameter
  
  :returns: The updated request
  */
  public func onSuccess(success: (T) -> Void) -> CacheRequest<T> {
    if let value = value where didSucceed {
      success(value)
    } else {
      successListeners.append(success)
    }
    
    return self
  }
  
  /**
  Adds a listener for the failure event of this request
  
  :param: success The closure that should be called when the request fails, taking the error as a parameter
  
  :returns: The updated request
  */
  public func onFailure(failure: (NSError?) -> Void) -> CacheRequest<T> {
    if didFail {
      failure(error)
    } else {
      failureListeners.append(failure)
    }
    
    return self
  }
}
