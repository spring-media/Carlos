import Foundation
import Combine

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
  public func transform(_ val: TypeIn) -> AnyPublisher<TypeOut, Error> {
    DispatchQueue.global().publisher { promise in
      guard let string = String(data: val as Data, encoding: self.encoding) else {
        promise(.failure(TransformationError.invalidData))
        return
      }
      
      promise(.success(string))
    }
  }
  
  /**
  Deserializes a String into a NSData instance
  
  - parameter val: The String to deserialize
  
  - returns: A Future<NSData> instance containing the bytes representation of the given string
  */
  public func inverseTransform(_ val: TypeOut) -> AnyPublisher<TypeIn, Error> {
    DispatchQueue.global().publisher { promise in
      guard let data = val.data(using: self.encoding, allowLossyConversion: false) as NSData? else {
        promise(.failure(TransformationError.dataConversionToStringFailed))
        return
      }
      
      promise(.success(data))
    }
  }
}
