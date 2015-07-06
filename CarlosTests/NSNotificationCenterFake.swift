//
//  NSNotificationCenterFake.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 06/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

class NSNotificationCenterFake: NSNotificationCenter {
  var subscribedToNotificationWithName: String?
  private var notificationBlock: ((NSNotification!) -> Void)?
  override func addObserverForName(name: String?, object obj: AnyObject?, queue: NSOperationQueue?, usingBlock block: (NSNotification!) -> Void) -> NSObjectProtocol {
    subscribedToNotificationWithName = name
    notificationBlock = block
    
    return super.addObserverForName(name, object: obj, queue: queue, usingBlock: block)
  }
  
  var unsubscribedToNotificationWithName: String?
  override func removeObserver(observer: AnyObject, name aName: String?, object anObject: AnyObject?) {
    unsubscribedToNotificationWithName = aName
    
    super.removeObserver(observer, name: aName, object: anObject)
  }
  
  func simulateNotification() {
    notificationBlock?(nil)
  }
}