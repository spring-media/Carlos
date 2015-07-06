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
  public init(cost: Int = 50 * 1024 * 1024) {
    internalCache = NSCache()
    internalCache.totalCostLimit = cost
  }
  
  public func get(fetchable: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    if let result = internalCache.objectForKey(fetchable.fetchableKey) as? NSData {
      Logger.log("Fetched \(fetchable.fetchableKey) on memory level")
      success(result)
    } else {
      Logger.log("Failed fetching \(fetchable.fetchableKey) on the memory cache")
      failure(errorWithCode(FetchError.ValueNotInCache.rawValue))
    }
  }
  
  public func onMemoryWarning() {
    clear()
  }
  
  public func set(value: NSData, forKey fetchable: FetchableType) {
    internalCache.setObject(value, forKey: fetchable.fetchableKey)
  }
  
  public func clear() {
    internalCache.removeAllObjects()
  }
}