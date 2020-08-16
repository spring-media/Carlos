import Foundation

import OpenCombine
import OpenCombineDispatch

extension CacheLevel {
  /**
  Dispatches all the operations of this CacheLevel on the given GCD queue
   
  - parameter queue: The queue you want to dispatch all the operations (get, set, clear, onMemoryWarning) of this CacheLevel on
   
  - returns: A new CacheLevel that dispatches all the operations on the given GCD queue
  */
  public func dispatch(_ queue: DispatchQueue) -> BasicCache<KeyType, OutputType> {
    return BasicCache(
      getClosure: { key in
        self.get(key)
          .receive(on: queue.ocombine)
          .eraseToAnyPublisher()
      },
      setClosure: { (value, key) in
        self.set(value, forKey: key)
          .receive(on: queue.ocombine)
          .eraseToAnyPublisher()
      },
      clearClosure: {
        queue.async { self.clear() }
      },
      memoryClosure: {
        queue.async { self.onMemoryWarning() }
      }
    )
  }
}
