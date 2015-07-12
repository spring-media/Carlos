import Foundation

/// Abstract an object that can transform values to another type
public protocol OneWayTransformer {
  /// The input type of the transformer
  typealias TypeIn
  
  /// The output type of the transformer
  typealias TypeOut
  
  /**
  Apply the transformation from A to B
  
  :param: val The value to transform
  
  :returns: The transformed value
  */
  func transform(val: TypeIn) -> TypeOut
}

/// Simple implementation of the TwoWayTransformer protocol
public class OneWayTransformationBox<I, O>: OneWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = I
  
  /// The output type of the transformation box
  public typealias TypeOut = O
  
  private let transformClosure: I -> O
  
  public init(transform: (I -> O)) {
    self.transformClosure = transform
  }
  
  public func transform(val: TypeIn) -> TypeOut {
    return transformClosure(val)
  }
}
