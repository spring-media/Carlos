import Foundation

/**
Adds a memory warning listener on the given cache

:param: cache The cache that should listen to the memory warnings. Usually it's the top level cache result of the cache levels composition

:returns: The token that you should use later on to unsubscribe
*/
public func listenToMemoryWarnings<A: CacheLevel where A: AnyObject>(cache: A) -> NSObjectProtocol {
  return NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak cache] _ in
    if let cache = cache {
      cache.onMemoryWarning()
    }
  })
}

/**
Removes the memory warning listener

:param: token The token you got from the call to listenToMemoryWarning: previously
*/
public func unsubscribeToMemoryWarnings(token: NSObjectProtocol) {
  NSNotificationCenter.defaultCenter().removeObserver(token, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
}
