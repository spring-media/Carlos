import Foundation
import PiedPiper

/// Abstract an object that can transform values to another type
public protocol OneWayTransformer {
  /// The input type of the transformer
  associatedtype TypeIn
  
  /// The output type of the transformer
  associatedtype TypeOut
  
  /**
  Apply the transformation from A to B
  
  - parameter val: The value to transform
  
  - returns: A Future that will contain the transformed value, or fail if the transformation failed
  */
  func transform(_ val: TypeIn) -> Future<TypeOut>
}

/// Simple implementation of the OneWayTransformer protocol
public final class OneWayTransformationBox<I, O>: OneWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = I
  
  /// The output type of the transformation box
  public typealias TypeOut = O
  
  private let transformClosure: (I) -> Future<O>
  
  /**
  Initializes a 1-way transformation box with the given closure
  
  - parameter transform: The transformation closure to convert a value of type TypeIn into a value of type TypeOut
  */
  public init(transform: @escaping ((I) -> Future<O>)) {
    self.transformClosure = transform
  }
  
  /**
  Transforms a value of type TypeIn into a value of type TypeOut
  
  - parameter val: The value to convert
  
  - returns: A Future that will contain the converted value or fail if the transformation fails
  */
  public func transform(_ val: TypeIn) -> Future<TypeOut> {
    return transformClosure(val)
  }
}
