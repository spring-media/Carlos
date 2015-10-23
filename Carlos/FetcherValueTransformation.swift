import Foundation

extension Fetcher {
  
  /**
   Applies a transformation to the fetcher
   The transformation works by changing the type of the value the fetcher returns when succeeding
   Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
   
   - parameter transformer: The transformation you want to apply
   
   - returns: A new fetcher result of the transformation of the original fetcher
   */
  public func transformValues<A: OneWayTransformer where OutputType == A.TypeIn>(transformer: A) -> BasicFetcher<KeyType, A.TypeOut> {
    return self =>> transformer
  }
  
  /**
   Applies a transformation to the fetcher
   The transformation works by changing the type of the value the fetcher returns when succeeding
   Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
   
   - parameter transformerClosure: The transformation closure you want to apply
   
   - returns: A new fetcher result of the transformation of the original fetcher
   */
  public func transformValues<A>(transformerClosure: OutputType -> Result<A>) -> BasicFetcher<KeyType, A> {
    return self =>> transformerClosure
  }
}

/**
 Applies a transformation to a fetch closure
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetchClosure: The fetcher closure you want to transform
 - parameter transformer: The transformation you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
public func transformValues<A, B: OneWayTransformer>(fetchClosure: (key: A) -> Result<B.TypeIn>, transformer: B) -> BasicFetcher<A, B.TypeOut> {
  return transformValues(wrapClosureIntoFetcher(fetchClosure), transformer: transformer)
}

/**
 Applies a transformation to a fetcher
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetcher: The fetcher you want to transform
 - parameter transformer: The transformation you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
public func transformValues<A: Fetcher, B: OneWayTransformer where A.OutputType == B.TypeIn>(fetcher: A, transformer: B) -> BasicFetcher<A.KeyType, B.TypeOut> {
  return BasicFetcher(
    getClosure: { key in
      return fetcher.get(key).mutate(transformer)
    }
  )
}

/**
 Applies a transformation to a fetch closure
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetchClosure: The fetcher closure you want to transform
 - parameter transformerClosure: The transformation closure you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
public func transformValues<A, B, C>(fetchClosure: (key: A) -> Result<B>, transformerClosure: B -> Result<C>) -> BasicFetcher<A, C> {
  return transformValues(wrapClosureIntoFetcher(fetchClosure), transformer: wrapClosureIntoOneWayTransformer(transformerClosure))
}

/**
 Applies a transformation to a fetcher
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetcher: The fetcher you want to transform
 - parameter transformerClosure: The transformation closure you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
public func transformValues<A: Fetcher, B>(fetcher: A, transformerClosure: A.OutputType -> Result<B>) -> BasicFetcher<A.KeyType, B> {
  return BasicFetcher(
    getClosure: { key in
      return fetcher.get(key).mutate(wrapClosureIntoOneWayTransformer(transformerClosure))
    }
  )
}

/**
 Applies a transformation to a fetch closure
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetchClosure: The fetch closure you want to transform
 - parameter transformer: The transformation you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
public func =>><A, B: OneWayTransformer>(fetchClosure: (key: A) -> Result<B.TypeIn>, transformer: B) -> BasicFetcher<A, B.TypeOut> {
  return transformValues(wrapClosureIntoFetcher(fetchClosure), transformer: transformer)
}

/**
 Applies a transformation to a fetcher
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetcher: The fetcher you want to transform
 - parameter transformer: The transformation you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
public func =>><A: Fetcher, B: OneWayTransformer where A.OutputType == B.TypeIn>(fetcher: A, transformer: B) -> BasicFetcher<A.KeyType, B.TypeOut> {
  return transformValues(fetcher, transformer: transformer)
}

/**
 Applies a transformation to a fetch closure
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetchClosure: The fetch closure you want to transform
 - parameter transformerClosure: The transformation closure you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
public func =>><A, B, C>(fetchClosure: (key: A) -> Result<B>, transformerClosure: B -> Result<C>) -> BasicFetcher<A, C> {
  return transformValues(wrapClosureIntoFetcher(fetchClosure), transformer: wrapClosureIntoOneWayTransformer(transformerClosure))
}

/**
 Applies a transformation to a fetcher
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetcher: The fetcher you want to transform
 - parameter transformerClosure: The transformation closure you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
public func =>><A: Fetcher, B>(fetcher: A, transformerClosure: A.OutputType -> Result<B>) -> BasicFetcher<A.KeyType, B> {
  return transformValues(fetcher, transformer: wrapClosureIntoOneWayTransformer(transformerClosure))
}