import Foundation
import PiedPiper

extension CacheLevel {
  /**
  Dispatches all the operations of this CacheLevel on the given GCD queue
   
  - parameter queue: The queue you want to dispatch all the operations (get, set, clear, onMemoryWarning) of this CacheLevel on
   
  - returns: A new CacheLevel that dispatches all the operations on the given GCD queue
  */
  public func dispatch(_ queue: DispatchQueue) -> BasicCache<KeyType, OutputType> {
    let gcd = GCD(queue: queue)
    
    return BasicCache(
      getClosure: { key in
        let result = Promise<OutputType>()
        
        gcd.async {
          result.mimic(self.get(key))
        }
        
        return result.future
      },
      setClosure: { (value, key) in
        let result = Promise<()>()
        
        gcd.async {
          result.mimic(self.set(value, forKey: key))
        }
        
        return result.future
      },
      clearClosure: {
        gcd.async(self.clear)
      },
      memoryClosure: {
        gcd.async(self.onMemoryWarning)
      }
    )
  }
}
