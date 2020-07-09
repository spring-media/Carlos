import Foundation
import PiedPiper

/// Abstract an object that can conditionally transform values to another type and back to the original one, based on a given key
public protocol ConditionedTwoWayTransformer: ConditionedOneWayTransformer {
  /**
   Conditionally apply the inverse transformation from B to A
   
   - parameter key: The key to use to evaluate the condition
   - parameter val: The value to inverse transform
   
   - returns: A Future that will contain the original value, or fail if the transformation failed
   */
  func conditionalInverseTransform(key: KeyType, value: TypeOut) -> Future<TypeIn>
}

extension ConditionedTwoWayTransformer {
  
  /**
   Inverts a ConditionedTwoWayTransformer
   
   - returns: A ConditionedTwoWayTransformationBox that takes the output type of the original transformer and returns the input type of the original transformer, maintaining the condition unmodified
   */
  public func invert() -> ConditionedTwoWayTransformationBox<KeyType, TypeOut, TypeIn> {
    return ConditionedTwoWayTransformationBox(conditionalTransformClosure: self.conditionalInverseTransform, conditionalInverseTransformClosure: self.conditionalTransform)
  }
}

/// Simple implementation of the ConditionedTwoWayTransformer protocol
public final class ConditionedTwoWayTransformationBox<Key, InputType, OutputType>: ConditionedTwoWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = InputType
  
  /// The output type of the transformation box
  public typealias TypeOut = OutputType
  
  /// The key type to use for the condition
  public typealias KeyType = Key
  
  private let conditionalTransformClosure: (_ key: Key, _ value: InputType) -> Future<OutputType>
  private let conditionalInverseTransformClosure: (_ key: Key, _ value: OutputType) -> Future<InputType>
  
  /**
   Initializes a new instance of a conditioned 2-way transformation box
   
   - parameter conditionalTransformClosure: The conditional transformation closure to convert a value of type TypeIn to a value of type TypeOut
   - parameter conditionalInverseTransformClosure: The conditional transformation closure to convert a value of type TypeOut to a value of type TypeIn
   */
  public init(conditionalTransformClosure: @escaping (_ key: Key, _ value: InputType) -> Future<OutputType>, conditionalInverseTransformClosure: @escaping (_ key: Key, _ value: OutputType) -> Future<InputType>) {
    self.conditionalTransformClosure = conditionalTransformClosure
    self.conditionalInverseTransformClosure = conditionalInverseTransformClosure
  }
  
  /**
   Convenience initializer to create a conditioned 2-way transformation box through a normal 2-way transformer
   
   - parameter transformer: The normal TwoWayTransformer with matching input and output type
   
   This initializer will basically ignore the key
   */
  public convenience init<T: TwoWayTransformer>(transformer: T) where T.TypeIn == TypeIn, T.TypeOut == TypeOut {
    self.init(conditionalTransformClosure: { _, value in
      transformer.transform(value)
    }, conditionalInverseTransformClosure: { _, value in
      transformer.inverseTransform(value)
    })
  }
  
  /**
   Conditionally converts a value of type TypeIn to a value of type TypeOut, based on the given key
   
   - parameter key: The key to use to evaluate the condition
   - parameter val: The value to convert
   
   - returns: A Future that will contain the converted value, or fail if the transformation fails
   */
  public func conditionalTransform(key: KeyType, value: TypeIn) -> Future<TypeOut> {
    return conditionalTransformClosure(key, value)
  }
  
  /**
   Conditionally converts a value of type TypeOut to a value of type TypeIn, based on the given key
   
   - parameter key: The key to use to evaluate the condition
   - parameter val: The value to convert
   
   - returns: A Future that will contain the converted value, or fail if the inverse transformation fails
   */
  public func conditionalInverseTransform(key: KeyType, value: TypeOut) -> Future<TypeIn> {
    return conditionalInverseTransformClosure(key, value)
  }
}
