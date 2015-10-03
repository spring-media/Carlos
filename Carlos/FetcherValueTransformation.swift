import Foundation

extension Fetcher {
  public func transformValues<A: OneWayTransformer where OutputType == A.TypeIn>(transformer: A) -> BasicFetcher<KeyType, A.TypeOut> {
    return self =>> transformer
  }
}

public func transformValues<A, B: OneWayTransformer>(fetchClosure: (key: A) -> CacheRequest<B.TypeIn>, transformer: B) -> BasicFetcher<A, B.TypeOut> {
  return transformValues(wrapClosureIntoFetcher(fetchClosure), transformer: transformer)
}

public func transformValues<A: CacheLevel, B: OneWayTransformer where A.OutputType == B.TypeIn>(cache: A, transformer: B) -> BasicFetcher<A.KeyType, B.TypeOut> {
  return BasicFetcher(
    getClosure: { key in
      return cache.get(key).mutate(transformer)
    }
  )
}

public func =>><A, B: OneWayTransformer>(fetchClosure: (key: A) -> CacheRequest<B.TypeIn>, transformer: B) -> BasicFetcher<A, B.TypeOut> {
  return transformValues(wrapClosureIntoFetcher(fetchClosure), transformer: transformer)
}

public func =>><A: CacheLevel, B: OneWayTransformer where A.OutputType == B.TypeIn>(cache: A, transformer: B) -> BasicFetcher<A.KeyType, B.TypeOut> {
  return transformValues(cache, transformer: transformer)
}