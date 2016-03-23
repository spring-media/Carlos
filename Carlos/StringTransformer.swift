import Foundation
import PiedPiper

/**
This class takes care of transforming NSData instances into String values.
*/
public class StringTransformer: TwoWayTransformer {
  public enum Error: ErrorType {
    case InvalidData
    case DataConversionToStringFailed
  }
  
  public typealias TypeIn = NSData
  public typealias TypeOut = String
  
  private let encoding: NSStringEncoding
  
  /**
  Initializes a new instance of StringTransformer
  
  - parameter encoding: The encoding the transformer will use when serializing and deserializing NSData instances. By default it's NSUTF8StringEncoding
  */
  public init(encoding: NSStringEncoding = NSUTF8StringEncoding) {
    self.encoding = encoding
  }
  
  /**
  Serializes a NSData instance into a String with the configured encoding
  
  - parameter val: The NSData instance to serialize
  
  - returns: A Future containing the serialized String with the given encoding if the input is valid
  */
  public func transform(val: TypeIn) -> Future<TypeOut> {
    return Promise(value: NSString(data: val, encoding: encoding) as? String, error: Error.InvalidData).future
  }
  
  /**
  Deserializes a String into a NSData instance
  
  - parameter val: The String to deserialize
  
  - returns: A Future<NSData> instance containing the bytes representation of the given string
  */
  public func inverseTransform(val: TypeOut) -> Future<TypeIn> {
    return Promise(value: val.dataUsingEncoding(encoding, allowLossyConversion: false), error: Error.DataConversionToStringFailed).future
  }
}