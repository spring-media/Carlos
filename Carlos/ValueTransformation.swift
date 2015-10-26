import Foundation

extension Result {
  
  /**
  Mutates a Result from a type A to a type B through a OneWayTransformer

  - parameter origin: The original Result
  - parameter transformer: The OneWayTransformer from A to B

  - returns: A new Result<B>
  */
  internal func mutate<A: OneWayTransformer where A.TypeIn == T>(transformer: A) -> Result<A.TypeOut> {
    let mutatedRequest = Result<A.TypeOut>()
    
    self
      .onFailure(mutatedRequest.fail)
      .onSuccess { result in
        mutatedRequest.mimic(transformer.transform(result))
      }
    
    return mutatedRequest
  }

  /**
  Mutates a Result from a type A to a type B through a OneWayTransformer

  - parameter origin: The original Result
  - parameter transformerClosure: The transformation closure from A to B

  - returns: A new Result<B>
  */
  internal func mutate<A>(transformerClosure: T -> Result<A>) -> Result<A> {
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
    return BasicCache(
      getClosure: { key in
        return self.get(key).mutate(transformer)
      },
      setClosure: { (value, key) in
        transformer.inverseTransform(value)
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
Applies a transformation to a cache level
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

- parameter cache: The cache level you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache result of the transformation of the original cache
*/
@available(*, deprecated=0.5)
public func transformValues<A: CacheLevel, B: TwoWayTransformer where A.OutputType == B.TypeIn>(cache: A, transformer: B) -> BasicCache<A.KeyType, B.TypeOut> {
  return cache.transformValues(transformer)
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
  return cache.transformValues(transformer)
}
