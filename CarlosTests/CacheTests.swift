//
//  CacheTests.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 06/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import UIKit
import XCTest
import Carlos

class CacheTests: XCTestCase {
  var sut: Cache!
  var notificationCenter: NSNotificationCenterFake!
  var levels: [CacheLevel] = []
  
  override func setUp() {
    super.setUp()
    
    notificationCenter = NSNotificationCenterFake()
    levels = [
      CacheLevelFake(),
      CacheLevelFake()
    ]
    
    sut = Cache(levels: levels, notificationCenter: notificationCenter)
  }
  
  func testSubscribesToMemoryWarningNotification() {
    XCTAssertNotNil(notificationCenter.subscribedToNotificationWithName, "Cache should subscribe to some notification")
    
    if let notificationName = notificationCenter.subscribedToNotificationWithName {
      XCTAssertEqual(notificationName, UIApplicationDidReceiveMemoryWarningNotification, "Cache should subscribe to memory warning notifications")
    }
  }
  
  func testNotifiesLevelsWhenMemoryWarning() {
    notificationCenter.simulateNotification()
    
    for level in levels {
      XCTAssertTrue((level as! CacheLevelFake).receivedMemoryWarning, "Every cache level should be notified of the memory warning")
    }
  }
  
  func testNotifiesLevelsWhenClearing() {
    sut.clear()
    
    for level in levels {
      XCTAssertTrue((level as! CacheLevelFake).cleared, "Every cache level should be cleared")
    }
  }
  
  func testSetsOnAllLevels() {
    let data = "test".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    let key = "testKey"
    
    sut.set(data, forKey: key)
    
    for level in levels {
      XCTAssertNotNil((level as! CacheLevelFake).didSetValue, "Cache should set the value on every cache level")
      XCTAssertNotNil((level as! CacheLevelFake).didSetKey, "Cache should set the key on every cache level")
      
      if let dataSet = (level as? CacheLevelFake)?.didSetValue {
        XCTAssertEqual(dataSet, data, "Cache should set the right value on every cache level")
      }
      
      if let keySet = (level as? CacheLevelFake)?.didSetKey {
        XCTAssertEqual(keySet, key, "Cache should set the right key on every cache level")
      }
    }
  }
  
  func testGetStopsAtFirstLevelIfSucceeds() {
    let key = "testKey"
    
    let firstLevel = levels.first as! CacheLevelFake
    firstLevel.valueToReturn = "testResult".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
    sut.get(key, onSuccess: { data in
    }, onFailure: { error in
      XCTFail("Should not get here")
    })
    
    XCTAssertNotNil(firstLevel.didGetWithKey, "Should ask the first level of course")
    XCTAssertNil((levels.last as! CacheLevelFake).didGetWithKey, "Should not ask the second level")
    
    if let keyUsed = firstLevel.didGetWithKey {
      XCTAssertEqual(keyUsed, key, "Should use the right key")
    }
  }
  
  func testGetFailsWhenNoLevelsAreSpecified() {
    let cache = Cache(levels: [], notificationCenter: notificationCenter)
    
    cache.get("testKey", onSuccess: { data in
      XCTFail("Should not get here")
    }, onFailure: { error in
      XCTAssertEqual(error!.code, FetchError.NoCacheLevelsRemaining.rawValue, "Should use the right error")
    })
  }
  
  func testGetPassesTheCachedDataWhenOnFirstLevel() {
    let expectedValue = "testResultToReturn"
    let firstLevel = levels.first as! CacheLevelFake
    firstLevel.valueToReturn = expectedValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
    sut.get("testKey", onSuccess: { data in
      XCTAssertEqual(NSString(data: data, encoding: NSUTF8StringEncoding)!, expectedValue, "The retrieved data should be the same as returned by the cache level")
    }, onFailure: { error in
      XCTFail("Should not get here")
    })
  }
  
  func testGetStopsAtLastLevelThenFails() {
    let key = "testKey"
    
    sut.get(key, onSuccess: { data in
      XCTFail("Should not get here")
    }, onFailure: { error in
      XCTAssertEqual(error!.code, FetchError.NoCacheLevelsRemaining.rawValue, "Should use the right error")
    })
    
    for level in levels {
      XCTAssertNotNil((level as! CacheLevelFake).didGetWithKey, "Should ask every level before failing")
    }
  }
  
  func testGetSetsOnUpperLevelsWhenValueIsFound() {
    let expectedValue = "testResultToReturn"
    let key = "testKey"
    
    let firstLevel = levels.first as! CacheLevelFake
    let secondLevel = levels.last as! CacheLevelFake
    
    firstLevel.valueToReturn = nil
    secondLevel.valueToReturn = expectedValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
    sut.get(key, onSuccess: { data in
    }, onFailure: { error in
      XCTFail("Should not get here")
    })
    
    XCTAssertNotNil(firstLevel.didGetWithKey, "Should ask the first level first")
    XCTAssertNotNil(secondLevel.didGetWithKey, "Should ask the second level then")
    XCTAssertNotNil(firstLevel.didSetKey, "Should then set the key on the first level")
    XCTAssertNil(secondLevel.didSetKey, "Should not set the key on the second level too, though")
    
    if let keySet = firstLevel.didSetKey {
      XCTAssertEqual(keySet, key, "Should set the right key on the first level")
    }
    
    if let value = firstLevel.didSetValue {
      XCTAssertEqual(value, expectedValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, "Should set the right value on the first level")
    }
  }
  
  func testGetPassesTheCachedDataWhenLowerLevelSucceeds() {
    let expectedValue = "testResultToReturn"
    let key = "testKey"
    
    let firstLevel = levels.first as! CacheLevelFake
    let secondLevel = levels.last as! CacheLevelFake
    
    firstLevel.valueToReturn = nil
    secondLevel.valueToReturn = expectedValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    
    sut.get(key, onSuccess: { data in
      XCTAssertEqual(data, expectedValue.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, "Should still pass the right data after a lower level found it")
    }, onFailure: { error in
      XCTFail("Should not get here")
    })
  }
}
