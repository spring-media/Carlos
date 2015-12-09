import Foundation

infix operator ?>> { associativity left }

extension CacheLevel {
  
  /**
   Adds a conditioned post-processing step to the get results of this CacheLevel
   
   As usual, if the transformation fails, the get request will also fail
   
   - parameter conditionedTransformer: The transformation closure that will be applied to every successful result of the method get called on the cache level. The closure gets the key used for the get request (where it can apply its condition on) and the fetched value, and has to return the same type of the value.
     The transformation won't be applied when setting values on the cache level.
   
   - returns: A transformed CacheLevel that incorporates the post-processing step
   */
  public func conditionedPostProcess(conditionedTransformer: (key: KeyType, value: OutputType) -> Future<OutputType>) -> BasicCache<KeyType, OutputType> {
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
 - parameter conditionedTransformer: The transformation closure that will be applied to every successful fetch. The closure gets the key used for the request (where it can apply its condition on) and the fetched value, and has to return the same type of the value.
   The transformation won't be applied when setting values on the cache level, also considering fetch closures don't have a set operation.
 
 - returns: A CacheLevel that incorporates the post-processing step after the fetch
 */
public func ?>><A, B>(fetchClosure: (key: A) -> Future<B>, conditionedTransformerClosure: (key: A, value: B) -> Future<B>) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(fetchClosure).conditionedPostProcess(conditionedTransformerClosure)
}

/**
 Adds a conditioned post-processing step to the get results of a given CacheLevel
 
 As usual, if the transformation fails, the get request will also fail
 
 - parameter cache: The CacheLevel you want to apply the post-processing step to
 - parameter conditionedTransformer: The transformation closure that will be applied to every successful result of the method get called on the cache level. The closure gets the key used for the get request (where it can apply its condition on) and the fetched value, and has to return the same type of the value.
   The transformation won't be applied when setting values on the cache level.
 
 - returns: A transformed CacheLevel that incorporates the post-processing step
 */
public func ?>><A: CacheLevel>(cache: A, conditionedTransformerClosure: (key: A.KeyType, value: A.OutputType) -> Future<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.conditionedPostProcess(conditionedTransformerClosure)
}