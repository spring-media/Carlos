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
  public func transformKeys<A: OneWayTransformer>(_ transformer: A) -> BasicCache<A.TypeIn, OutputType> where KeyType == A.TypeOut {
    return BasicCache(
      getClosure: { key in
        transformer.transform(key).flatMap(self.get)
      },
      setClosure: { (value, key) in
        return transformer.transform(key).flatMap { transformedKey in
          self.set(value, forKey: transformedKey)
        }
      },
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}
