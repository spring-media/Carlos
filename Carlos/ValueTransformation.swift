import Foundation

/**
Mutates a CacheRequest from a type A to a type B through a OneWayTransformer

:param: origin The original CacheRequest
:param: transformer The OneWayTransformer from A to B

:returns: A new CacheRequest<B>
*/
internal func mutateCacheRequest<A, B: OneWayTransformer where A == B.TypeIn>(origin: CacheRequest<A>, transformer: B) -> CacheRequest<B.TypeOut> {
  let mutatedRequest = CacheRequest<B.TypeOut>()
  
  origin
    .onFailure({ mutatedRequest.fail($0) })
    .onSuccess({ mutatedRequest.succeed(transformer.transform($0)) })
  
  return mutatedRequest
}

/**
Mutates a CacheRequest from a type A to a type B through a OneWayTransformer

:param: origin The original CacheRequest
:param: transformerClosure The transformation closure from A to B

:returns: A new CacheRequest<B>
*/
internal func mutateCacheRequest<A, B>(origin: CacheRequest<A>, transformerClosure: A -> B) -> CacheRequest<B> {
  let mutatedRequest = CacheRequest<B>()
  let transformationBox = wrapClosureIntoOneWayTransformer(transformerClosure)
  
  origin
    .onFailure({ mutatedRequest.fail($0) })
    .onSuccess({ mutatedRequest.succeed(transformationBox.transform($0)) })
  
  return mutatedRequest
}

infix operator >>= { associativity left }

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

:param: fetchClosure The cache closure you want to transform
:param: transformer The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func transformValues<A, B, C: TwoWayTransformer where C.TypeIn == B>(fetchClosure: (key: A) -> CacheRequest<B>, transformer: C) -> BasicCache<A, C.TypeOut> {
  return transformValues(wrapClosureIntoCacheLevel(fetchClosure), transformer)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

:param: cache The cache level you want to transform
:param: transformer The transformation you want to apply

:returns: A new cache result of the transformation of the original cache
*/
public func transformValues<A: CacheLevel, B: TwoWayTransformer where A.OutputType == B.TypeIn>(cache: A, transformer: B) -> BasicCache<A.KeyType, B.TypeOut> {
  return BasicCache<A.KeyType, B.TypeOut>(
    getClosure: { key in
      return mutateCacheRequest(cache.get(key), transformer)
    }, setClosure: { (key, value) in
      cache.set(transformer.inverseTransform(value), forKey: key)
    }, clearClosure: {
      cache.clear()
    }, memoryClosure: {
      cache.onMemoryWarning()
    }
  )
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

:param: fetchClosure The cache closure you want to transform
:param: transformer The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func >>=<A, B, C: TwoWayTransformer where C.TypeIn == B>(fetchClosure: (key: A) -> CacheRequest<B>, transformer: C) -> BasicCache<A, C.TypeOut> {
  return transformValues(wrapClosureIntoCacheLevel(fetchClosure), transformer)
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the value the cache returns when succeeding
Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types

:param: cache The cache level you want to transform
:param: transformer The transformation you want to apply

:returns: A new cache result of the transformation of the original cache
*/
public func >>=<A: CacheLevel, B: TwoWayTransformer where A.OutputType == B.TypeIn>(cache: A, transformer: B) -> BasicCache<A.KeyType, B.TypeOut> {
  return transformValues(cache, transformer)
}
