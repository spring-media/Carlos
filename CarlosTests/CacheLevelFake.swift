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
  var didSetValue: NSData?
  var didSetKey: String?
  func set(value: NSData, forKey fetchable: FetchableType) {
    didSetValue = value
    didSetKey = fetchable.fetchableKey
  }
  
  var didGetWithKey: String?
  var valueToReturn: NSData?
  func get(fetchable: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    didGetWithKey = fetchable.fetchableKey
    
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