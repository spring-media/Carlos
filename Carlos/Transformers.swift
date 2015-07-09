//
//  Transformers.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 09/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation
import MapKit

/**
NSDateFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSDate to String (transform) and viceversa (inverseTransform)
*/
extension NSDateFormatter: TwoWayTransformer {
  public typealias TypeIn = NSDate
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromDate(val)
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn {
    return dateFromString(val)!
  }
}

/**
NSNumberFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSNumber to String (transform) and viceversa (inverseTransform)
*/
extension NSNumberFormatter: TwoWayTransformer {
  public typealias TypeIn = NSNumber
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromNumber(val) ?? ""
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn {
    return numberFromString(val) ?? 0
  }
}

/**
NSDateComponentsFormatter extension to conform to the OneWayTransformer protocol

This class transforms from NSDateComponents to String
*/
extension NSDateComponentsFormatter: OneWayTransformer {
  public typealias TypeIn = NSDateComponents
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromDateComponents(val) ?? ""
  }
}

/**
NSByteCountFormatter extension to conform to the OneWayTransformer protocol

This class transforms from Int64 to String
*/
extension NSByteCountFormatter: OneWayTransformer {
  public typealias TypeIn = Int64
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromByteCount(val)
  }
}

/**
MKDistanceFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from CLLocationDistance to String (transform) and viceversa (inverseTransform)
*/
extension MKDistanceFormatter: TwoWayTransformer {
  public typealias TypeIn = CLLocationDistance
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut {
    return stringFromDistance(val)
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn {
    return distanceFromString(val)
  }
}