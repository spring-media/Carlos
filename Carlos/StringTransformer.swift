import Foundation
import PiedPiper

/**
This class takes care of transforming NSData instances into String values.
*/
final public class StringTransformer: TwoWayTransformer {
  public enum TransformationError: Error {
    case invalidData
    case dataConversionToStringFailed
  }
  
  public typealias TypeIn = NSData
  public typealias TypeOut = String
  
  private let encoding: String.Encoding
  
  /**
  Initializes a new instance of StringTransformer
  
  - parameter encoding: The encoding the transformer will use when serializing and deserializing NSData instances. By default it's NSUTF8StringEncoding
  */
  public init(encoding: String.Encoding = String.Encoding.utf8) {
    self.encoding = encoding
  }
  
  /**
  Serializes a NSData instance into a String with the configured encoding
  
  - parameter val: The NSData instance to serialize
  
  - returns: A Future containing the serialized String with the given encoding if the input is valid
  */
  public func transform(_ val: TypeIn) -> Future<TypeOut> {
    return Future(value: String(data: val as Data, encoding: encoding), error: TransformationError.invalidData)
  }
  
  /**
  Deserializes a String into a NSData instance
  
  - parameter val: The String to deserialize
  
  - returns: A Future<NSData> instance containing the bytes representation of the given string
  */
  public func inverseTransform(_ val: TypeOut) -> Future<TypeIn> {
    return Future(value: val.data(using: encoding, allowLossyConversion: false) as NSData?, error: TransformationError.dataConversionToStringFailed)
  }
}
