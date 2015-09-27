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
    return dateFromString(val)
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


/**
This class takes care of transforming NSData instances into JSON objects in the form of AnyObject instances. Depending on your usage, the AnyObject could contain an Array, a Dictionary, or nil if the NSData is not a valid JSON
*/
public class JSONTransformer: TwoWayTransformer {
  public typealias TypeIn = NSData
  public typealias TypeOut = AnyObject
  
  public init() {}
  
  /**
  Parses JSON from an NSData instance into an AnyObject instance 
  
  - parameter val: The NSData representing the received JSON
  
  - returns: An Optional<AnyObject> value, with the parsed JSON if the input data was valid, .None otherwise
  */
  public func transform(val: TypeIn) -> TypeOut? {
    return try? NSJSONSerialization.JSONObjectWithData(val, options: [.AllowFragments])
  }
  
  /**
  Deserializes a JSON object into an NSData instance
  
  - parameter val: The JSON object you want to serialize
  
  - returns: An Optional<NSData> value, with the deserialized JSON if the input was valid, .None otherwise
  */
  public func inverseTransform(val: TypeOut) -> TypeIn? {
    return try? NSJSONSerialization.dataWithJSONObject(val, options: [])
  }
}