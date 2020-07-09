import Foundation
import PiedPiper

extension CacheLevel {
  
  /**
  Adds a post-processing step to the get results of this CacheLevel
  
  As usual, if the transformation fails, the get request will also fail
  
  - parameter transformer: The OneWayTransformer that will be applied to every successful result of the method get called on the cache level. The transformer has to return the same type of the input type, and the transformation won't be applied when setting values on the cache level.
  
  - returns: A transformed CacheLevel that incorporates the post-processing step
  */
  public func postProcess<A: OneWayTransformer>(_ transformer: A) -> BasicCache<KeyType, OutputType> where OutputType == A.TypeIn, A.TypeIn == A.TypeOut {
    return BasicCache(
      getClosure: { key in
        self.get(key).mutate(transformer)
      },
      setClosure: self.set,
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}
