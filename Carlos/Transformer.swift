//
//  TwoWayTransformer.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 07/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// Abstract an object that can transform values to another type and back to the original one
public protocol TwoWayTransformer {
  typealias TypeIn
  typealias TypeOut
  
  /**
  Apply the forward transformation from A to B
  
  :param: val The value to transform
  
  :returns: The transformed value
  */
  func forwardTransform(val: TypeIn) -> TypeOut
  
  /**
  Apply the inverse transformation from B to A
  
  :param: val The value to inverse transform
  
  :returns: The original value
  */
  func inverseTransform(val: TypeOut) -> TypeIn
}

/// Abstract an object that can transform values to another type
public protocol OneWayTransformer {
  typealias TypeIn
  typealias TypeOut
  
  /**
  Apply the transformation from A to B
  
  :param: val The value to transform
  
  :returns: The transformed value
  */
  func transform(val: TypeIn) -> TypeOut
}

/// Simple implementation of the TwoWayTransformer protocol
public struct TwoWayTransformationBox<I, O>: TwoWayTransformer {
  public typealias TypeIn = I
  public typealias TypeOut = O
  
  private let forwardTransformClosure: I -> O
  private let inverseTransformClosure: O -> I
  
  public init(forwardTransform: (I -> O), inverseTransform: (O -> I)) {
    self.forwardTransformClosure = forwardTransform
    self.inverseTransformClosure = inverseTransform
  }
  
  public func forwardTransform(val: I) -> O {
    return forwardTransformClosure(val)
  }
  
  public func inverseTransform(val: O) -> I {
    return inverseTransformClosure(val)
  }
}

/// Simple implementation of the TwoWayTransformer protocol
public struct OneWayTransformationBox<I, O>: OneWayTransformer {
  public typealias TypeIn = I
  public typealias TypeOut = O
  
  private let transformClosure: I -> O
  
  public init(transform: (I -> O)) {
    self.transformClosure = transform
  }
  
  public func transform(val: TypeIn) -> TypeOut {
    return transformClosure(val)
  }
}

infix operator <*> { associativity left }

/**
Applies a transformation to a cache closure

:param: cacheLevel The cache closure you want to transform
:param: transformationBox The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func <*><A, B, C: TwoWayTransformer where C.TypeIn == B>(cacheLevel: (key: A, success: B -> Void, failure: NSError? -> Void) -> Void, transformationBox: C) -> BasicCache<A, C.TypeOut> {
  return wrapClosureIntoCacheLevel(cacheLevel) <*> transformationBox
}

/**
Applies a transformation to a cache level

:param: cacheLevel The cache level you want to transform
:param: transformationBox The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func <*><A: CacheLevel, B: TwoWayTransformer where A.OutputType == B.TypeIn>(cacheLevel: A, transformationBox: B) -> BasicCache<A.KeyType, B.TypeOut> {
  return BasicCache<A.KeyType, B.TypeOut>(getClosure: { (key, success, failure) in
    cacheLevel.get(key, onSuccess: { result in
      success(transformationBox.forwardTransform(result))
    }, onFailure: failure)
  }, setClosure: { (key, value) in
    cacheLevel.set(transformationBox.inverseTransform(value), forKey: key)
  }, clearClosure: {
    cacheLevel.clear()
  }, memoryClosure: {
    cacheLevel.onMemoryWarning()
  })
}

infix operator <^> { associativity left }

/**
Applies a transformation to a cache closure

:param: cacheLevel The cache closure you want to transform
:param: transformationBox The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func <^><A, B, C: OneWayTransformer where C.TypeOut == A>(cacheLevel: (key: A, success: B -> Void, failure: NSError? -> Void) -> Void, transformationBox: C) -> BasicCache<C.TypeIn, B> {
  return wrapClosureIntoCacheLevel(cacheLevel) <^> transformationBox
}

/**
Applies a transformation to a cache level

:param: cacheLevel The cache level you want to transform
:param: transformationBox The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func <^><A: CacheLevel, B: OneWayTransformer where A.KeyType == B.TypeOut>(cacheLevel: A, transformationBox: B) -> BasicCache<B.TypeIn, A.OutputType> {
  return BasicCache<B.TypeIn, A.OutputType>(getClosure: { (key, success, failure) in
    cacheLevel.get(transformationBox.transform(key), onSuccess: success, onFailure: failure)
  }, setClosure: { (key, value) in
    cacheLevel.set(value, forKey: transformationBox.transform(key))
  }, clearClosure: {
    cacheLevel.clear()
  }, memoryClosure: {
    cacheLevel.onMemoryWarning()
  })
}
