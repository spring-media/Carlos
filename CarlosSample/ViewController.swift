//
//  ViewController.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import UIKit
import Carlos

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cache = MemoryCacheLevel() >>> DiskCacheLevel() >>> (NetworkFetcher() <^> OneWayTransformationBox(transform: { str in
      NSURL(string: str)!
    }))
    
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

