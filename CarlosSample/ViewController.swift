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
  typealias OutputType = NSData
  
  func get(fetchable: KeyType) -> CacheRequest<OutputType> {
    return CacheRequest<OutputType>()
  }
  
  func clear() {
    
  }
  
  func set(value: OutputType, forKey fetchable: KeyType) {
    
  }
  
  func onMemoryWarning() {
    
  }
}

class TestCache2: CacheLevel {
  typealias KeyType = NSData
  typealias OutputType = NSData
  
  func get(fetchable: KeyType) -> CacheRequest<OutputType> {
    return CacheRequest<OutputType>()
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
    
    let testToURL = OneWayTransformationBox(transform: { (x: Test) -> NSURL in
      x.y
    })
    let testToString = OneWayTransformationBox(transform: { (x: Test) -> String in
      "\(x.x)"
    })
    let testToData = OneWayTransformationBox(transform: { (x: Test) -> NSData in
      x.y.absoluteString!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    })
    
    let cache: BasicCache<Test, NSData> = (testToString =>> MemoryCacheLevel()) >>> (testToString =>> DiskCacheLevel()) >>> (testToURL =>> NetworkFetcher()) >>> ((testToURL =>> TestCache()) >>> (testToData =>> TestCache2()))
    
    let testToFetch = Test(x: 1, y: NSURL(string: "http://www.google.de")!)
    cache.get(testToFetch)
      .onSuccess({ value in
        println("Fetched successfully value")
      })
      .onFailure({ error in
        println("Error \(error) during fetch")
      })
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW,
      Int64(2 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      cache.get(testToFetch)
        .onSuccess({ value in
          println("Fetched successfully value")
        })
        .onFailure({ error in
          println("Error \(error) during fetch")
        })
    }
  }
}

