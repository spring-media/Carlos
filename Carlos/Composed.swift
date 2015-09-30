import Foundation

infix operator >>> { associativity left }

/**
Composes two cache closures

- parameter firstFetcher: The first cache closure
- parameter secondFetcher: The second cache closure

- returns: A new cache level that is the result of the composition of the two cache closures
*/
public func compose<A, B>(firstFetcher: (key: A) -> CacheRequest<B>, secondFetcher: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return wrapClosureIntoCacheLevel(firstFetcher) >>> wrapClosureIntoCacheLevel(secondFetcher)
}

extension CacheLevel {
  
  /**
  Composes two cache levels
  
  - parameter cache: The second cache level
  
  - returns: A new cache level that is the result of the composition of the two cache levels
  */
  public func compose<A: CacheLevel where A.KeyType == KeyType, A.OutputType == OutputType>(cache: A) -> BasicCache<A.KeyType, A.OutputType> {
    return self >>> cache
  }
  
  /**
  Composes the cache level with a cache closure
  
  - parameter fetchClosure: The cache closure
  
  - returns: A new cache level that is the result of the composition of the cache level with the cache closure
  */
  public func compose(fetchClosure: (key: KeyType) -> CacheRequest<OutputType>) -> BasicCache<KeyType, OutputType> {
    return self >>> wrapClosureIntoCacheLevel(fetchClosure)
  }
}

/**
Composes two cache levels

- parameter firstCache: The first cache level
- parameter secondCache: The second cache level

- returns: A new cache level that is the result of the composition of the two cache levels
*/
public func compose<A: CacheLevel, B: CacheLevel where A.KeyType == B.KeyType, A.OutputType == B.OutputType>(firstCache: A, secondCache: B) -> BasicCache<A.KeyType, A.OutputType> {
  return BasicCache(
    getClosure: { key in
      let request = CacheRequest<A.OutputType>()
      
      firstCache.get(key)
        .onSuccess { result in
          request.succeed(result)
        }
        .onFailure { error in
          secondCache.get(key)
            .onSuccess { result in
              request.succeed(result)
              firstCache.set(result, forKey: key)
            }
            .onFailure{ error in
              request.fail(error)
            }
        }
      
      return request
    },
    setClosure: { (value, key) in
      firstCache.set(value, forKey: key)
      secondCache.set(value, forKey: key)
    },
    clearClosure: {
      firstCache.clear()
      secondCache.clear()
    },
    memoryClosure: {
      firstCache.onMemoryWarning()
      secondCache.onMemoryWarning()
    }
  )
}

/**
Composes a cache level with a cache closure

- parameter cache: The cache level
- parameter fetchClosure: The cache closure

- returns: A new cache level that is the result of the composition of the cache level with the cache closure
*/
public func compose<A: CacheLevel>(cache: A, fetchClosure: (key: A.KeyType) -> CacheRequest<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return cache >>> wrapClosureIntoCacheLevel(fetchClosure)
}

/**
Composes a cache closure with a cache level

- parameter fetchClosure: The cache closure
- parameter cache: The cache level

- returns: A new cache level that is the result of the composition of the cache closure with the cache level
*/
public func compose<A: CacheLevel>(fetchClosure: (key: A.KeyType) -> CacheRequest<A.OutputType>, cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return wrapClosureIntoCacheLevel(fetchClosure) >>> cache
}

/**
Composes two cache closures

- parameter firstFetcher: The first cache closure
- parameter secondFetcher: The second cache closure

- returns: A new cache level that is the result of the composition of the two cache closures
*/
public func >>><A, B>(firstFetcher: (key: A) -> CacheRequest<B>, secondFetcher: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return compose(firstFetcher, secondFetcher: secondFetcher)
}

/**
Composes two cache levels

- parameter firstCache: The first cache level
- parameter secondCache: The second cache level

- returns: A new cache level that is the result of the composition of the two cache levels
*/
public func >>><A: CacheLevel, B: CacheLevel where A.KeyType == B.KeyType, A.OutputType == B.OutputType>(firstCache: A, secondCache: B) -> BasicCache<A.KeyType, A.OutputType> {
  return compose(firstCache, secondCache: secondCache)
}

/**
Composes a cache level with a cache closure

- parameter cache: The cache level
- parameter fetchClosure: The cache closure

- returns: A new cache level that is the result of the composition of the cache level with the cache closure
*/
public func >>><A: CacheLevel>(cache: A, fetchClosure: (key: A.KeyType) -> CacheRequest<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return compose(cache, secondCache: wrapClosureIntoCacheLevel(fetchClosure))
}

/**
Composes a cache closure with a cache level

- parameter fetchClosure: The cache closure
- parameter cache: The cache level

- returns: A new cache level that is the result of the composition of the cache closure with the cache level
*/
public func >>><A: CacheLevel>(fetchClosure: (key: A.KeyType) -> CacheRequest<A.OutputType>, cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return compose(wrapClosureIntoCacheLevel(fetchClosure), secondCache: cache)
}