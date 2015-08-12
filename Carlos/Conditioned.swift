import Foundation

infix operator <?> { associativity right }

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

:param: condition The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.
:param: cache The cache level you want to decorate

:returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

:discussion: The condition doesn't apply to the set, clear, onMemoryWarning calls
*/
public func <?><A: CacheLevel>(condition: (A.KeyType) -> (Bool, NSError?), cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return conditioned(cache, condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

:param: condition The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.
:param: fetchClosure The fetch closure to decorate

:returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
*/
public func <?><A, B>(condition: A -> (Bool, NSError?), fetchClosure: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return conditioned(wrapClosureIntoCacheLevel(fetchClosure), condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

:param: fetchClosure The fetch closure to decorate
:param: condition The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.

:returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
*/
public func conditioned<A, B>(fetchClosure: (key: A) -> CacheRequest<B>, condition: A -> (Bool, NSError?)) -> BasicCache<A, B> {
  return conditioned(wrapClosureIntoCacheLevel(fetchClosure), condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

:param: cache The cache level you want to decorate
:param: condition The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.

:returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

:discussion: The condition doesn't apply to the set, clear, onMemoryWarning calls
*/
public func conditioned<A: CacheLevel>(cache: A, condition: (A.KeyType) -> (Bool, NSError?)) -> BasicCache<A.KeyType, A.OutputType> {
  return BasicCache(
    getClosure: { (key) in
      let request = CacheRequest<A.OutputType>()
      
      let (passesCondition, error) = condition(key)
      if passesCondition {
        cache.get(key).onSuccess({ result in
          request.succeed(result)
        }).onFailure({ error in
          request.fail(error)
        })
      } else {
        request.fail(error ?? errorWithCode(FetchError.ConditionNotSatisfied.rawValue))
      }
      
      return request
    },
    setClosure: { (key, value) in
      cache.set(value, forKey: key)
    },
    clearClosure: { cache.clear() },
    memoryClosure: { cache.onMemoryWarning() }
  )
}
