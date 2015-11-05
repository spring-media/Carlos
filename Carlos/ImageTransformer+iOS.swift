import Foundation
import UIKit

/**
This class takes care of transforming NSData instances into UIImage objects.

Keep in mind that at the moment this class always deserializes images through UIImagePNGRepresentation, so there may be a data usage bigger than actually required.
*/
public class ImageTransformer: TwoWayTransformer {
  public enum Error: ErrorType {
    case InvalidData
    case CannotConvertImage
  }
  
  public typealias TypeIn = NSData
  public typealias TypeOut = UIImage
  
  /// Initializes a new instance of ImageTransformer
  public init() {}
  
  /**
  Serializes an NSData instance into a UIImage
  
  - parameter val: The NSData you want to serialize
  
  - returns: A Future<UIImage> object
  */
  public func transform(val: TypeIn) -> Future<TypeOut> {
    let result = Promise<TypeOut>()
    
    GCD.background {
      UIImage(data: val)
    }.main { image in
      if let image = image {
        result.succeed(image)
      } else {
        result.fail(Error.InvalidData)
      }
    }
    
    return result.future
  }
  
  /**
  Deserializes an UIImage instance into NSData
  
  - parameter val: The UIImage you want to deserialize
  
  - returns: A Future<NSData> instance obtained with UIImagePNGRepresentation
  */
  public func inverseTransform(val: TypeOut) -> Future<TypeIn> {
    let result = Promise<TypeIn>()
    
    GCD.background {
      /* This is a waste of bytes, we should probably use a lower-level framework */
      UIImagePNGRepresentation(val)
    }.main { data in
      if let data = data {
        result.succeed(data)
      } else {
        result.fail(Error.CannotConvertImage)
      }
    }
    
    return result.future
  }
}