//
//  CacheLevelFake.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 06/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation
import Carlos

class CacheLevelFake: CacheLevel {
  typealias KeyType = String
  typealias OutputType = NSData

  var didSetValue: NSData?
  var didSetKey: String?
  func set(value: NSData, forKey fetchable: String) {
    didSetValue = value
    didSetKey = fetchable
  }
  
  var didGetWithKey: String?
  var valueToReturn: NSData?
  func get(fetchable: String, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    didGetWithKey = fetchable
    
    if let value = valueToReturn {
      success(value)
    } else {
      failure(NSError(domain: "Test", code: -1, userInfo: nil))
    }
  }
  
  var cleared = false
  func clear() {
    cleared = true
  }
  
  var receivedMemoryWarning = false
  func onMemoryWarning() {
    receivedMemoryWarning = true
  }
}