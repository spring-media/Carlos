import Foundation

extension CacheLevel where Self: AnyObject {
  /**
  Adds a memory warning listener on the given cache
  
  - returns: The token that you should use later on to unsubscribe
  */
  public func listenToMemoryWarnings() -> NSObjectProtocol {
    return NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: OperationQueue.main, using: { [weak self] _ in
      self?.onMemoryWarning()
    })
  }
}

/**
Removes the memory warning listener

- parameter token: The token you got from the call to listenToMemoryWarning: previously
*/
public func unsubscribeToMemoryWarnings(_ token: NSObjectProtocol) {
  NotificationCenter.default.removeObserver(token, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
}
