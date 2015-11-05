import Foundation

/// Abstract an object that can transform values to another type
public protocol OneWayTransformer: AsyncComputation {
  /// The input type of the transformer
  typealias TypeIn
  
  /// The output type of the transformer
  typealias TypeOut
  
  /**
  Apply the transformation from A to B
  
  - parameter val: The value to transform
  
  - returns: A Future that will contain the transformed value, or fail if the transformation failed
  */
  func transform(val: TypeIn) -> Future<TypeOut>
}

// OneWayTransformers are AsyncComputation by default!
extension OneWayTransformer {
  /// The input type of the asynchronous computation for a OneWayTransformer is the input type of the transform call
  public typealias Input = TypeIn
  
  /// The output type of the asynchronous computation for a OneWayTransformer is the output type of the transform call
  public typealias Output = TypeOut
  
  /**
  This call is equivalent to transform:
   
  - parameter input: The input to transform
   
  - returns: An object containing the result of the transformation or an error
  */
  public func perform(input: TypeIn) -> Future<TypeOut> {
    return transform(input)
  }
}

/// Simple implementation of the OneWayTransformer protocol
public final class OneWayTransformationBox<I, O>: OneWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = I
  
  /// The output type of the transformation box
  public typealias TypeOut = O
  
  private let transformClosure: I -> Future<O>
  
  /**
  Initializes a 1-way transformation box with the given closure
  
  - parameter transform: The transformation closure to convert a value of type TypeIn into a value of type TypeOut
  */
  public init(transform: (I -> Future<O>)) {
    self.transformClosure = transform
  }
  
  /**
  Transforms a value of type TypeIn into a value of type TypeOut
  
  - parameter val: The value to convert
  
  - returns: A Future that will contain the converted value or fail if the transformation fails
  */
  public func transform(val: TypeIn) -> Future<TypeOut> {
    return transformClosure(val)
  }
}
