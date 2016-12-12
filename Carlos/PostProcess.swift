import Foundation
import PiedPiper

infix operator ~>> { associativity left }

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
  
  /**
  Adds a post-processing step to the get results of this CacheLevel
  
  As usual, if the transformation fails, the get request will also fail
  
  - parameter transformerClosure: The transformation closure that will be applied to every successful result of the method get called on the cache level. The closure has to return the same type of the input type, and the transformation won't be applied when setting values on the cache level.
  
  - returns: A transformed CacheLevel that incorporates the post-processing step
   */
  @available(*, deprecated: 0.7)
  public func postProcess(_ transformerClosure: (OutputType) -> Future<OutputType>) -> BasicCache<KeyType, OutputType> {
    return self.postProcess(wrapClosureIntoOneWayTransformer(transformerClosure))
  }
}

/**
Adds a post-processing step to the get results of a fetch closure

As usual, if the transformation fails, the get request will also fail

- parameter fetchClosure: The fetch closure you want to decorate
- parameter transformer: The OneWayTransformer that will be applied to every successful result of the fetch closure. The transformer has to return the same type of the input type

- returns: A CacheLevel that incorporates the post-processing step
*/
@available(*, deprecated: 0.5)
public func postProcess<A, B: OneWayTransformer>(_ fetchClosure: (_ key: A) -> Future<B.TypeIn>, transformer: B) -> BasicCache<A, B.TypeOut> where B.TypeIn == B.TypeOut {
  return wrapClosureIntoFetcher(fetchClosure).postProcess(transformer)
}

/**
Adds a post-processing step to the get results of a fetch closure

As usual, if the transformation fails, the get request will also fail

- parameter fetchClosure: The fetch closure you want to decorate
- parameter transformerClosure: The transformation closure that will be applied to every successful result of the fetch closure. The transformation closure has to return the same type of the input type

- returns: A CacheLevel that incorporates the post-processing step
*/
@available(*, deprecated: 0.5)
public func postProcess<A, B>(_ fetchClosure: (_ key: A) -> Future<B>, transformerClosure: (B) -> Future<B>) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(fetchClosure).postProcess(wrapClosureIntoOneWayTransformer(transformerClosure))
}

/**
Adds a post-processing step to the get results of a CacheLevel

As usual, if the transformation fails, the get request will also fail

- parameter cache: The CacheLevel you want to decorate
- parameter transformer: The OneWayTransformer that will be applied to every successful result of the CacheLevel. The transformer has to return the same type of the input type, and the transformation won't be applied when setting values on the cache level.

- returns: A transformed CacheLevel that incorporates the post-processing step
*/
@available(*, deprecated: 0.5)
public func postProcess<A: CacheLevel, B: OneWayTransformer>(_ cache: A, transformer: B) -> BasicCache<A.KeyType, A.OutputType> where A.OutputType == B.TypeIn, B.TypeIn == B.TypeOut {
  return cache.postProcess(transformer)
}

/**
Adds a post-processing step to the get results of a CacheLevel

As usual, if the transformation fails, the get request will also fail

- parameter cache: The CacheLevel you want to decorate
- parameter transformerClosure: The transformation closure that will be applied to every successful result of the method get called on the cache level. The closure has to return the same type of the input type, and the transformation won't be applied when setting values on the cache level.

- returns: A transformed CacheLevel that incorporates the post-processing step
*/
@available(*, deprecated: 0.5)
public func postProcess<A: CacheLevel>(_ cache: A, transformerClosure: (A.OutputType) -> Future<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.postProcess(wrapClosureIntoOneWayTransformer(transformerClosure))
}

/**
Adds a post-processing step to the get results of a fetch closure

As usual, if the transformation fails, the get request will also fail

- parameter fetchClosure: The fetch closure you want to decorate
- parameter transformer: The OneWayTransformer that will be applied to every successful result of the fetch closure. The transformer has to return the same type of the input type

- returns: A CacheLevel that incorporates the post-processing step
 */
@available(*, deprecated: 0.7)
public func ~>><A, B: OneWayTransformer>(fetchClosure: (_ key: A) -> Future<B.TypeIn>, transformer: B) -> BasicCache<A, B.TypeOut> where B.TypeIn == B.TypeOut {
  return wrapClosureIntoFetcher(fetchClosure).postProcess(transformer)
}

/**
Adds a post-processing step to the get results of a fetch closure

As usual, if the transformation fails, the get request will also fail

- parameter fetchClosure: The fetch closure you want to decorate
- parameter transformerClosure: The transformation closure that will be applied to every successful result of the fetch closure. The transformation closure has to return the same type of the input type

- returns: A CacheLevel that incorporates the post-processing step
 */
@available(*, deprecated: 0.7)
public func ~>><A, B>(fetchClosure: (_ key: A) -> Future<B>, transformerClosure: (B) -> Future<B>) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(fetchClosure).postProcess(wrapClosureIntoOneWayTransformer(transformerClosure))
}

/**
Adds a post-processing step to the get results of a CacheLevel

As usual, if the transformation fails, the get request will also fail

- parameter cache: The CacheLevel you want to decorate
- parameter transformer: The OneWayTransformer that will be applied to every successful result of the CacheLevel. The transformer has to return the same type of the input type, and the transformation won't be applied when setting values on the cache level.

- returns: A transformed CacheLevel that incorporates the post-processing step
*/
public func ~>><A: CacheLevel, B: OneWayTransformer>(cache: A, transformer: B) -> BasicCache<A.KeyType, A.OutputType> where A.OutputType == B.TypeIn, B.TypeIn == B.TypeOut {
  return cache.postProcess(transformer)
}

/**
Adds a post-processing step to the get results of a CacheLevel

As usual, if the transformation fails, the get request will also fail

- parameter cache: The CacheLevel you want to decorate
- parameter transformerClosure: The transformation closure that will be applied to every successful result of the method get called on the cache level. The closure has to return the same type of the input type, and the transformation won't be applied when setting values on the cache level.

- returns: A transformed CacheLevel that incorporates the post-processing step
 */
@available(*, deprecated: 0.7)
public func ~>><A: CacheLevel>(cache: A, transformerClosure: (A.OutputType) -> Future<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.postProcess(wrapClosureIntoOneWayTransformer(transformerClosure))
}
