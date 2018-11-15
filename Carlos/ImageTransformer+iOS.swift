import Foundation
import PiedPiper
#if os(macOS)
    import Cocoa
    public typealias CarlosImage = NSImage
#else
    import UIKit
    public typealias CarlosImage = UIImage
#endif
/**
This class takes care of transforming NSData instances into UIImage (or NSImage objects on macOS).

Keep in mind that at the moment this class always deserializes images through UIImagePNGRepresentation, so there may be a data usage bigger than actually required.
*/
public final class ImageTransformer: TwoWayTransformer {
  public enum TransformationError: Error {
    case invalidData
    case cannotConvertImage
  }
  
  public typealias TypeIn = NSData
  public typealias TypeOut = CarlosImage
  
  /// Initializes a new instance of ImageTransformer
  public init() {}
  
  /**
  Serializes an NSData instance into a UIImage
  
  - parameter val: The NSData you want to serialize
  
  - returns: A Future<UIImage> object
  */
  public func transform(_ val: TypeIn) -> Future<TypeOut> {
    let result = Promise<TypeOut>()
    
    GCD.background {
      CarlosImage(data: val as Data)
    }.main { image in
      if let image = image {
        result.succeed(image)
      } else {
        result.fail(TransformationError.invalidData)
      }
    }
    
    return result.future
  }
  
  /**
  Deserializes an UIImage instance into NSData
  
  - parameter val: The UIImage you want to deserialize
  
  - returns: A Future<NSData> instance obtained with UIImagePNGRepresentation
  */
  public func inverseTransform(_ val: TypeOut) -> Future<TypeIn> {
    let result = Promise<TypeIn>()
    
    GCD.background { () -> Data? in
      #if os(macOS)
        if let rep = val.tiffRepresentation, let bitmapImageRep = NSBitmapImageRep(data: rep) {
          return bitmapImageRep.representation(using: .png, properties: [:])
        }
        return nil
      #else
      /* This is a waste of bytes, we should probably use a lower-level framework */
      return val.pngData()
      #endif
    }.main { data in
      if let data = data {
        result.succeed(data as NSData)
      } else {
        result.fail(TransformationError.cannotConvertImage)
      }
    }
    
    return result.future
  }
}
