import Foundation

extension CacheLevel where Self: AnyObject {
  /**
  Adds a memory warning listener on the given cache
  
  - returns: The token that you should use later on to unsubscribe
  */
  public func listenToMemoryWarnings() -> NSObjectProtocol {
    #if os(macOS)
        let source = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical])
        source.setEventHandler { [weak self] _ in
            self?.onMemoryWarning()
        }
        return source
    #else
        return NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: OperationQueue.main, using: { [weak self] _ in
            self?.onMemoryWarning()
        })
    #endif
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
    NotificationCenter.default.removeObserver(token, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
  #endif
  }
}
