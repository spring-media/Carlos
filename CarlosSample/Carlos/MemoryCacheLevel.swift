//
//  MemoryCacheLevel.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

public class MemoryCacheLevel: CacheLevel {
  private let internalCache: NSCache
  
  public init() {
    internalCache = NSCache()
    internalCache.totalCostLimit = Int(50 * CarlosGlobals.Megabyte)
  }
  
  public func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    println("Fetching key: \(key.key) on memory fetcher")
    if let result = internalCache.objectForKey(key.key) as? NSData {
      println("Fetched \(result)")
      success(result)
    } else {
      println("Failed fetching \(key.key) in the memory cache")
      failure(nil)
    }
  }
  
  public func onMemoryWarning() {
    clear()
  }
  
  public func set(value: NSData, forKey key: FetchableType) {
    internalCache.setObject(value, forKey: key.key)
  }
  
  public func clear() {
    internalCache.removeAllObjects()
  }
}