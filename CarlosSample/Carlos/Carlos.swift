//
//  Cache.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

internal struct CarlosGlobals {
  static let QueueNamePrefix = "com.carlos."
  static let Caches = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
}

/// An abstraction for a generic cache level
public protocol CacheLevel {
  /**
  Tries to get a value from the cache level
  
  :param: key The key of the value you would like to get
  :param: success The closure to execute when the value is found
  :param: failure The closure to execute when no value is found for the given key on the cache level
  */
  func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void)
  
  /**
  Tries to set a value on the cache level
  
  :param: value The bytes to set on the cache level
  :param: key The key of the value you're trying to set
  */
  func set(value: NSData, forKey key: FetchableType)
  
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
  var key: String { get } //TODO: Rename this to "value"?
}

extension String: FetchableType {
  public var key: String {
    return self
  }
}

extension NSURL: FetchableType {
  public var key: String {
    return absoluteString!
  }
}
