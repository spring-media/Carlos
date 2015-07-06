//
//  DiskCacheTests.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 06/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import UIKit
import XCTest
import Carlos

class DiskCacheTests: XCTestCase {
  var sut: DiskCacheLevel!
  var fileManager: NSFileManagerFake!
  var realFileManager = NSFileManager.defaultManager()
  
  let size: UInt64 = 100
  let path = {
    (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String).stringByAppendingPathComponent("disk_cache")
  }()
  
  override func setUp() {
    super.setUp()
    
    fileManager = NSFileManagerFake()
    sut = DiskCacheLevel(path: path, capacity: size, fileManager: fileManager)
  }
  
  override func tearDown() {
    super.tearDown()
    
    realFileManager.removeItemAtPath(path, error: nil)
  }
  
  func testShouldPrepareTheCacheDirectory() {
    XCTAssertNotNil(fileManager.createdDirectoryAtPath, "Should ask the file manager to create a directory")
    
    if let directoryPath = fileManager.createdDirectoryAtPath {
      XCTAssertEqual(directoryPath, path, "Should create the right path")
    }
  }
  
  func testSetValueShouldSaveOnDisk() {
    let key = "testKey"
    let expectedData = "testData".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    
    sut.set(expectedData, forKey: key)

    let expectation = expectationWithDescription("Set value on disk")
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      XCTAssertTrue(self.realFileManager.fileExistsAtPath(self.path.stringByAppendingPathComponent(key.MD5TestString())), "The file should be on disk")
      XCTAssertEqual(NSData(contentsOfFile: self.path.stringByAppendingPathComponent(key.MD5TestString()))!, expectedData, "The file should contain the right data")
      
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(0.5, handler: { error in
      if let error = error {
        XCTFail("Should not get here")
      }
    })
  }
  
  func testGetShouldFailIfValueWasNeverSet() {
    let key = "testKey2"
    
    let expectation = expectationWithDescription("Get value from disk when no value was set")
    
    sut.get(key, onSuccess: { _ in
      XCTFail("Should not get here")
    }, onFailure: { error in
      XCTAssertTrue(true, "Should get here because no value was on disk")
      
      expectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(0.5, handler: { error in
      if let error = error {
        XCTFail("Should not get here")
      }
    })
  }
  
  func testGetShouldReturnTheCachedValueIfPreviouslySet() {
    let key = "testKey3"
    let expectedData = "simple value to save".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    
    let expectation = expectationWithDescription("Get value from disk when a value was set")
    
    sut.set(expectedData, forKey: key)
    sut.get(key, onSuccess: { data in
      XCTAssertEqual(data, expectedData, "Should return the right data")
      expectation.fulfill()
    }, onFailure: { _ in
      XCTFail("Should not get here")
    })
    
    waitForExpectationsWithTimeout(0.5, handler: { error in
      if let error = error {
        XCTFail("Should not get here")
      }
    })
  }
  
  func testShouldNotExceedItsCapacity() {
    let keys = ["key1", "key2", "key3", "key4"]
    let values = [
      "This is a first simple value",
      "This is a second longer value",
      "Yet another value that should keep increasing the disk size",
      "Last value that should exceed the cache threshold of 100 bytes or whatever"]
    
    for (key, value) in zip(keys, values) {
      sut.set(value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: key)
    }
    
    var atLeastOneIsNotThereAnymore = false
    for key in keys {
      sut.get(key, onSuccess: { _ in }, onFailure: { _ in
        atLeastOneIsNotThereAnymore = true
      })
    }
    
    let expectation = expectationWithDescription("Set values on disk")
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      XCTAssertTrue(atLeastOneIsNotThereAnymore, "At least one value should have been removed from the disk cache")
      
      expectation.fulfill()
    }
    
    waitForExpectationsWithTimeout(0.5, handler: { error in
      if let error = error {
        XCTFail("Should not get here")
      }
    })
  }
  
  func testShouldAdoptAnLRUStrategyWhenPurging() {
    let keys = ["key1", "key2", "key3", "key4"]
    let values = [
      "This is a first simple value",
      "This is a second longer value",
      "Yet another value that should keep increasing the disk size",
      "Last value that should exceed the cache threshold of 100 bytes or whatever"]
    
    for (key, value) in zip(keys, values) {
      sut.set(value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: key)
    }
  
    let expectation = expectationWithDescription("LRU strategy when purging the disk cache")
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.sut.get(keys.first!, onSuccess: { _ in
      }, onFailure: { _ in
        XCTAssertTrue(true, "should clear the oldest key")
        expectation.fulfill()
      })
    }
    
    waitForExpectationsWithTimeout(0.5, handler: { error in
      if let error = error {
        XCTFail("Should not get here")
      }
    })
  }
  
  func testClearShouldRemoveAllTheValues() {
    let key = "testKey3"
    let expectedData = "simple value to save".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    
    let expectation = expectationWithDescription("Clear values on the disk cache")
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
    sut.set(expectedData, forKey: key)
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.sut.clear()
    }
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.sut.get(key, onSuccess: { data in
        XCTFail("Should not get here")
      }, onFailure: { _ in
        XCTAssertTrue(true, "Should get here because the value is not on disk anymore")
        expectation.fulfill()
      })
    }
    
    waitForExpectationsWithTimeout(0.6, handler: { error in
      if let error = error {
        XCTFail("Should not get here")
      }
    })
  }
  
  func testOnMemoryWarningShouldBeNoOp() {
    let key = "testKey3"
    let expectedData = "simple value to save".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    
    let expectation = expectationWithDescription("Memory warning on the disk cache")
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
    sut.set(expectedData, forKey: key)
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.sut.onMemoryWarning()
    }
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.sut.get(key, onSuccess: { data in
        XCTAssertEqual(data, expectedData, "Should return the right data")
        
        expectation.fulfill()
      }, onFailure: { _ in
          XCTFail("Should not get here")
      })
    }
    
    waitForExpectationsWithTimeout(0.6, handler: { error in
      if let error = error {
        XCTFail("Should not get here")
      }
    })
  }
}
