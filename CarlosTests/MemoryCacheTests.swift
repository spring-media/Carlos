//
//  MemoryCacheTests.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 06/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import UIKit
import XCTest
import Carlos

class MemoryCacheTests: XCTestCase {
  var sut: MemoryCacheLevel<NSData>!
  
  let size = 100
  let keys = ["key1", "key2", "key3", "key4"]
  let values = [
    "this is a short value that should not exceed the cache limits",
    "this is also a short value that should not exceed the cache limits",
    "this, maybe, can also stay there, depending on the implementation details of the cache",
    "at some point, though, the cache size will go over the limit and one of these value should be evicted, hopefully"
  ]
  
  override func setUp() {
    super.setUp()
    
    sut = MemoryCacheLevel(capacity: size)
  }
  
  func testShouldNotGoOverTheLimit() {
    for (key, value) in zip(keys, values) {
      sut.set(value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: key)
    }
    
    var atLeastOneIsNotThereAnymore = false
    for key in keys {
      sut.get(key, onSuccess: { _ in }, onFailure: { _ in
        atLeastOneIsNotThereAnymore = true
      })
    }
    
    XCTAssertTrue(atLeastOneIsNotThereAnymore, "At least one value should have been removed from the memory cache")
  }
  
  func testShouldFailIfValueIsNeverSet() {
    sut.get("never set this key", onSuccess: { _ in
      XCTFail("Should not get here")
    }, onFailure: { error in
      XCTAssertEqual(error!.code, FetchError.ValueNotInCache.rawValue, "Should use the right error")
    })
  }
  
  func testOnMemoryWarning() {
    for (key, value) in zip(keys, values) {
      sut.set(value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: key)
    }
    
    sut.onMemoryWarning()
    
    var atLeastOneIsStillThere = false
    for key in keys {
      sut.get(key, onSuccess: { _ in
        atLeastOneIsStillThere = true
      }, onFailure: { _ in
      })
    }
    
    XCTAssertFalse(atLeastOneIsStillThere, "No value should be there anymore")
  }
  
  func testClear() {
    for (key, value) in zip(keys, values) {
      sut.set(value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: key)
    }
    
    sut.clear()
    
    var atLeastOneIsStillThere = false
    for key in keys {
      sut.get(key, onSuccess: { _ in
        atLeastOneIsStillThere = true
        }, onFailure: { _ in
      })
    }
    
    XCTAssertFalse(atLeastOneIsStillThere, "No value should be there anymore")
  }
  
  func testShouldGetValuesIfSet() {
    let keyToUse = "simple key"
    let expectedData = "simple value".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    sut.set(expectedData, forKey: keyToUse)
    
    sut.get(keyToUse, onSuccess: { data in
      XCTAssertEqual(data, expectedData, "The fetched data should be the same that was set")
    }, onFailure: { _ in
      XCTFail("Should not get here")
    })
  }
  
  func testShouldOverwriteValuesIfSameKeyIsSet() {
    let keyToUse = "simple key"
    let expectedData = "simple value".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    
    sut.set("unexpected data".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: keyToUse)
    sut.set(expectedData, forKey: keyToUse)
    
    sut.get(keyToUse, onSuccess: { data in
      XCTAssertEqual(data, expectedData, "The fetched data should be the same that was set")
      }, onFailure: { _ in
        XCTFail("Should not get here")
    })
  }
}
