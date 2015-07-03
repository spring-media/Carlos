//
//  Cache.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

struct CarlosGlobals {
  static let QueueNamePrefix = "com.carlos."
  static let Megabyte: UInt64 = 1024*1024
  static let Caches = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
}

public protocol CacheLevel {
  func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void)
  func set(value: NSData, forKey key: FetchableType)
  func clear()
  func onMemoryWarning()
}

public protocol FetchableType {
  var key: String { get }
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
