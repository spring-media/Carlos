//
//  ViewController.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import UIKit
import Carlos

func basePath() -> String {
  let cachesPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
  let hanekePathComponent = "com.carlos"
  let basePath = cachesPath.stringByAppendingPathComponent(hanekePathComponent)
  return basePath
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSFileManager.defaultManager().createDirectoryAtPath(basePath(), withIntermediateDirectories: true, attributes: [:], error: nil)
    let cache = Cache(levels: [MemoryCacheLevel(), DiskCache(path: basePath()), FallbackFetcher(staticvalue: "test".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!), NetworkFetcher()])
    
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

