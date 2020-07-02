import Foundation
import PiedPiper
import MapKit

public enum NSDateFormatterError: Error {
  case invalidInputString
}

/**
NSDateFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSDate to String (transform) and viceversa (inverseTransform)
*/
extension DateFormatter: TwoWayTransformer {
  public typealias TypeIn = Date
  public typealias TypeOut = String
  
  public func transform(_ val: TypeIn) -> Future<TypeOut> {
    return Future(string(from: val))
  }
  
  public func inverseTransform(_ val: TypeOut) -> Future<TypeIn> {
    return Future(value: date(from: val), error: NSDateFormatterError.invalidInputString)
  }
}

public enum NSNumberFormatterError: Error {
  case cannotConvertToString
  case invalidString
}

/**
NSNumberFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from NSNumber to String (transform) and viceversa (inverseTransform)
*/
extension NumberFormatter: TwoWayTransformer {
  public typealias TypeIn = NSNumber
  public typealias TypeOut = String
  
  public func transform(_ val: TypeIn) -> Future<TypeOut> {
    return Future(value: string(from: val), error: NSNumberFormatterError.cannotConvertToString)
  }
  
  public func inverseTransform(_ val: TypeOut) -> Future<TypeIn> {
    return Future(value: number(from: val), error: NSNumberFormatterError.invalidString)
  }
}

/**
MKDistanceFormatter extension to conform to the TwoWayTransformer protocol

This class transforms from CLLocationDistance to String (transform) and viceversa (inverseTransform)
*/
extension MKDistanceFormatter: TwoWayTransformer {
  public typealias TypeIn = CLLocationDistance
  public typealias TypeOut = String
  
  public func transform(_ val: TypeIn) -> Future<TypeOut> {
    return Future(string(fromDistance: val))
  }
  
  public func inverseTransform(_ val: TypeOut) -> Future<TypeIn> {
    return Future(distance(from: val))
  }
}
