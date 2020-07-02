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
  public func transformValues<A: OneWayTransformer>(_ transformer: A) -> BasicFetcher<KeyType, A.TypeOut> where OutputType == A.TypeIn {
    return BasicFetcher(
      getClosure: { key in
        return self.get(key).mutate(transformer)
      }
    )
  }
}
