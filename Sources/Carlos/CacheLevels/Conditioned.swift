import Combine
import Foundation

extension CacheLevel {
  /**
   Wraps the CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

   - parameter condition: The condition closure that takes a key and returns true if the key can be fetched, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Future<Bool>

   - returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

   The condition doesn't apply to the set, clear, onMemoryWarning calls
   */
  public func conditioned(_ condition: @escaping (KeyType) -> AnyPublisher<Bool, Error>) -> BasicCache<KeyType, OutputType> {
    BasicCache(
      getClosure: conditionedClosure(get, condition: condition),
      setClosure: set,
      removeClosure: remove,
      clearClosure: clear,
      memoryClosure: onMemoryWarning
    )
  }
}

private func conditionedClosure<A, B>(_ closure: @escaping (A) -> AnyPublisher<B, Error>, condition: @escaping (A) -> AnyPublisher<Bool, Error>) -> ((A) -> AnyPublisher<B, Error>) {
  return { input in
    condition(input).flatMap { (passesCondition: Bool) -> AnyPublisher<B, Error> in
      if passesCondition {
        return closure(input)
      } else {
        return Fail(error: FetchError.conditionNotSatisfied).eraseToAnyPublisher()
      }
    }.eraseToAnyPublisher()
  }
}

extension OneWayTransformer {
  /**
   Wraps the transformer with a boolean condition on the input that controls when a transformation should fail unconditionally.

   - parameter condition: The condition closure that takes an input and returns true if the input can be transformed, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Future<Bool>

   - returns: A new OneWayTransformer that will check for the condition before every transformation is dispatched to the decorated transformer
   */
  public func conditioned(_ condition: @escaping (TypeIn) -> AnyPublisher<Bool, Error>) -> OneWayTransformationBox<TypeIn, TypeOut> {
    OneWayTransformationBox(transform: conditionedClosure(transform, condition: condition))
  }
}

extension TwoWayTransformer {
  /**
   Wraps the transformer with a boolean condition on the input and a boolean condition on the "inverse input" that controls when a transformation on either side should fail unconditionally.

   - parameter condition: The condition closure used for normal transformations that takes an input and returns true if the input can be transformed, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Future<Bool>
   - parameter inverseCondition: The condition closure used for inverse transformations that takes a TypeOut argument and returns true if the input can be transformed, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Future<Bool>.

   - returns: A new TwoWayTransformer that will check for the conditions before every transformation is dispatched to the decorated transformer
   */
  public func conditioned(_ condition: @escaping (TypeIn) -> AnyPublisher<Bool, Error>, inverseCondition: @escaping (TypeOut) -> AnyPublisher<Bool, Error>) -> TwoWayTransformationBox<TypeIn, TypeOut> {
    TwoWayTransformationBox(
      transform: conditionedClosure(transform, condition: condition),
      inverseTransform: conditionedClosure(inverseTransform, condition: inverseCondition)
    )
  }
}
