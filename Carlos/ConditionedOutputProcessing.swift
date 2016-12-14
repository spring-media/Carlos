import Foundation
import PiedPiper

extension Future {
  
  /**
   Mutates a future from a type A to a type B through a ConditionedOneWayTransformer
   
   - parameter key The key to use for the condition
   - parameter conditionedTransformer A ConditionedOneWayTransformer used to conditionally transform the values of the given Future
   
   - returns A new Future with the transformed value
   */
  internal func mutate<K, O, Transformer: ConditionedOneWayTransformer>(_ key: K, conditionedTransformer: Transformer) -> Future<O> where Transformer.KeyType == K, Transformer.TypeIn == T, Transformer.TypeOut == O {
    return flatMap { result in
      conditionedTransformer.conditionalTransform(key: key, value: result)
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
  public func conditionedPostProcess<T: ConditionedOneWayTransformer>(_ conditionedTransformer: T) -> BasicCache<KeyType, OutputType> where T.KeyType == KeyType, T.TypeIn == OutputType, T.TypeOut == OutputType {
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
