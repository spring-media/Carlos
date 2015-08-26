//
//  ExtensionDelegate.swift
//  CarlosWatchSample Extension
//
//  Created by Monaco, Vittorio on 26/08/15.
//  Copyright © 2015 WeltN24. All rights reserved.
//

import WatchKit
import CarlosWatch

class ExtensionDelegate: NSObject, WKExtensionDelegate {
  var cache: BasicCache<NSURL, NSData>!
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
