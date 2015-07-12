import Foundation

/// Abstract an object that can transform values to another type and back to the original one
public protocol TwoWayTransformer: OneWayTransformer {
  /**
  Apply the inverse transformation from B to A
  
  :param: val The value to inverse transform
  
  :returns: The original value
  */
  func inverseTransform(val: TypeOut) -> TypeIn
}

/// Simple implementation of the TwoWayTransformer protocol
public final class TwoWayTransformationBox<I, O>: TwoWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = I
  
  /// The output type of the transformation box
  public typealias TypeOut = O
  
  private let transformClosure: I -> O
  private let inverseTransformClosure: O -> I
  
  public init(transform: (I -> O), inverseTransform: (O -> I)) {
    self.transformClosure = transform
    self.inverseTransformClosure = inverseTransform
  }
  
  public func transform(val: I) -> O {
    return transformClosure(val)
  }
  
  public func inverseTransform(val: O) -> I {
    return inverseTransformClosure(val)
  }
}

/**
Inverts a TwoWayTransformer

:param: transformer The TwoWayTransformer you want to invert

:returns: A TwoWayTransformationBox that takes the output type of the original transformer and returns the input type of the original transformer
*/
public func invert<A: TwoWayTransformer, B, C where A.TypeIn == B, A.TypeOut == C>(transformer: A) -> TwoWayTransformationBox<C, B> {
  return TwoWayTransformationBox<C, B>(transform: { input in
    transformer.inverseTransform(input)
  }, inverseTransform: { output in
    transformer.transform(output)
  })
}