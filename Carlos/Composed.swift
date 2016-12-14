import Foundation
import PiedPiper

extension CacheLevel {
  
  /**
  Composes two cache levels
  
  - parameter cache: The second cache level
  
  - returns: A new cache level that is the result of the composition of the two cache levels
  */
  public func compose<A: CacheLevel>(_ cache: A) -> BasicCache<A.KeyType, A.OutputType> where A.KeyType == KeyType, A.OutputType == OutputType {
    return BasicCache(
      getClosure: { key in
        let request = Promise<A.OutputType>()
        
        self.get(key)
          .onSuccess(request.succeed)
          .onCancel(request.cancel)
          .onFailure { error in
            request.mimic(cache.get(key).map { result in
              self.set(result, forKey: key)
              return result
            })
        }
        
        return request.future
      },
      setClosure: { (value, key) in
        let firstWrite = self.set(value, forKey: key)
        let secondWrite = cache.set(value, forKey: key)
        
        return firstWrite.flatMap { secondWrite }
      },
      clearClosure: {
        self.clear()
        cache.clear()
      },
      memoryClosure: {
        self.onMemoryWarning()
        cache.onMemoryWarning()
      }
    )
  }
}
