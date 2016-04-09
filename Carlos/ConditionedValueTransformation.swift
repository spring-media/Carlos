import Foundation
import PiedPiper

extension Future {
  
  /**
   Mutates a future from a type A to a type B through a ConditionedTwoWayTransformer
   
   - parameter key The key to use for the condition
   - parameter conditionedTransformer A ConditionedTwoWayTransformer used to conditionally transform the values of the given Future
   
   - returns A new Future with the transformed value
   */
  internal func mutate<K, O, Transformer: ConditionedTwoWayTransformer where Transformer.KeyType == K, Transformer.TypeIn == T, Transformer.TypeOut == O>(key: K, conditionedTransformer: Transformer) -> Future<O> {
    return flatMap { result in
      conditionedTransformer.conditionalTransform(key, value: result)
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
  public func conditionedValueTransformation<A: ConditionedTwoWayTransformer where OutputType == A.TypeIn, A.KeyType == KeyType>(transformer: A) -> BasicCache<KeyType, A.TypeOut> {
    return BasicCache(
      getClosure: { key in
        self.get(key).mutate(key, conditionedTransformer: transformer)
      },
      setClosure: { (value, key) in
        transformer.conditionalInverseTransform(key, value: value)
          .onSuccess { transformedValue in
            self.set(transformedValue, forKey: key)
          }
      },
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}

/**
 Adds a conditioned value transformation step to a given CacheLevel
 
 As usual, if the transformation fails, the get (or set) request will also fail
 
 - parameter cache: The CacheLevel you want to apply the value transformation step to
 - parameter conditionedTransformer: The transformer that will be applied to every get or set. The transformer gets the key used for the request (where it can apply its condition on) and the fetched value or the value to set, and returns a future with the transformed value.
 
 - returns: A transformed CacheLevel that incorporates the value transformation step
 */
public func ?>><A: CacheLevel, T: ConditionedTwoWayTransformer where T.KeyType == A.KeyType, T.TypeIn == A.OutputType>(cache: A, conditionedTransformer: T) -> BasicCache<A.KeyType, T.TypeOut> {
  return cache.conditionedValueTransformation(conditionedTransformer)
}
