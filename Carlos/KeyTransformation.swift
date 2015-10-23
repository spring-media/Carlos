import Foundation

extension CacheLevel {
  
  /**
  Applies a transformation to the cache level
  The transformation works by changing the type of the key the cache accepts
  Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from
  
  - parameter transformer: The transformation you want to apply
  
  - returns: A new cache level result of the transformation of the original cache level
  */
  public func transformKeys<A: OneWayTransformer where KeyType == A.TypeOut>(transformer: A) -> BasicCache<A.TypeIn, OutputType> {
    return transformer =>> self
  }
  
  /**
  Applies a transformation to the cache level
  The transformation works by changing the type of the key the cache accepts
  Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from
  
  - parameter transformerClosure: The transformation closure you want to apply
  
  - returns: A new cache level result of the transformation of the original cache level
  */
  public func transformKeys<A>(transformerClosure: A -> Result<KeyType>) -> BasicCache<A, OutputType> {
    return transformerClosure =>> self
  }
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter fetchClosure: The cache closure you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func transformKeys<A, B: OneWayTransformer>(transformer: B, fetchClosure: (key: B.TypeOut) -> Result<A>) -> BasicCache<B.TypeIn, A> {
  return transformKeys(transformer, cache: wrapClosureIntoFetcher(fetchClosure))
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter fetchClosure: The cache closure you want to transform
- parameter transformerClosure: The transformation closure you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func transformKeys<A, B, C>(transformerClosure: C -> Result<A>, fetchClosure: (key: A) -> Result<B>) -> BasicCache<C, B> {
  return transformKeys(wrapClosureIntoOneWayTransformer(transformerClosure), cache: wrapClosureIntoFetcher(fetchClosure))
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter cache: The cache level you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func transformKeys<A: CacheLevel, B: OneWayTransformer where A.KeyType == B.TypeOut>(transformer: B, cache: A) -> BasicCache<B.TypeIn, A.OutputType> {
  return BasicCache(
    getClosure: { key in
      let result = Result<A.OutputType>()
      
      transformer.transform(key)
        .onSuccess { transformedKey in
          result.mimic(cache.get(transformedKey))
        }
        .onFailure(result.fail)
      
      return result
    },
    setClosure: { (value, key) in
      transformer.transform(key)
        .onSuccess { transformedKey in
          cache.set(value, forKey: transformedKey)
        }
    },
    clearClosure: cache.clear,
    memoryClosure: cache.onMemoryWarning
  )
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter cache: The cache level you want to transform
- parameter transformerClosure: The transformation closure you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func transformKeys<A: CacheLevel, B>(transformerClosure: B -> Result<A.KeyType>, cache: A) -> BasicCache<B, A.OutputType> {
  return transformKeys(wrapClosureIntoOneWayTransformer(transformerClosure), cache: cache)
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter fetchClosure: The cache closure you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func =>><A, B: OneWayTransformer>(transformer: B, fetchClosure: (key: B.TypeOut) -> Result<A>) -> BasicCache<B.TypeIn, A> {
  return transformKeys(transformer, cache: wrapClosureIntoFetcher(fetchClosure))
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter fetchClosure: The cache closure you want to transform
- parameter transformerClosure: The transformation closure you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func =>><A, B, C>(transformerClosure: C -> Result<A>, fetchClosure: (key: A) -> Result<B>) -> BasicCache<C, B> {
  return transformKeys(wrapClosureIntoOneWayTransformer(transformerClosure), cache: wrapClosureIntoFetcher(fetchClosure))
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter cache: The cache level you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func =>><A: CacheLevel, B: OneWayTransformer where A.KeyType == B.TypeOut>(transformer: B, cache: A) -> BasicCache<B.TypeIn, A.OutputType> {
  return transformKeys(transformer, cache: cache)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter cache: The cache level you want to transform
- parameter transformerClosure: The transformation closure you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
public func =>><A: CacheLevel, B>(transformerClosure: B -> Result<A.KeyType>, cache: A) -> BasicCache<B, A.OutputType> {
  return transformKeys(wrapClosureIntoOneWayTransformer(transformerClosure), cache: cache)
}
