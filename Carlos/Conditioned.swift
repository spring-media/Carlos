import Foundation
import PiedPiper

extension CacheLevel {
  
  /**
  Wraps the CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally
  
  - parameter condition: The condition closure that takes a key and returns true if the key can be fetched, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Future<Bool>
  
  - returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
  
  The condition doesn't apply to the set, clear, onMemoryWarning calls
  */
  public func conditioned(_ condition: @escaping (KeyType) -> Future<Bool>) -> BasicCache<KeyType, OutputType> {
    return BasicCache(
      getClosure: conditionedClosure(self.get, condition: condition),
      setClosure: self.set,
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}

private func conditionedClosure<A, B>(_ closure: @escaping (A) -> Future<B>, condition: @escaping (A) -> Future<Bool>) -> ((A) -> Future<B>) {
  return { input in
    return condition(input).flatMap { (passesCondition: Bool) -> Future<B> in
      if passesCondition {
        return closure(input)
      } else {
        return Future(FetchError.conditionNotSatisfied)
      }
    }
  }
}

extension OneWayTransformer {
  /**
  Wraps the transformer with a boolean condition on the input that controls when a transformation should fail unconditionally.
   
  - parameter condition: The condition closure that takes an input and returns true if the input can be transformed, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Future<Bool>
   
  - returns: A new OneWayTransformer that will check for the condition before every transformation is dispatched to the decorated transformer
  */
  public func conditioned(_ condition: @escaping (TypeIn) -> Future<Bool>) -> OneWayTransformationBox<TypeIn, TypeOut> {
    return OneWayTransformationBox(transform: conditionedClosure(self.transform, condition: condition))
  }
}

extension TwoWayTransformer {
  /**
  Wraps the transformer with a boolean condition on the input and a boolean condition on the "inverse input" that controls when a transformation on either side should fail unconditionally.
   
  - parameter condition: The condition closure used for normal transformations that takes an input and returns true if the input can be transformed, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Future<Bool>
  - parameter inverseCondition: The condition closure used for inverse transformations that takes a TypeOut argument and returns true if the input can be transformed, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Future<Bool>.
   
  - returns: A new TwoWayTransformer that will check for the conditions before every transformation is dispatched to the decorated transformer
  */
  public func conditioned(_ condition: @escaping (TypeIn) -> Future<Bool>, inverseCondition: @escaping (TypeOut) -> Future<Bool>) -> TwoWayTransformationBox<TypeIn, TypeOut> {
    return TwoWayTransformationBox(
      transform: conditionedClosure(self.transform, condition: condition),
      inverseTransform: conditionedClosure(self.inverseTransform, condition: inverseCondition)
    )
  }
}
