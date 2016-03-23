import Foundation
import PiedPiper

extension Fetcher {
  
  /**
   Applies a transformation to the fetcher
   The transformation works by changing the type of the value the fetcher returns when succeeding
   Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
   
   - parameter transformer: The transformation you want to apply
   
   - returns: A new fetcher result of the transformation of the original fetcher
   */
  public func transformValues<A: OneWayTransformer where OutputType == A.TypeIn>(transformer: A) -> BasicFetcher<KeyType, A.TypeOut> {
    return BasicFetcher(
      getClosure: { key in
        return self.get(key).mutate(transformer)
      }
    )
  }
  
  /**
   Applies a transformation to the fetcher
   The transformation works by changing the type of the value the fetcher returns when succeeding
   Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
   
   - parameter transformerClosure: The transformation closure you want to apply
   
   - returns: A new fetcher result of the transformation of the original fetcher
   */
  @available(*, deprecated=0.7)
  public func transformValues<A>(transformerClosure: OutputType -> Future<A>) -> BasicFetcher<KeyType, A> {
    return self.transformValues(wrapClosureIntoOneWayTransformer(transformerClosure))
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
@available(*, deprecated=0.5)
public func transformValues<A, B: OneWayTransformer>(fetchClosure: (key: A) -> Future<B.TypeIn>, transformer: B) -> BasicFetcher<A, B.TypeOut> {
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
@available(*, deprecated=0.5)
public func transformValues<A: Fetcher, B: OneWayTransformer where A.OutputType == B.TypeIn>(fetcher: A, transformer: B) -> BasicFetcher<A.KeyType, B.TypeOut> {
  return fetcher.transformValues(transformer)
}

/**
 Applies a transformation to a fetch closure
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetchClosure: The fetcher closure you want to transform
 - parameter transformerClosure: The transformation closure you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
@available(*, deprecated=0.5)
public func transformValues<A, B, C>(fetchClosure: (key: A) -> Future<B>, transformerClosure: B -> Future<C>) -> BasicFetcher<A, C> {
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
@available(*, deprecated=0.5)
public func transformValues<A: Fetcher, B>(fetcher: A, transformerClosure: A.OutputType -> Future<B>) -> BasicFetcher<A.KeyType, B> {
  return fetcher.transformValues(transformerClosure)
}

/**
 Applies a transformation to a fetch closure
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetchClosure: The fetch closure you want to transform
 - parameter transformer: The transformation you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
@available(*, deprecated=0.7)
public func =>><A, B: OneWayTransformer>(fetchClosure: (key: A) -> Future<B.TypeIn>, transformer: B) -> BasicFetcher<A, B.TypeOut> {
  return wrapClosureIntoFetcher(fetchClosure).transformValues(transformer)
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
  return fetcher.transformValues(transformer)
}

/**
 Applies a transformation to a fetch closure
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetchClosure: The fetch closure you want to transform
 - parameter transformerClosure: The transformation closure you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
@available(*, deprecated=0.7)
public func =>><A, B, C>(fetchClosure: (key: A) -> Future<B>, transformerClosure: B -> Future<C>) -> BasicFetcher<A, C> {
  return wrapClosureIntoFetcher(fetchClosure).transformValues(wrapClosureIntoOneWayTransformer(transformerClosure))
}

/**
 Applies a transformation to a fetcher
 The transformation works by changing the type of the value the fetcher returns when succeeding
 Use this transformation when you store a value type but want to mount the fetcher in a pipeline that works with other value types
 
 - parameter fetcher: The fetcher you want to transform
 - parameter transformerClosure: The transformation closure you want to apply
 
 - returns: A new fetcher result of the transformation of the original fetcher
 */
@available(*, deprecated=0.7)
public func =>><A: Fetcher, B>(fetcher: A, transformerClosure: A.OutputType -> Future<B>) -> BasicFetcher<A.KeyType, B> {
  return fetcher.transformValues(wrapClosureIntoOneWayTransformer(transformerClosure))
}