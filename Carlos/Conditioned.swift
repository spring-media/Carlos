//
//  Conditioned.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 09/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

infix operator <?> { associativity right }

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

:param: cache The cache level you want to decorate
:param: condition The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.

:returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

:discussion: The condition doesn't apply to the set, clear, onMemoryWarning calls
*/
public func <?><A: CacheLevel, B where A.KeyType == B>(condition: (B) -> (Bool, NSError?), cache: A) -> BasicCache<B, A.OutputType> {
  return conditioned(cache, condition)
}

/**
Wraps a CacheLevel with a boolean condition on the key that controls when a get call should fail unconditionally

:param: cache The cache level you want to decorate
:param: condition The condition closure that takes a key and returns true whether the key could be fetched, or false whether the get should fail unconditionally. The closure also returns an optional error in case it wants to explicitly communicate why it failed. In case no error is returned, a default FetchError.ConditionNotSatisfied is used instead.

:returns: A new BasicCache that will check for the condition before every get is dispatched to the decorated cache level

:discussion: The condition doesn't apply to the set, clear, onMemoryWarning calls
*/
public func conditioned<A: CacheLevel, B where A.KeyType == B>(cache: A, condition: (B) -> (Bool, NSError?)) -> BasicCache<B, A.OutputType> {
  return BasicCache<B, A.OutputType>(
    getClosure: { (key) in
      let request = CacheRequest<A.OutputType>()
      
      let (passesCondition, error) = condition(key)
      if passesCondition {
        cache.get(key).onSuccess({ result in
          request.succeed(result)
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
