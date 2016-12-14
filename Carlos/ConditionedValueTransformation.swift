import Foundation
import PiedPiper

extension Future {
  
  /**
   Mutates a future from a type A to a type B through a ConditionedTwoWayTransformer
   
   - parameter key The key to use for the condition
   - parameter conditionedTransformer A ConditionedTwoWayTransformer used to conditionally transform the values of the given Future
   
   - returns A new Future with the transformed value
   */
  internal func mutate<K, O, Transformer: ConditionedTwoWayTransformer>(key: K, conditionedTransformer: Transformer) -> Future<O> where Transformer.KeyType == K, Transformer.TypeIn == T, Transformer.TypeOut == O {
    return flatMap { result in
      conditionedTransformer.conditionalTransform(key: key, value: result)
    }
  }
}

extension CacheLevel {
  
  /**
   Applies a conditional transformation to the cache level
   
   The transformation works by changing the type of the value the cache returns when succeeding
   
   Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types
   
   - parameter conditionedTransformer: The conditioned transformer that will be applied to every successful result of the method get or (inverse transform) set called on the cache level. The object gets the key used for the get request (where it can apply its condition on) and the fetched value, and returns the transformed value.
   
   - returns: A new cache result of the transformation of the original cache
   */
  public func conditionedValueTransformation<A: ConditionedTwoWayTransformer>(transformer: A) -> BasicCache<KeyType, A.TypeOut> where OutputType == A.TypeIn, A.KeyType == KeyType {
    return BasicCache(
      getClosure: { key -> Future<A.TypeOut> in
        self.get(key).mutate(key, conditionedTransformer: transformer)
      },
      setClosure: { (value, key) in
        transformer.conditionalInverseTransform(key: key, value: value)
          .flatMap { transformedValue in
            self.set(transformedValue, forKey: key)
          }.future
      },
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}

