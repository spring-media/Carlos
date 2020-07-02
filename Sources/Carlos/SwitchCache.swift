import Foundation
import PiedPiper

/// Convenience enumeration to specify which of two switched cache levels should be used for a get or set operation
public enum CacheLevelSwitchResult {
  /// The first CacheLevel of the switch
  case cacheA
  /// The second CacheLevel of the switch
  case cacheB
}

/**
Switches two existing cache levels and returns a new cache level with the switching logic inside.
This enables you to have multiple cache "lanes" and switch between them depending on the key that is currently being fetcher or set, or some other external condition.

- parameter cacheA: The first cache level you want to switch
- parameter cacheB: The second cache level you want to switch
- parameter switchClosure: The closure where you return which of the two cache levels should be used for get or set calls depending on the key or some other external condition

- returns: A new cache level that includes the specified switching logic. clear and onMemoryWarning calls are dispatched to both lanes.
*/
public func switchLevels<A: CacheLevel, B: CacheLevel>(cacheA: A, cacheB: B, switchClosure: @escaping (_ key: A.KeyType) -> CacheLevelSwitchResult) -> BasicCache<A.KeyType, A.OutputType> where A.KeyType == B.KeyType, A.OutputType == B.OutputType {
  return BasicCache(
    getClosure: { key in
      switch switchClosure(key) {
      case .cacheA:
        return cacheA.get(key)
      case .cacheB:
        return cacheB.get(key)
      }
    },
    setClosure: { (value, key) in
      switch switchClosure(key) {
      case .cacheA:
        return cacheA.set(value, forKey: key)
      case .cacheB:
        return cacheB.set(value, forKey: key)
      }
    },
    clearClosure: {
      cacheA.clear()
      cacheB.clear()
    },
    memoryClosure: {
      cacheA.onMemoryWarning()
      cacheB.onMemoryWarning()
    }
  )
}
