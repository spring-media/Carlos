import Foundation
import PiedPiper

infix operator ?>> { associativity left }

extension Future {
  
  /**
   Mutates a future from a type A to a type B through a ConditionedOneWayTransformer
   
   - parameter key The key to use for the condition
   - parameter conditionedTransformer A ConditionedOneWayTransformer used to conditionally transform the values of the given Future
   
   - returns A new Future with the transformed value
   */
  internal func mutate<K, O, Transformer: ConditionedOneWayTransformer where Transformer.KeyType == K, Transformer.TypeIn == T, Transformer.TypeOut == O>(key: K, conditionedTransformer: Transformer) -> Future<O> {
    return flatMap { result in
      conditionedTransformer.conditionalTransform(key, value: result)
    }
  }
}

extension CacheLevel {
  
  /**
   Adds a conditioned post-processing step to the get results of this CacheLevel
   
   As usual, if the transformation fails, the get request will also fail
   
   - parameter conditionedTransformer: The transformer that will be applied to every successful result of the method get called on the cache level. The object gets the key used for the get request (where it can apply its condition on) and the fetched value, and has to return the same type of the value.
     The transformation won't be applied when setting values on the cache level.
   
   - returns: A transformed CacheLevel that incorporates the post-processing step
   */
  public func conditionedPostProcess<T: ConditionedOneWayTransformer where T.KeyType == KeyType, T.TypeIn == OutputType, T.TypeOut == OutputType>(conditionedTransformer: T) -> BasicCache<KeyType, OutputType> {
    return BasicCache(
      getClosure: { key in
        self.get(key).mutate(key, conditionedTransformer: conditionedTransformer)
      },
      setClosure: self.set,
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}

/**
 Adds a conditioned post-processing step to the results of a fetch closure
 
 As usual, if the transformation fails, the fetch will also fail
 
 - parameter fetchClosure: The closure that will take care of fetching the values
 - parameter conditionedTransformer: The transformer that will be applied to every successful fetch. The transformer gets the key used for the request (where it can apply its condition on) and the fetched value, and has to return the same type of the value.
   The transformation won't be applied when setting values on the cache level, also considering fetch closures don't have a set operation.
 
 - returns: A CacheLevel that incorporates the post-processing step after the fetch
 */
public func ?>><A, B, T: ConditionedOneWayTransformer where T.KeyType == A, T.TypeIn == B, T.TypeOut == B>(fetchClosure: (key: A) -> Future<B>, conditionedTransformer: T) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(fetchClosure).conditionedPostProcess(conditionedTransformer)
}

/**
 Adds a conditioned post-processing step to the get results of a given CacheLevel
 
 As usual, if the transformation fails, the get request will also fail
 
 - parameter cache: The CacheLevel you want to apply the post-processing step to
 - parameter conditionedTransformer: The transformer that will be applied to every successful fetch. The transformer gets the key used for the request (where it can apply its condition on) and the fetched value, and has to return the same type of the value.
 The transformation won't be applied when setting values on the cache level, also considering fetch closures don't have a set operation.
 
 - returns: A transformed CacheLevel that incorporates the post-processing step
 */
public func ?>><A: CacheLevel, T: ConditionedOneWayTransformer where T.KeyType == A.KeyType, T.TypeIn == A.OutputType, T.TypeOut == A.OutputType>(cache: A, conditionedTransformer: T) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.conditionedPostProcess(conditionedTransformer)
}