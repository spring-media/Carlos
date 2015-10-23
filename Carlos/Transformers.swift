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
  
  public func transform(val: TypeIn) -> Result<TypeOut> {
    return Result(value: stringFromDate(val))
  }
  
  public func inverseTransform(val: TypeOut) -> Result<TypeIn> {
    return Result(value: dateFromString(val), error: Error.InvalidInputString)
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
  
  public func transform(val: TypeIn) -> Result<TypeOut> {
    return Result(value: stringFromNumber(val), error: Error.CannotConvertToString)
  }
  
  public func inverseTransform(val: TypeOut) -> Result<TypeIn> {
    return Result(value: numberFromString(val), error: Error.InvalidString)
  }
}

/**
MKDistanceFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from CLLocationDistance to String (transform) and viceversa (inverseTransform)
*/
extension MKDistanceFormatter: TwoWayTransformer {
  public typealias TypeIn = CLLocationDistance
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> Result<TypeOut> {
    return Result(value: stringFromDistance(val))
  }
  
  public func inverseTransform(val: TypeOut) -> Result<TypeIn> {
    return Result(value: distanceFromString(val))
  }
}
