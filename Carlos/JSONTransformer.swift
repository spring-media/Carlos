import Foundation

/**
This class takes care of transforming NSData instances into JSON objects in the form of AnyObject instances. Depending on your usage, the AnyObject could contain an Array, a Dictionary, or nil if the NSData is not a valid JSON
*/
public class JSONTransformer: TwoWayTransformer {
  public typealias TypeIn = NSData
  public typealias TypeOut = AnyObject
  
  /// Initializes a new instance of JSONTransformer
  public init() {}
  
  /**
  Parses JSON from an NSData instance into an AnyObject instance
  
  - parameter val: The NSData representing the received JSON
  
  - returns: An Optional<AnyObject> value, with the parsed JSON if the input data was valid, .None otherwise
  */
  public func transform(val: TypeIn) -> Result<TypeOut> {
    let result = Result<TypeOut>()
    
    do {
      let transformed = try NSJSONSerialization.JSONObjectWithData(val, options: [.AllowFragments])
      result.succeed(transformed)
    } catch {
      result.fail(error)
    }
    
    return result
  }
  
  /**
  Deserializes a JSON object into an NSData instance
  
  - parameter val: The JSON object you want to deserialize
  
  - returns: An Optional<NSData> value, with the deserialized JSON if the input was valid, .None otherwise
  */
  public func inverseTransform(val: TypeOut) -> Result<TypeIn> {
    let result = Result<TypeIn>()
    
    do {
      let transformed = try NSJSONSerialization.dataWithJSONObject(val, options: [])
      result.succeed(transformed)
    } catch {
      result.fail(error)
    }
    
    return result
  }
}