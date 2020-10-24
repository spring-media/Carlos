import Foundation

import Combine

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
  public func transform(_ val: TypeIn) -> AnyPublisher<TypeOut, Error> {
    AnyPublisher.create { promise in
      if let image = CarlosImage(data: val as Data) {
        promise(.success(image))
      } else {
        promise(.failure(TransformationError.invalidData))
      }
    }
    .eraseToAnyPublisher()
  }

  /**
   Deserializes an UIImage instance into NSData

   - parameter val: The UIImage you want to deserialize

   - returns: A Future<NSData> instance obtained with UIImagePNGRepresentation
   */
  public func inverseTransform(_ val: TypeOut) -> AnyPublisher<TypeIn, Error> {
    AnyPublisher.create { promise in
      #if os(macOS)
        if let rep = val.tiffRepresentation, let bitmapImageRep = NSBitmapImageRep(data: rep) {
          promise(.success(bitmapImageRep.representation(using: .png, properties: [:])))
        }
        promise(.success(nil))
      #else
        /* This is a waste of bytes, we should probably use a lower-level framework */
        promise(.success(val.pngData()))
      #endif
    }.flatMap { (data: Data?) -> AnyPublisher<TypeIn, Error> in
      guard let data = data else {
        return Fail(error: TransformationError.cannotConvertImage).eraseToAnyPublisher()
      }

      return Just(data as NSData)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    .eraseToAnyPublisher()
  }
}
