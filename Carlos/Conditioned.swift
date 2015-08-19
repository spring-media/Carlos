import Foundation

infix operator <?> { associativity right }

extension CacheLevel {
  
  /**
  Wraps the CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally
  
  - parameter condition: The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.
  
  - returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
  
  :discussion: The condition doesn't apply to the set, clear, onMemoryWarning calls
  */
  public func conditioned(condition: (KeyType) -> (Bool, ErrorType?)) -> BasicCache<KeyType, OutputType> {
    return BasicCache(
      getClosure: { (key) in
        let request: CacheRequest<OutputType>
        
        let (passesCondition, error) = condition(key)
        if passesCondition {
          request = self.get(key)
        } else {
          request = CacheRequest(error: error ?? FetchError.ConditionNotSatisfied)
        }
        
        return request
      },
      setClosure: { (key, value) in
        self.set(value, forKey: key)
      },
      clearClosure: { self.clear() },
      memoryClosure: { self.onMemoryWarning() }
    )
  }
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

- parameter condition: The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.
- parameter cache: The cache level you want to decorate

- returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

:discussion: The condition doesn't apply to the set, clear, onMemoryWarning calls
*/
public func <?><A: CacheLevel>(condition: (A.KeyType) -> (Bool, ErrorType?), cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.conditioned(condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

- parameter condition: The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.
- parameter fetchClosure: The fetch closure to decorate

- returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
*/
public func <?><A, B>(condition: A -> (Bool, ErrorType?), fetchClosure: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return wrapClosureIntoCacheLevel(fetchClosure).conditioned(condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

- parameter fetchClosure: The fetch closure to decorate
- parameter condition: The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.

- returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
*/
public func conditioned<A, B>(fetchClosure: (key: A) -> CacheRequest<B>, condition: A -> (Bool, ErrorType?)) -> BasicCache<A, B> {
  return wrapClosureIntoCacheLevel(fetchClosure).conditioned(condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

- parameter cache: The cache level you want to decorate
- parameter condition: The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.

- returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

:discussion: The condition doesn't apply to the set, clear, onMemoryWarning calls
*/
public func conditioned<A: CacheLevel>(cache: A, condition: (A.KeyType) -> (Bool, ErrorType?)) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.conditioned(condition)
}
