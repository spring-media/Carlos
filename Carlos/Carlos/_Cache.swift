//
//  Cache.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

protocol CacheLevel {
  func set(data: NSData, key: String)
  func get(key: String, success: (NSData) -> (), failure: (NSError?) -> ())
  func clear()
}

class MemoryLevel : CacheLevel {
  var cache = NSCache() // NSCache is thread-safe

  init() {
    // TODO: Start observing low memory conditions
  }

  func get(key: String, success: (NSData) -> (), failure: (NSError?) -> ()) {
    if let result = self.cache.objectForKey(key) as? NSData {
      success(result)
    } else {
      failure(nil)
    }
  }

  func set(data: NSData, key: String) {
    self.cache.setObject(data, forKey: key)
  }

  func clear() {
    cache.removeAllObjects()
  }
}

class DiskLevel : CacheLevel {
  var capacity: UInt64

  init(capacity: UInt64 = 64_000_000) {
    self.capacity = capacity
  }

  func get(key: String, success: (NSData) -> (), failure: (NSError?) -> ()) {
  }

  func set(data: NSData, key: String) {
  }

  func clear() {
  }
}

//class NetworkLevel : CacheLevel {
//  func get(key: String, success: Succeeder, failure: Failer) {
//    failure()
//  }
//
//  func set(data: NSData, key: String) {
//  }
//
//  func clear() {
//  }
//}

class Cache : CacheLevel {
  var levels: [CacheLevel] = []

  init() {
    addLevel(MemoryLevel())
    addLevel(DiskLevel())
  }

  func addLevel(level: CacheLevel) {
    levels.append(level)
  }

  func get(key: K, success: (V) -> (), failure: (NSError?) -> ())  {
    lookup(key, levels: self.levels, success: success, failure: failure)
  }

  func set(data: V, key: K) {
    for level in levels {
      level.set(data, key: key)
    }
  }

  func clear() {
    for level in levels {
      level.clear()
    }
  }

  private func lookup(key: String, levels: [CacheLevel], success: (V) -> (), failure: (NSError?) -> ()) {
//    if let head = levels.removeAtIndex(0) where !levels.isEmpty? {
//      head.get(key,{succes()}, { lookup(...)
//    }
  }
}