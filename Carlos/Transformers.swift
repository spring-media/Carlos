import Foundation
import MapKit

/**
NSDateFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSDate to String (transform) and viceversa (inverseTransform)
*/
extension NSDateFormatter: TwoWayTransformer {
  public typealias TypeIn = NSDate
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut? {
    return stringFromDate(val)
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn? {
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
  
  public func transform(val: TypeIn) -> TypeOut? {
    return stringFromNumber(val)
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn? {
    return numberFromString(val)
  }
}

/**
MKDistanceFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from CLLocationDistance to String (transform) and viceversa (inverseTransform)
*/
extension MKDistanceFormatter: TwoWayTransformer {
  public typealias TypeIn = CLLocationDistance
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> TypeOut? {
    return stringFromDistance(val)
  }
  
  public func inverseTransform(val: TypeOut) -> TypeIn? {
    return distanceFromString(val)
  }
}