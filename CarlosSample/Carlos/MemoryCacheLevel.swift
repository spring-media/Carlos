//
//  MemoryCacheLevel.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// This class is a memory cache level. It internally uses NSCache, and has a configurable total cost limit that defaults to 50 MB.
public final class MemoryCacheLevel: CacheLevel {
  private let internalCache: NSCache
  
  /**
  Initializes a new memory cache level

  :param: cost The total cost limit for the memory cache. Defaults to 50 MB
  */
  public init(cost: Int = Int(50 * 1024 * 1024)) {
    internalCache = NSCache()
    internalCache.totalCostLimit = cost
  }
  
  public func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    //TODO: Use a logger here
    println("Fetching key: \(key.key) on memory fetcher")
    
    if let result = internalCache.objectForKey(key.key) as? NSData {
      //TODO: Use a logger here
      println("Fetched \(key.key)")
      success(result)
    } else {
      //TODO: Use a logger here
      println("Failed fetching \(key.key) in the memory cache")
      //TODO: Pass an error here
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