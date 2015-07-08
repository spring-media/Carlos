//
//  TwoWayTransformer.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 07/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

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

public func mutateCacheRequest<A, B: TwoWayTransformer where A == B.TypeIn>(origin: CacheRequest<A>, transformer: B) -> CacheRequest<B.TypeOut> {
  let mutatedRequest = CacheRequest<B.TypeOut>()
  
  origin
    .onFailure({ mutatedRequest.fail($0) })
    .onSuccess({ mutatedRequest.succeed(transformer.forwardTransform($0)) })
  
  return mutatedRequest
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

infix operator =>> { associativity left }

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

:param: fetchClosure The cache closure you want to transform
:param: transformer The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func transformKeys<A, B, C: OneWayTransformer where C.TypeOut == A>(transformer: C, fetchClosure: (key: A) -> CacheRequest<B>) -> BasicCache<C.TypeIn, B> {
  return transformKeys(transformer, wrapClosureIntoCacheLevel(fetchClosure))
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

:param: cache The cache level you want to transform
:param: transformer The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func transformKeys<A: CacheLevel, B: OneWayTransformer where A.KeyType == B.TypeOut>(transformer: B, cache: A) -> BasicCache<B.TypeIn, A.OutputType> {
  return BasicCache<B.TypeIn, A.OutputType>(
    getClosure: { key in
      return cache.get(transformer.transform(key))
    }, setClosure: { (key, value) in
      cache.set(value, forKey: transformer.transform(key))
    }, clearClosure: {
      cache.clear()
    }, memoryClosure: {
      cache.onMemoryWarning()
    }
  )
}

/**
Applies a transformation to a cache closure
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

:param: fetchClosure The cache closure you want to transform
:param: transformer The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func =>><A, B, C: OneWayTransformer where C.TypeOut == A>(transformer: C, fetchClosure: (key: A) -> CacheRequest<B>) -> BasicCache<C.TypeIn, B> {
  return transformKeys(transformer, wrapClosureIntoCacheLevel(fetchClosure))
}

/**
Applies a transformation to a cache level
The transformation works by changing the type of the key the cache accepts
Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

:param: cache The cache level you want to transform
:param: transformer The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func =>><A: CacheLevel, B: OneWayTransformer where A.KeyType == B.TypeOut>(transformer: B, cache: A) -> BasicCache<B.TypeIn, A.OutputType> {
  return transformKeys(transformer, cache)
}
