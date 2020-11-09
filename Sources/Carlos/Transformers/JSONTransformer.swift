import Combine
import Foundation

/**
 This class takes care of transforming NSData instances into JSON objects in the form of AnyObject instances. Depending on your usage, the AnyObject could contain an Array, a Dictionary, or nil if the NSData is not a valid JSON
 */
public final class JSONTransformer: TwoWayTransformer {
  public typealias TypeIn = NSData
  public typealias TypeOut = AnyObject

  /// Initializes a new instance of JSONTransformer
  public init() {}

  /**
   Parses JSON from an NSData instance into an AnyObject instance

   - parameter val: The NSData representing the received JSON

   - returns: A Future<AnyObject> value, with the parsed JSON if the input data was valid
   */
  public func transform(_ val: TypeIn) -> AnyPublisher<TypeOut, Error> {
    AnyPublisher.create { promise in
      do {
        let transformed = try JSONSerialization.jsonObject(with: val as Data, options: [.allowFragments]) as AnyObject
        promise(.success(transformed))
      } catch {
        promise(.failure(error))
      }
    }
  }

  /**
   Deserializes a JSON object into an NSData instance

   - parameter val: The JSON object you want to deserialize

   - returns: A Future<NSData> value, with the deserialized JSON if the input was valid
   */
  public func inverseTransform(_ val: TypeOut) -> AnyPublisher<TypeIn, Error> {
    AnyPublisher.create { promise in
      do {
        let transformed = try JSONSerialization.data(withJSONObject: val, options: [])
        promise(.success(transformed as NSData))
      } catch {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
}
