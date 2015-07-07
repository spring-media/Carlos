//
//  MemoryCacheLevel.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

public protocol ExpensiveObject {
  var cost: Int { get }
}

extension NSData: ExpensiveObject {
  public var cost: Int {
    return self.length
  }
}

extension String: ExpensiveObject {
  public var cost: Int {
    return count(self)
  }
}

/// This class is a memory cache level. It internally uses NSCache, and has a configurable total cost limit that defaults to 50 MB.
public final class MemoryCacheLevel<T: AnyObject where T: ExpensiveObject>: CacheLevel {
  public typealias KeyType = String
  public typealias OutputType = T
  
  private let internalCache: NSCache
  
  /**
  Initializes a new memory cache level

  :param: cost The total cost limit for the memory cache. Defaults to 50 MB
  */
  public init(capacity: Int = 50 * 1024 * 1024) {
    internalCache = NSCache()
    internalCache.totalCostLimit = capacity
  }
  
  public func get(fetchable: String, onSuccess success: (T) -> Void, onFailure failure: (NSError?) -> Void) {
    if let result = internalCache.objectForKey(fetchable) as? T {
      Logger.log("Fetched \(fetchable) on memory level")
      success(result)
    } else {
      Logger.log("Failed fetching \(fetchable) on the memory cache")
      failure(errorWithCode(FetchError.ValueNotInCache.rawValue))
    }
  }
  
  public func onMemoryWarning() {
    clear()
  }
  
  public func set(value: T, forKey fetchable: String) {
    internalCache.setObject(value, forKey: fetchable, cost: value.cost)
  }
  
  public func clear() {
    internalCache.removeAllObjects()
  }
}