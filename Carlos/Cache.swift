//
//  Cache.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// The cache to use when interfacing with Carlos. Conforms to CacheLevel to provide all its meaningful methods, and has an internal list of cache levels that can be customized at initialization time.
public final class Cache: CacheLevel {
  //TODO: Consider having a pool of cache requests to avoid double-requesting the same resource
  //TODO: Make this class generic and add a transformation closure to convert from and to the generic type to NSData
  private let levels: [CacheLevel]
  private var memoryObserver: NSObjectProtocol!
  
  /**
  Initializes a new Carlos Cache
  
  :param: levels The cache levels to use. Defaults to memory and disk.
  */
  public init(levels: [CacheLevel] = [MemoryCacheLevel(), DiskCacheLevel()]) {
    self.levels = levels
    
    memoryObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] _ in
      if let strongSelf = self {
        strongSelf.onMemoryWarning()
      }
    })
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(memoryObserver, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
  }
  
  public func onMemoryWarning() {
    for cache in levels {
      cache.onMemoryWarning()
    }
  }
  
  public func get(fetchable: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    lookup(fetchable, levels: levels, success: success, failure: failure)
  }
  
  private func lookup(fetchable: FetchableType, levels: [CacheLevel], success: (NSData) -> Void, failure: (NSError?) -> Void) {
    if levels.isEmpty {
      failure(errorWithCode(FetchError.NoCacheLevelsSpecified.rawValue))
    } else {
      if let firstLevel = levels.first {
        firstLevel.get(fetchable, onSuccess: { data in
          success(data)
        }, onFailure: { error in
          self.lookup(fetchable, levels: Array(levels[1..<levels.count]), success: { data in
            firstLevel.set(data, forKey: fetchable)
            success(data)
          }, failure: failure)
        })
      }
    }
  }
  
  public func set(value: NSData, forKey fetchable: FetchableType) {
    for level in levels {
      level.set(value, forKey: fetchable)
    }
  }
  
  public func clear() {
    for level in levels {
      level.clear()
    }
  }
}