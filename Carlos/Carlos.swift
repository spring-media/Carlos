//
//  Cache.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// The error domain used for Carlos errors
public let CarlosErrorDomain = "CarlosErrorDomain"

public enum FetchError: Int {
  /// Used when a cache level doesn't have a value in the cache
  case ValueNotInCache = 10100
  
  /// Used when no cache level was specified during initialization
  case NoCacheLevelsSpecified = 9900
  
  /// Used when the specified fetchable was invalid
  case InvalidFetchable = 8900
}

internal func errorWithCode(code: Int) -> NSError {
  return NSError(domain: CarlosErrorDomain, code: code, userInfo: nil)
}

internal struct CarlosGlobals {
  static let QueueNamePrefix = "com.carlos."
  static let Caches = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
}

/// Abstracts a memory watchdog on which you can subscribe to memory warning notifications and unsubscribe later on
public protocol MemoryWatchdog {
  /**
  Starts listening to memory warning notifications on this memory watchdog
  
  :param: _ The closure to execute when a memory warning comes
  
  :returns: A token that you can use to unsubscribe from memory warning notifications
  */
  func listenToMemoryWarning(() -> Void) -> NSObjectProtocol
  
  /**
  Stops listening to memory warning notifications on this memory watchdog
  
  :param: token The token that was first returned by the watchdog after a call to listenToMemoryWarning:
  */
  func unsubscribeToMemoryWarning(token: NSObjectProtocol)
}

extension NSNotificationCenter: MemoryWatchdog {
  public func listenToMemoryWarning(notify: () -> Void) -> NSObjectProtocol {
    return addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { _ in
      notify()
    })
  }
  
  public func unsubscribeToMemoryWarning(token: NSObjectProtocol) {
    removeObserver(token, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
  }
}

/// An abstraction for a generic cache level
public protocol CacheLevel {
  /**
  Tries to get a value from the cache level
  
  :param: fetchable The key of the value you would like to get
  :param: success The closure to execute when the value is found
  :param: failure The closure to execute when no value is found for the given key on the cache level
  */
  func get(fetchable: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void)
  
  /**
  Tries to set a value on the cache level
  
  :param: value The bytes to set on the cache level
  :param: fetchable The key of the value you're trying to set
  */
  func set(value: NSData, forKey fetchable: FetchableType)
  
  /**
  Asks to clear the cache level
  */
  func clear()
  
  /**
  Notifies the cache level that a memory warning was thrown, and asks it to do its best to clean some memory
  */
  func onMemoryWarning()
}

/// An abstraction for a generic key that can be used for cache levels
public protocol FetchableType {
  /// The underlying key to use for the cache
  var fetchableKey: String { get }
}

extension String: FetchableType {
  public var fetchableKey: String {
    return self
  }
}

extension NSURL: FetchableType {
  public var fetchableKey: String {
    return absoluteString!
  }
}
