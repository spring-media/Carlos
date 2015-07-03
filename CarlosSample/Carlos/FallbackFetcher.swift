//
//  FallbackFetcher.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

public class FallbackFetcher: CacheLevel {
  private let staticValue: NSData
  
  public init(staticvalue: NSData) {
    self.staticValue = staticvalue
  }
  
  public func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    println("Fetching key: \(key.key) on dummy fetcher")
    
    if arc4random_uniform(7)%3 == 0 {
      println("You're lucky today!")
      success(staticValue)
    } else {
      println("No luck today!")
      failure(nil)
    }
  }
  
  public func onMemoryWarning() {}
  
  public func set(value: NSData, forKey key: FetchableType) {
    println("Set \(value) for \(key.key)")
  }
  
  public func clear() {
  }
}
