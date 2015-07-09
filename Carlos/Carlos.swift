//
//  Cache.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// The error domain used for Carlos errors
public let CarlosErrorDomain = "CarlosErrorDomain"

public enum FetchError: Int {
  /// Used when a cache level doesn't have a value in the cache
  case ValueNotInCache = 10100
  
  /// Used when no cache level did find the key
  case NoCacheLevelsRemaining = 9900
  
  /// Used when the specified fetchable was invalid
  case InvalidFetchable = 8900
  
  /// Used when the fetchable doesn't satisfy the cache condition
  case ConditionNotSatisfied = 8901
}

internal func errorWithCode(code: Int) -> NSError {
  return NSError(domain: CarlosErrorDomain, code: code, userInfo: nil)
}

/**
Builds a convenience NSError with error code FetchError.ValueNotInCache

:returns: An initialized NSError with the Carlos error domain and the ValueNotInCache error code.

:discussion: The userInfo dictionary is empty
*/
public func valueNotInCacheError() -> NSError {
  return errorWithCode(FetchError.ValueNotInCache.rawValue)
}

internal struct CarlosGlobals {
  static let QueueNamePrefix = "com.carlos."
  static let Caches = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
}

/**
Adds a memory warning listener on the given cache

:param: cache The cache that should listen to the memory warnings. Usually it's the top level cache result of the cache levels composition

:returns: The token that you should use later on to unsubscribe
*/
public func listenToMemoryWarnings<A: CacheLevel where A: AnyObject>(cache: A) -> NSObjectProtocol {
  return NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak cache] _ in
    if let cache = cache {
      cache.onMemoryWarning()
    }
  })
}

/**
Removes the memory warning listener

:param: token The token you got from the call to listenToMemoryWarning: previously
*/
public func unsubscribeToMemoryWarnings(token: NSObjectProtocol) {
  NSNotificationCenter.defaultCenter().removeObserver(token, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
}

/// This class wraps a cache request future
public class CacheRequest<T> {
  private var failureListeners: [(NSError?) -> Void] = []
  private var successListeners: [(T) -> Void] = []
  private var didSucceed = false
  private var didFail = false
  private var error: NSError?
  private var value: T?
  
  /// Creates a new CacheRequest
  public init() {}
  
  /**
  Makes the request succeed with a value
  
  :param: value The value found for the request
  
  :discussion: Calling this method makes all the listeners get the onSuccess callback
  */
  public func succeed(value: T) {
    didSucceed = true
    self.value = value
    
    for listener in successListeners {
      listener(value)
    }
  }
  
  /**
  Makes the request fail with an error
  
  :param: error The optional error that caused the request to fail
  
  :discussion: Calling this method makes all the listeners get the onFailure callback
  */
  public func fail(error: NSError?) {
    didFail = true
    self.error = error
    
    for listener in failureListeners {
      listener(error)
    }
  }
  
  /**
  Adds a listener for the success event of this request
  
  :param: success The closure that should be called when the request succeeds, taking the value as a parameter
  
  :returns: The updated request
  */
  public func onSuccess(success: (T) -> Void) -> CacheRequest<T> {
    if let value = value where didSucceed {
      success(value)
    } else {
      successListeners.append(success)
    }
    
    return self
  }
  
  /**
  Adds a listener for the failure event of this request
  
  :param: success The closure that should be called when the request fails, taking the error as a parameter
  
  :returns: The updated request
  */
  public func onFailure(failure: (NSError?) -> Void) -> CacheRequest<T> {
    if didFail {
      failure(error)
    } else {
      failureListeners.append(failure)
    }
    
    return self
  }
}

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

/**
Wraps a CacheLevel with a requests pool

:param: cache The cache level you want to decorate

:returns: A PoolCache that will pool requests coming to the decorated cache. This means that multiple requests for the same fetchable will be pooled and only one will be actually done (so that expensive operations like network or file system fetches will only be done once). All onSuccess and onFailure callbacks will be done on the pooled request.
*/
public func pooled<A: CacheLevel where A.KeyType: Hashable>(cache: A) -> PoolCache<A.KeyType, A.OutputType, A> {
  return PoolCache<A.KeyType, A.OutputType, A>(internalCache: cache)
}

/// An abstraction for a generic cache level
public protocol CacheLevel {
  /// A typealias for the key the cache level accepts
  typealias KeyType
  
  /// A typealias for the data the cache returns in the success closure
  typealias OutputType
  
  /**
  Tries to get a value from the cache level
  
  :param: fetchable The key of the value you would like to get
  
  :returns: a CacheRequest that you can attach success and failure closures to
  */
  func get(fetchable: KeyType) -> CacheRequest<OutputType>
  
  /**
  Tries to set a value on the cache level
  
  :param: value The bytes to set on the cache level
  :param: fetchable The key of the value you're trying to set
  */
  func set(value: OutputType, forKey fetchable: KeyType)
  
  /**
  Asks to clear the cache level
  */
  func clear()
  
  /**
  Notifies the cache level that a memory warning was thrown, and asks it to do its best to clean some memory
  */
  func onMemoryWarning()
}

infix operator >>> { associativity left }

internal func wrapClosureIntoCacheLevel<A, B>(closure: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return BasicCache<A, B>(getClosure: { key in
    return closure(key: key)
  }, setClosure: { (_, _) in }, clearClosure: { }, memoryClosure: { })
}

/**
Composes two cache closures

:param: firstFetcher The first cache closure
:param: secondFetcher The second cache closure

:returns: A new cache level that is the result of the composition of the two cache closures
*/
public func compose<A, B>(firstFetcher: (key: A) -> CacheRequest<B>, secondFetcher: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return wrapClosureIntoCacheLevel(firstFetcher) >>> wrapClosureIntoCacheLevel(secondFetcher)
}

/**
Composes two cache levels

:param: firstCache The first cache level
:param: secondCache The second cache level

:returns: A new cache level that is the result of the composition of the two cache levels
*/
public func compose<A: CacheLevel, B: CacheLevel where A.KeyType == B.KeyType, A.OutputType == B.OutputType>(firstCache: A, secondCache: B) -> BasicCache<A.KeyType, A.OutputType> {
  return BasicCache<A.KeyType, A.OutputType>(
    getClosure: { key in
      let request = CacheRequest<A.OutputType>()
      
      firstCache.get(key)
        .onSuccess({ result in
          request.succeed(result)
        })
        .onFailure({ error in
          secondCache.get(key).onSuccess({ result in
            request.succeed(result)
            firstCache.set(result, forKey: key)
          }).onFailure({ error in
            request.fail(error)
          })
        })
      
      return request
    }, setClosure: { (key, value) in
      firstCache.set(value, forKey: key)
      secondCache.set(value, forKey: key)
    }, clearClosure: {
      firstCache.clear()
      secondCache.clear()
    }, memoryClosure: {
      firstCache.onMemoryWarning()
      secondCache.onMemoryWarning()
    }
  )
}

/**
Composes a cache level with a cache closure

:param: cache The cache level
:param: fetchClosure The cache closure

:returns: A new cache level that is the result of the composition of the cache level with the cache closure
*/
public func compose<A: CacheLevel>(cache: A, fetchClosure: (key: A.KeyType) -> CacheRequest<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return cache >>> wrapClosureIntoCacheLevel(fetchClosure)
}

/**
Composes a cache closure with a cache level

:param: fetchClosure The cache closure
:param: cache The cache level

:returns: A new cache level that is the result of the composition of the cache closure with the cache level
*/
public func compose<A: CacheLevel>(fetchClosure: (key: A.KeyType) -> CacheRequest<A.OutputType>, cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return wrapClosureIntoCacheLevel(fetchClosure) >>> cache
}

/**
Composes two cache closures

:param: firstFetcher The first cache closure
:param: secondFetcher The second cache closure

:returns: A new cache level that is the result of the composition of the two cache closures
*/
public func >>><A, B>(firstFetcher: (key: A) -> CacheRequest<B>, secondFetcher: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return compose(firstFetcher, secondFetcher)
}

/**
Composes two cache levels

:param: firstCache The first cache level
:param: secondCache The second cache level

:returns: A new cache level that is the result of the composition of the two cache levels
*/
public func >>><A: CacheLevel, B: CacheLevel where A.KeyType == B.KeyType, A.OutputType == B.OutputType>(firstCache: A, secondCache: B) -> BasicCache<A.KeyType, A.OutputType> {
  return compose(firstCache, secondCache)
}

/**
Composes a cache level with a cache closure

:param: cache The cache level
:param: fetchClosure The cache closure

:returns: A new cache level that is the result of the composition of the cache level with the cache closure
*/
public func >>><A: CacheLevel>(cache: A, fetchClosure: (key: A.KeyType) -> CacheRequest<A.OutputType>) -> BasicCache<A.KeyType, A.OutputType> {
  return compose(cache, wrapClosureIntoCacheLevel(fetchClosure))
}

/**
Composes a cache closure with a cache level

:param: fetchClosure The cache closure
:param: cache The cache level

:returns: A new cache level that is the result of the composition of the cache closure with the cache level
*/
public func >>><A: CacheLevel>(fetchClosure: (key: A.KeyType) -> CacheRequest<A.OutputType>, cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return compose(wrapClosureIntoCacheLevel(fetchClosure), cache)
}