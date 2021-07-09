import Combine
import Foundation

extension CacheLevel {
  /**
   Applies a conditional transformation to the cache level

   The transformation works by changing the type of the value the cache returns when succeeding

   Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

   - parameter conditionedTransformer: The conditioned transformer that will be applied to every successful result of the method get or (inverse transform) set called on the cache level. The object gets the key used for the get request (where it can apply its condition on) and the fetched value, and returns the transformed value.

   - returns: A new cache result of the transformation of the original cache
   */
  public func conditionedValueTransformation<A: ConditionedTwoWayTransformer>(transformer: A) -> BasicCache<KeyType, A.TypeOut> where OutputType == A.TypeIn, A.KeyType == KeyType {
    BasicCache(
      getClosure: { key -> AnyPublisher<A.TypeOut, Error> in
        self.get(key)
          .flatMap { transformer.conditionalTransform(key: key, value: $0) }
          .eraseToAnyPublisher()
      },
      setClosure: { value, key in
        return transformer.conditionalInverseTransform(key: key, value: value)
          .flatMap { transformedValue in
            self.set(transformedValue, forKey: key)
          }
          .eraseToAnyPublisher()
      },
      removeClosure: remove,
      clearClosure: clear,
      memoryClosure: onMemoryWarning
    )
  }
}
