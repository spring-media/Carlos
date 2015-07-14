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
  
  func get(key: KeyType) -> CacheRequest<OutputType> {
    return CacheRequest<OutputType>()
  }
  
  func clear() {
    
  }
  
  func set(value: OutputType, forKey key: KeyType) {
    
  }
  
  func onMemoryWarning() {
    
  }
}

class TestCache2: CacheLevel {
  typealias KeyType = NSData
  typealias OutputType = NSData
  
  func get(key: KeyType) -> CacheRequest<OutputType> {
    return CacheRequest<OutputType>()
  }
  
  func set(value: OutputType, forKey key: KeyType) {
    
  }
  
  func clear() {
    
  }
  
  func onMemoryWarning() {
    
  }
}

extension Test: Hashable {
  var hashValue: Int {
    return x
  }
}

extension Test: Equatable {
  
}

func ==(lhs: Test, rhs: Test) -> Bool {
  return lhs.x == rhs.x && lhs.y == rhs.y
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
    
    let normalCache = (testToString =>> MemoryCacheLevel()) >>> (testToString =>> DiskCacheLevel()) >>> (testToURL =>> NetworkFetcher()) >>> ((testToURL =>> TestCache()) >>> (testToData =>> TestCache2()))
    
    let cache = pooled(normalCache)
    
    let testToFetch = Test(x: 1, y: NSURL(string: "http://www.repubblica.it")!)
    cache.get(testToFetch)
      .onSuccess({ value in
        println("Fetched successfully repubblica")
      })
      .onFailure({ error in
        println("Error \(error) during fetch of repubblica")
      })
    
    cache.get(testToFetch)
      .onSuccess({ value in
        println("Fetched successfully repubblica")
      })
      .onFailure({ error in
        println("Error \(error) during fetch of repubblica")
      })
    
    cache.get(Test(x: 2, y: NSURL(string: "http://google.de")!))
      .onSuccess({ value in
        println("Fetched successfully google")
      })
      .onFailure({ error in
        println("Error \(error) during fetch of google")
      })
  }
}

