import Foundation
import PiedPiper

/// Abstract an object that can conditionally transform values to another type
public protocol ConditionedOneWayTransformer {
  /// The input type of the transformer
  associatedtype TypeIn
  
  /// The output type of the transformer
  associatedtype TypeOut
  
  /// The type of the key used to evaluate the condition
  associatedtype KeyType
  
  /**
   Apply the conditional transformation from A to B
   
   - parameter key: The key to use to evaluate the condition
   - parameter val: The value to transform
   
   - returns: A Future that will contain the transformed value, or fail if the transformation failed
   */
  func conditionalTransform(key: KeyType, value: TypeIn) -> Future<TypeOut>
}

/// Simple implementation of the ConditionedOneWayTransformer protocol
public final class ConditionedOneWayTransformationBox<Key, InputType, OutputType>: ConditionedOneWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = InputType
  
  /// The output type of the transformation box
  public typealias TypeOut = OutputType
  
  /// The key type used by the transformation box
  public typealias KeyType = Key
  
  private let conditionalTransformClosure: (_ key: Key, _ value: InputType) -> Future<OutputType>
  
  /**
   Initializes a conditioned 1-way transformation box with the given closure
   
   - parameter conditionalTransformClosure: The conditional transformation closure to convert a value of type TypeIn into a value of type TypeOut given a key of type KeyType
   */
  public init(conditionalTransformClosure: @escaping (_ key: Key, _ value: InputType) -> Future<OutputType>) {
    self.conditionalTransformClosure = conditionalTransformClosure
  }
  
  /**
   Convenience initializer to create a conditioned 1-way transformation box through a normal 1-way transformer
   
    - parameter transformer: The normal OneWayTransformer with matching input and output type
   
   This initializer will basically ignore the key
   */
  public convenience init<T: OneWayTransformer>(transformer: T) where T.TypeIn == TypeIn, T.TypeOut == TypeOut {
    self.init(conditionalTransformClosure: { _, value in
      transformer.transform(value)
    })
  }
  
  /**
   Conditionally transforms a value of type TypeIn into a value of type TypeOut, based on the given key
   
   - parameter key: The key to use to evaluate the condition
   - parameter val: The value to convert
   
   - returns: A Future that will contain the converted value or fail if the transformation fails
   */
  public func conditionalTransform(key: KeyType, value: TypeIn) -> Future<TypeOut> {
    return conditionalTransformClosure(key, value)
  }
}
