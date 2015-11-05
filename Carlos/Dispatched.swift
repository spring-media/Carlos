import Foundation

//TODO: Expose and use GCDQueue

infix operator ~>> { }

extension CacheLevel {
  /**
  Dispatches all the operations of this CacheLevel on the given GCD queue
   
  - parameter queue: The queue you want to dispatch all the operations (get, set, clear, onMemoryWarning) of this CacheLevel on
   
  - returns: A new CacheLevel that dispatches all the operations on the given GCD queue
  */
  public func dispatch(queue: dispatch_queue_t) -> BasicCache<KeyType, OutputType> {
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
        gcd.async {
          self.set(value, forKey: key)
        }
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

/**
Dispatches all the operations of a given CacheLevel on the given GCD queue
 
- parameter lhs: The CacheLevel you want to dispatch on the given GCD queue
- parameter rhs: The queue you want to dispatch all the operations (get, set, clear, onMemoryWarning) of the CacheLevel on
 
- returns: A new CacheLevel that dispatches all the operations on the given GCD queue
*/
public func ~>><A: CacheLevel>(lhs: A, rhs: dispatch_queue_t) -> BasicCache<A.KeyType, A.OutputType> {
  return lhs.dispatch(rhs)
}

/**
Dispatches all the operations of a given fetch closure on the given GCD queue
 
- parameter lhs: The fetch closure you want to dispatch on the given GCD queue
- parameter rhs: The queue you want to dispatch the fetch closure on
 
- returns: A new CacheLevel that dispatches the fetch closure on the given GCD queue
*/
public func ~>><A, B>(lhs: A -> Future<B>, rhs: dispatch_queue_t) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(lhs).dispatch(rhs)
}