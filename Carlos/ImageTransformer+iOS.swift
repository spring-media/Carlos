import Foundation

/**
This class takes care of transforming NSData instances into UIImage objects.

Keep in mind that at the moment this class always deserializes images through UIImagePNGRepresentation, so there may be a data usage bigger than actually required.
*/
public class ImageTransformer: TwoWayTransformer {
  public typealias TypeIn = NSData
  public typealias TypeOut = UIImage
  
  public init() {}
  
  /**
  Serializes an NSData instance into a UIImage
  
  - parameter val: The NSData you want to serialize
  
  - returns: A UIImage object if the input was valid, .None otherwise
  */
  public func transform(val: TypeIn) -> TypeOut? {
    return UIImage(data: val)
  }
  
  /**
  Deserializes an UIImage instance into NSData
  
  - parameter val: The UIImage you want to deserialize
  
  - returns: An NSData instance obtained with UIImagePNGRepresentation if the input was valid, .None otherwise
  */
  public func inverseTransform(val: TypeOut) -> TypeIn? {
    return UIImagePNGRepresentation(val) /* This is a waste of bytes, we should probably use a lower-level framework */
  }
}