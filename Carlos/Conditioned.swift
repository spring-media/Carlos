import Foundation

infix operator <?> { associativity right }

extension CacheLevel {
  
  /**
  Wraps the CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally
  
  - parameter condition: The condition closure that takes a key and returns true if the key can be fetched, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Result<Bool>
  
  - returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
  
  The condition doesn't apply to the set, clear, onMemoryWarning calls
  */
  public func conditioned(condition: (KeyType) -> Result<Bool>) -> BasicCache<KeyType, OutputType> {
    return BasicCache(
      getClosure: { key in
        let request = Result<OutputType>()
        
        condition(key)
          .onSuccess { passesCondition in
            if passesCondition {
              request.mimic(self.get(key))
            } else {
              request.fail(FetchError.ConditionNotSatisfied)
            }
          }
          .onFailure {
            request.fail($0)
          }
        
        return request
      },
      setClosure: self.set,
      clearClosure: self.clear,
      memoryClosure: self.onMemoryWarning
    )
  }
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

- parameter condition: The condition closure that takes a key and returns true if the key can be fetched, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Result<Bool>
- parameter cache: The cache level you want to decorate

- returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

The condition doesn't apply to the set, clear, onMemoryWarning calls
*/
public func <?><A: CacheLevel>(condition: (A.KeyType) -> Result<Bool>, cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.conditioned(condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

- parameter condition: The condition closure that takes a key and returns true if the key can be fetched, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Result<Bool>
- parameter fetchClosure: The fetch closure to decorate

- returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
*/
public func <?><A, B>(condition: A -> Result<Bool>, fetchClosure: (key: A) -> Result<B>) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(fetchClosure).conditioned(condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

- parameter fetchClosure: The fetch closure to decorate
- parameter condition: The condition closure that takes a key and returns true if the key can be fetched, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Result<Bool>

- returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level
*/
public func conditioned<A, B>(fetchClosure: (key: A) -> Result<B>, condition: A -> Result<Bool>) -> BasicCache<A, B> {
  return wrapClosureIntoFetcher(fetchClosure).conditioned(condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

- parameter cache: The cache level you want to decorate
- parameter condition: The condition closure that takes a key and returns true if the key can be fetched, or false if the request should fail unconditionally. The closure can also pass a specific error in case it wants to explicitly communicate why it failed. The condition can be asynchronous and has to return a Result<Bool>

- returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

The condition doesn't apply to the set, clear, onMemoryWarning calls
*/
public func conditioned<A: CacheLevel>(cache: A, condition: (A.KeyType) -> Result<Bool>) -> BasicCache<A.KeyType, A.OutputType> {
  return cache.conditioned(condition)
}
