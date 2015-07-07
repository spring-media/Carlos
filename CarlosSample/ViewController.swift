//
//  ViewController.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import UIKit
import Carlos

struct Test {
  let x: Int
  let y: NSURL
}

class TestCache: CacheLevel {
  typealias KeyType = NSURL
  typealias OutputType = Int
  
  func get(fetchable: KeyType, onSuccess success: (OutputType) -> Void, onFailure failure: (NSError?) -> Void) {
  }
  
  func clear() {
    
  }
  
  func set(value: OutputType, forKey fetchable: KeyType) {
    
  }
  
  func onMemoryWarning() {
    
  }
}

class TestCache2: CacheLevel {
  typealias KeyType = Int
  typealias OutputType = Int
  
  func get(fetchable: KeyType, onSuccess success: (OutputType) -> Void, onFailure failure: (NSError?) -> Void) {
    
  }
  
  func set(value: OutputType, forKey fetchable: KeyType) {
    
  }
  
  func clear() {
    
  }
  
  func onMemoryWarning() {
    
  }
}

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let test = TestCache()
    let transformation = OneWayTransformationBox(transform: { (x: Test) -> NSURL in
      x.y
    })
    let test2 = TestCache2()
    let transformation2 = OneWayTransformationBox(transform: { (x: Test) -> Int in
      x.x
    })
    
    let testTransformation = transformation =>> test
    let testTransformation2 = transformation2 =>> test2
    let finalResult = testTransformation >>> testTransformation2
    
    let cache = MemoryCacheLevel() >>> DiskCacheLevel() >>> (OneWayTransformationBox(transform: { str in
      NSURL(string: str)!
    }) =>> NetworkFetcher())
    
    cache.get("http://www.google.de", onSuccess: { value in
      println("Fetched successfully \(value)")
    }, onFailure: { error in
      println("Error \(error) during fetch")
    })
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
      Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      cache.get("http://www.google.de", onSuccess: { value in
        println("Fetched successfully \(value)")
        }, onFailure: { error in
          println("Error \(error) during fetch")
      })
    }
  }
}

