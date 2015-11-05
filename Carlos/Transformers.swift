import Foundation
import MapKit

/**
NSDateFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSDate to String (transform) and viceversa (inverseTransform)
*/
extension NSDateFormatter: TwoWayTransformer {
  public enum Error: ErrorType {
    case InvalidInputString
  }
  
  public typealias TypeIn = NSDate
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> Future<TypeOut> {
    return Promise(value: stringFromDate(val)).future
  }
  
  public func inverseTransform(val: TypeOut) -> Future<TypeIn> {
    return Promise(value: dateFromString(val), error: Error.InvalidInputString).future
  }
}

/**
NSNumberFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSNumber to String (transform) and viceversa (inverseTransform)
*/
extension NSNumberFormatter: TwoWayTransformer {
  public enum Error: ErrorType {
    case CannotConvertToString
    case InvalidString
  }
  
  public typealias TypeIn = NSNumber
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> Future<TypeOut> {
    return Promise(value: stringFromNumber(val), error: Error.CannotConvertToString).future
  }
  
  public func inverseTransform(val: TypeOut) -> Future<TypeIn> {
    return Promise(value: numberFromString(val), error: Error.InvalidString).future
  }
}

/**
MKDistanceFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from CLLocationDistance to String (transform) and viceversa (inverseTransform)
*/
extension MKDistanceFormatter: TwoWayTransformer {
  public typealias TypeIn = CLLocationDistance
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> Future<TypeOut> {
    return Promise(value: stringFromDistance(val)).future
  }
  
  public func inverseTransform(val: TypeOut) -> Future<TypeIn> {
    return Promise(value: distanceFromString(val)).future
  }
}
