import Combine
import Foundation

extension CacheLevel {
  /**
   Applies a transformation to the cache level
   The transformation works by changing the type of the key the cache accepts
   Use this transformation when you use a domain specific key or a wrapper key that contains several values every cache level can choose from

   - parameter transformer: The transformation you want to apply

   - returns: A new cache level result of the transformation of the original cache level
   */
  public func transformKeys<A: OneWayTransformer>(_ transformer: A) -> BasicCache<A.TypeIn, OutputType> where KeyType == A.TypeOut {
    BasicCache(
      getClosure: { key in
        transformer.transform(key)
          .flatMap(self.get)
          .eraseToAnyPublisher()
      },
      setClosure: { value, key in
        transformer.transform(key)
          .flatMap { transformedKey in
            self.set(value, forKey: transformedKey)
          }
          .eraseToAnyPublisher()
      },
      removeClosure: { 
        transformer.transform($0)
          .flatMap(self.remove)
          .eraseToAnyPublisher()
      },
      clearClosure: clear,
      memoryClosure: onMemoryWarning
    )
  }
}
