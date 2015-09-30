import Foundation

extension CacheRequest {
  
  /**
  Mutates a CacheRequest from a type A to a type B through a OneWayTransformer

  - parameter origin: The original CacheRequest
  - parameter transformer: The OneWayTransformer from A to B

  - returns: A new CacheRequest<B>
  */
  internal func mutate<A: OneWayTransformer where A.TypeIn == T>(transformer: A) -> CacheRequest<A.TypeOut> {
    let mutatedRequest = CacheRequest<A.TypeOut>()
    
    self
      .onFailure({
        mutatedRequest.fail($0)
      })
      .onSuccess({
        if let transformedValue = transformer.transform($0) {
          mutatedRequest.succeed(transformedValue)
        } else {
          mutatedRequest.fail(FetchError.ValueTransformationFailed)
        }
      })
    
    return mutatedRequest
  }

  /**
  Mutates a CacheRequest from a type A to a type B through a OneWayTransformer

  - parameter origin: The original CacheRequest
  - parameter transformerClosure: The transformation closure from A to B

  - returns: A new CacheRequest<B>
  */
  internal func mutate<A>(transformerClosure: T -> A?) -> CacheRequest<A> {
    return self.mutate(wrapClosureIntoOneWayTransformer(transformerClosure))
  }
}

extension CacheLevel {
  
  /**
  Applies a transformation to the cache level
  The transformation works by changing the type of the value the cache returns when succeeding
  Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types
  
  - parameter transformer: The transformation you want to apply
  
  - returns: A new cache result of the transformation of the original cache
  */
  public func transformValues<A: TwoWayTransformer where OutputType == A.TypeIn>(transformer: A) -> BasicCache<KeyType, A.TypeOut> {
    return self =>> transformer
  }
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

- parameter fetchClosure: The cache closure you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func transformValues<A, B: TwoWayTransformer>(fetchClosure: (key: A) -> CacheRequest<B.TypeIn>, transformer: B) -> BasicCache<A, B.TypeOut> {
  return transformValues(wrapClosureIntoCacheLevel(fetchClosure), transformer: transformer)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

- parameter cache: The cache level you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache result of the transformation of the original cache
*/
public func transformValues<A: CacheLevel, B: TwoWayTransformer where A.OutputType == B.TypeIn>(cache: A, transformer: B) -> BasicCache<A.KeyType, B.TypeOut> {
  return BasicCache(
    getClosure: { key in
      return cache.get(key).mutate(transformer)
    },
    setClosure: { (value, key) in
      if let transformedValue = transformer.inverseTransform(value) {
        cache.set(transformedValue, forKey: key)
      }
    },
    clearClosure: cache.clear,
    memoryClosure: cache.onMemoryWarning
  )
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

- parameter fetchClosure: The cache closure you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func =>><A, B: TwoWayTransformer>(fetchClosure: (key: A) -> CacheRequest<B.TypeIn>, transformer: B) -> BasicCache<A, B.TypeOut> {
  return transformValues(wrapClosureIntoCacheLevel(fetchClosure), transformer: transformer)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

- parameter cache: The cache level you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache result of the transformation of the original cache
*/
public func =>><A: CacheLevel, B: TwoWayTransformer where A.OutputType == B.TypeIn>(cache: A, transformer: B) -> BasicCache<A.KeyType, B.TypeOut> {
  return transformValues(cache, transformer: transformer)
}
