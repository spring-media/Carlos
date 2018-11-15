import Foundation

extension CacheLevel where Self: AnyObject {
  /**
  Adds a memory warning listener on the given cache
  
  - returns: The token that you should use later on to unsubscribe
  */
  public func listenToMemoryWarnings() -> NSObjectProtocol {
    #if os(macOS)
        let source = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical])
        let workItem = DispatchWorkItem(block:{ [weak self] in
          self?.onMemoryWarning()
        })
        source.setEventHandler(handler: workItem)
        return source
    #else
    return NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: OperationQueue.main, using: { [weak self] _ in
            self?.onMemoryWarning()
        })
    #endif
  }
}

/**
 Removes the memory warning listener
 
 - parameter token: The token you got from the call to listenToMemoryWarning: previously
 */
public func unsubscribeToMemoryWarnings(_ token: NSObjectProtocol) {
    #if os(macOS)
        if let source = token as? DispatchSource {
            source.cancel()
        }
    #else
  NotificationCenter.default.removeObserver(token, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    #endif
}
