import Foundation

extension CacheLevel where Self: AnyObject {
  /**
  Adds a memory warning listener on the given cache
  
  - returns: The token that you should use later on to unsubscribe
  */
  public func listenToMemoryWarnings() -> NSObjectProtocol {
    return NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] _ in
      self?.onMemoryWarning()
    })
  }
}

/**
Removes the memory warning listener

- parameter token: The token you got from the call to listenToMemoryWarning: previously
*/
public func unsubscribeToMemoryWarnings(token: NSObjectProtocol) {
  NSNotificationCenter.defaultCenter().removeObserver(token, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
}
