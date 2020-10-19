import Foundation
import Combine

extension CacheLevel {
  /**
  Applies a transformation to the cache level
  The transformation works by changing the type of the value the cache returns when succeeding
  Use this transformation when you store a value type but want to mount the cache in a pipeline that works with other value types
  
  - parameter transformer: The transformation you want to apply
  
  - returns: A new cache result of the transformation of the original cache
  */
  public func transformValues<A: TwoWayTransformer>(_ transformer: A) -> BasicCache<KeyType, A.TypeOut> where OutputType == A.TypeIn {
    return BasicCache(
      getClosure: { key in
        return self.get(key)
          .flatMap(transformer.transform)
          .eraseToAnyPublisher()
      },
      setClosure: { (value, key) in
        return transformer.inverseTransform(value)
          .flatMap { transformedValue in
            self.set(transformedValue, forKey: key)
          }
          .eraseToAnyPublisher()
      },
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}
