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
}

internal func errorWithCode(code: Int) -> NSError {
  return NSError(domain: CarlosErrorDomain, code: code, userInfo: nil)
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

/// An abstraction for a generic cache level
public protocol CacheLevel {
  /// A typealias for the key the cache level accepts
  typealias KeyType
  
  /// A typealias for the data the cache returns in the success closure
  typealias OutputType
  
  /**
  Tries to get a value from the cache level
  
  :param: fetchable The key of the value you would like to get
  :param: success The closure to execute when the value is found
  :param: failure The closure to execute when no value is found for the given key on the cache level
  */
  func get(fetchable: KeyType, onSuccess success: (OutputType) -> Void, onFailure failure: (NSError?) -> Void)
  
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

internal func wrapClosureIntoCacheLevel<A, B>(closure: (key: A, success: B -> Void, failure: NSError? -> Void) -> Void) -> BasicCache<A, B> {
  return BasicCache<A, B>(getClosure: { (key, success, failure) in
    closure(key: key , success: success, failure: failure)
  }, setClosure: { (_, _) in }, clearClosure: { }, memoryClosure: { })
}

/**
Composes two cache closures

:param: firstFetcher The first cache closure
:param: secondFetcher The second cache closure

:returns: A new cache level that is the result of the composition of the two cache closures
*/
public func >>><A, B>(firstFetcher: (key: A, success: B -> Void, failure: NSError? -> Void) -> Void, secondFetcher: (key: A, success: B -> Void, failure: NSError? -> Void) -> Void) -> BasicCache<A, B> {
  return wrapClosureIntoCacheLevel(firstFetcher) >>> wrapClosureIntoCacheLevel(secondFetcher)
}

/**
Composes two cache levels

:param: firstCache The first cache level
:param: secondCache The second cache level

:returns: A new cache level that is the result of the composition of the two cache levels
*/
public func >>><A: CacheLevel, B: CacheLevel where A.KeyType == B.KeyType, A.OutputType == B.OutputType>(firstCache: A, secondCache: B) -> BasicCache<A.KeyType, A.OutputType> {
  return BasicCache<A.KeyType, A.OutputType>(getClosure: { (key, success, failure) in
    firstCache.get(key, onSuccess: success, onFailure: { error in
      secondCache.get(key, onSuccess: { result in
        firstCache.set(result, forKey: key)
        success(result)
      }, onFailure: failure)
    })
  }, setClosure: { (key, value) in
    firstCache.set(value, forKey: key)
    secondCache.set(value, forKey: key)
  }, clearClosure: {
    firstCache.clear()
    secondCache.clear()
  }, memoryClosure: {
    firstCache.onMemoryWarning()
    secondCache.onMemoryWarning()
  })
}

/**
Composes a cache level with a cache closure

:param: cache The cache level
:param: fetchClosure The cache closure

:returns: A new cache level that is the result of the composition of the cache level with the cache closure
*/
public func >>><A: CacheLevel>(cache: A, fetchClosure: (key: A.KeyType, success: A.OutputType -> Void, failure: NSError? -> Void) -> Void) -> BasicCache<A.KeyType, A.OutputType> {
  return cache >>> wrapClosureIntoCacheLevel(fetchClosure)
}

/**
Composes a cache closure with a cache level

:param: fetchClosure The cache closure
:param: cache The cache level

:returns: A new cache level that is the result of the composition of the cache closure with the cache level
*/
public func >>><A: CacheLevel>(fetchClosure: (key: A.KeyType, success: A.OutputType -> Void, failure: NSError? -> Void) -> Void, cache: A) -> BasicCache<A.KeyType, A.OutputType> {
  return wrapClosureIntoCacheLevel(fetchClosure) >>> cache
}