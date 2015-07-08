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
  func get(fetchable: KeyType) -> CacheRequest<OutputType> {
    let request = CacheRequest<OutputType>()
    didGetWithKey = fetchable
    
    if let value = valueToReturn {
      request.succeed(value)
    } else {
      request.fail(NSError(domain: "Test", code: -1, userInfo: nil))
    }
    
    return request
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