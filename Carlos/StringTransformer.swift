import Foundation

/**
This class takes care of transforming NSData instances into String values.
*/
public class StringTransformer: TwoWayTransformer {
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
  
  - returns: The serialized String with the given encoding if the input is valid, .None otherwise
  */
  public func transform(val: TypeIn) -> TypeOut? {
    return NSString(data: val, encoding: encoding) as? String
  }
  
  /**
  Deserializes a String into a NSData instance
  
  - parameter val: The String to deserialize
  
  - returns: An NSData instance containing the bytes representation of the given string, .None if the deserialization failed
  */
  public func inverseTransform(val: TypeOut) -> TypeIn? {
    return val.dataUsingEncoding(encoding, allowLossyConversion: false)
  }
}