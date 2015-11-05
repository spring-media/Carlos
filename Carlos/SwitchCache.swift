import Foundation

/// Convenience enumeration to specify which of two switched cache levels should be used for a get or set operation
public enum CacheLevelSwitchResult {
  /// The first CacheLevel of the switch
  case CacheA
  /// The second CacheLevel of the switch
  case CacheB
}

/**
Switches two existing cache levels and returns a new cache level with the switching logic inside.
This enables you to have multiple cache "lanes" and switch between them depending on the key that is currently being fetcher or set, or some other external condition.

- parameter cacheA: The first cache level you want to switch, specified as a fetch closure
- parameter cacheB: The second cache level you want to switch
- parameter switchClosure: The closure where you return which of the two cache levels should be used for get or set calls depending on the key or some other external condition

- returns: A new cache level that includes the specified switching logic. clear and onMemoryWarning calls are dispatched to both lanes.
*/
public func switchLevels<A: CacheLevel, B, C where A.KeyType == B, A.OutputType == C>(cacheA: A, cacheB: (key: B) -> Future<C>, switchClosure: (key: A.KeyType) -> CacheLevelSwitchResult) -> BasicCache<A.KeyType, A.OutputType> {
  return switchLevels(cacheA, cacheB: wrapClosureIntoFetcher(cacheB), switchClosure: switchClosure)
}

/**
Switches two existing cache levels and returns a new cache level with the switching logic inside.
This enables you to have multiple cache "lanes" and switch between them depending on the key that is currently being fetcher or set, or some other external condition.

- parameter cacheA: The first cache level you want to switch
- parameter cacheB: The second cache level you want to switch, specified as a fetch closure
- parameter switchClosure: The closure where you return which of the two cache levels should be used for get or set calls depending on the key or some other external condition

- returns: A new cache level that includes the specified switching logic. clear and onMemoryWarning calls are dispatched to both lanes.
*/
public func switchLevels<A: CacheLevel, B, C where A.KeyType == B, A.OutputType == C>(cacheA: (key: B) -> Future<C>, cacheB: A, switchClosure: (key: A.KeyType) -> CacheLevelSwitchResult) -> BasicCache<A.KeyType, A.OutputType> {
  return switchLevels(wrapClosureIntoFetcher(cacheA), cacheB: cacheB, switchClosure: switchClosure)
}

/**
Switches two existing cache levels and returns a new cache level with the switching logic inside.
This enables you to have multiple cache "lanes" and switch between them depending on the key that is currently being fetcher or set, or some other external condition.

- parameter cacheA: The first cache level you want to switch, specified as a fetch closure
- parameter cacheB: The second cache level you want to switch, specified as a fetch closure
- parameter switchClosure: The closure where you return which of the two cache levels should be used for get or set calls depending on the key or some other external condition

- returns: A new cache level that includes the specified switching logic. clear and onMemoryWarning calls are dispatched to both lanes.
*/
public func switchLevels<A, B>(cacheA: (key: A) -> Future<B>, cacheB: (key: A) -> Future<B>, switchClosure: (key: A) -> CacheLevelSwitchResult) -> BasicCache<A, B> {
  return switchLevels(wrapClosureIntoFetcher(cacheA), cacheB: wrapClosureIntoFetcher(cacheB), switchClosure: switchClosure)
}

/**
Switches two existing cache levels and returns a new cache level with the switching logic inside.
This enables you to have multiple cache "lanes" and switch between them depending on the key that is currently being fetcher or set, or some other external condition.

- parameter cacheA: The first cache level you want to switch
- parameter cacheB: The second cache level you want to switch
- parameter switchClosure: The closure where you return which of the two cache levels should be used for get or set calls depending on the key or some other external condition

- returns: A new cache level that includes the specified switching logic. clear and onMemoryWarning calls are dispatched to both lanes.
*/
public func switchLevels<A: CacheLevel, B: CacheLevel where A.KeyType == B.KeyType, A.OutputType == B.OutputType>(cacheA: A, cacheB: B, switchClosure: (key: A.KeyType) -> CacheLevelSwitchResult) -> BasicCache<A.KeyType, A.OutputType> {
  return BasicCache(
    getClosure: { key in
      switch switchClosure(key: key) {
      case .CacheA:
        return cacheA.get(key)
      case .CacheB:
        return cacheB.get(key)
      }
    },
    setClosure: { (value, key) in
      switch switchClosure(key: key) {
      case .CacheA:
        cacheA.set(value, forKey: key)
      case .CacheB:
        cacheB.set(value, forKey: key)
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