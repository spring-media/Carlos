import Foundation
import PiedPiper

extension CacheLevel {
  
  /**
  Applies a transformation to the cache level
  The transformation works by changing the type of the key the cache accepts
  Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from
  
  - parameter transformer: The transformation you want to apply
  
  - returns: A new cache level result of the transformation of the original cache level
  */
  public func transformKeys<A: OneWayTransformer where KeyType == A.TypeOut>(transformer: A) -> BasicCache<A.TypeIn, OutputType> {
    return BasicCache(
      getClosure: { key in
        let result = Promise<OutputType>()
        
        transformer.transform(key)
          .onSuccess { transformedKey in
            result.mimic(self.get(transformedKey))
          }
          .onFailure(result.fail)
          .onCancel(result.cancel)
        
        return result.future
      },
      setClosure: { (value, key) in
        transformer.transform(key)
          .onSuccess { transformedKey in
            self.set(value, forKey: transformedKey)
        }
      },
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
  
  /**
  Applies a transformation to the cache level
  The transformation works by changing the type of the key the cache accepts
  Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from
  
  - parameter transformerClosure: The transformation closure you want to apply
  
  - returns: A new cache level result of the transformation of the original cache level
   */
  @available(*, deprecated=0.7)
  public func transformKeys<A>(transformerClosure: A -> Future<KeyType>) -> BasicCache<A, OutputType> {
    return self.transformKeys(wrapClosureIntoOneWayTransformer(transformerClosure))
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
@available(*, deprecated=0.5)
public func transformKeys<A, B: OneWayTransformer>(transformer: B, fetchClosure: (key: B.TypeOut) -> Future<A>) -> BasicCache<B.TypeIn, A> {
  return wrapClosureIntoFetcher(fetchClosure).transformKeys(transformer)
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter fetchClosure: The cache closure you want to transform
- parameter transformerClosure: The transformation closure you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
@available(*, deprecated=0.5)
public func transformKeys<A, B, C>(transformerClosure: C -> Future<A>, fetchClosure: (key: A) -> Future<B>) -> BasicCache<C, B> {
  return wrapClosureIntoFetcher(fetchClosure).transformKeys(transformerClosure)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter cache: The cache level you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
@available(*, deprecated=0.5)
public func transformKeys<A: CacheLevel, B: OneWayTransformer where A.KeyType == B.TypeOut>(transformer: B, cache: A) -> BasicCache<B.TypeIn, A.OutputType> {
  return cache.transformKeys(transformer)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter cache: The cache level you want to transform
- parameter transformerClosure: The transformation closure you want to apply

- returns: A new cache level result of the transformation of the original cache level
*/
@available(*, deprecated=0.5)
public func transformKeys<A: CacheLevel, B>(transformerClosure: B -> Future<A.KeyType>, cache: A) -> BasicCache<B, A.OutputType> {
  return cache.transformKeys(transformerClosure)
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter fetchClosure: The cache closure you want to transform
- parameter transformer: The transformation you want to apply

- returns: A new cache level result of the transformation of the original cache level
 */
@available(*, deprecated=0.7)
public func =>><A, B: OneWayTransformer>(transformer: B, fetchClosure: (key: B.TypeOut) -> Future<A>) -> BasicCache<B.TypeIn, A> {
  return wrapClosureIntoFetcher(fetchClosure).transformKeys(transformer)
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter fetchClosure: The cache closure you want to transform
- parameter transformerClosure: The transformation closure you want to apply

- returns: A new cache level result of the transformation of the original cache level
 */
@available(*, deprecated=0.7)
public func =>><A, B, C>(transformerClosure: C -> Future<A>, fetchClosure: (key: A) -> Future<B>) -> BasicCache<C, B> {
  return wrapClosureIntoFetcher(fetchClosure).transformKeys(transformerClosure)
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
  return cache.transformKeys(transformer)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

- parameter cache: The cache level you want to transform
- parameter transformerClosure: The transformation closure you want to apply

- returns: A new cache level result of the transformation of the original cache level
 */
@available(*, deprecated=0.7)
public func =>><A: CacheLevel, B>(transformerClosure: B -> Future<A.KeyType>, cache: A) -> BasicCache<B, A.OutputType> {
  return cache.transformKeys(transformerClosure)
}
