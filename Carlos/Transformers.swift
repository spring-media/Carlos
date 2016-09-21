import Foundation
import PiedPiper
import MapKit

public enum NSDateFormatterError: ErrorType {
  case InvalidInputString
}

/**
NSDateFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSDate to String (transform) and viceversa (inverseTransform)
*/
extension NSDateFormatter: TwoWayTransformer {
  public typealias TypeIn = NSDate
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> Future<TypeOut> {
    return Future(stringFromDate(val))
  }
  
  public func inverseTransform(val: TypeOut) -> Future<TypeIn> {
    return Future(value: dateFromString(val), error: NSDateFormatterError.InvalidInputString)
  }
}

public enum NSNumberFormatterError: ErrorType {
  case CannotConvertToString
  case InvalidString
}

/**
NSNumberFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSNumber to String (transform) and viceversa (inverseTransform)
*/
extension NSNumberFormatter: TwoWayTransformer {
  public typealias TypeIn = NSNumber
  public typealias TypeOut = String
  
  public func transform(val: TypeIn) -> Future<TypeOut> {
    return Future(value: stringFromNumber(val), error: NSNumberFormatterError.CannotConvertToString)
  }
  
  public func inverseTransform(val: TypeOut) -> Future<TypeIn> {
    return Future(value: numberFromString(val), error: NSNumberFormatterError.InvalidString)
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
    return Future(stringFromDistance(val))
  }
  
  public func inverseTransform(val: TypeOut) -> Future<TypeIn> {
    return Future(distanceFromString(val))
  }
}
