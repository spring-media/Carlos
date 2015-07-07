//
//  Transformer.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 07/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// Abstract an object that can transform values to another type and back to the original one
public protocol Transformer {
  typealias TypeA
  typealias TypeB
  
  /**
  Apply the forward transformation from A to B
  
  :param: val The value to transform
  
  :returns: The transformed value
  */
  func forwardTransform(val: TypeA) -> TypeB
  
  /**
  Apply the inverse transformation from B to A
  
  :param: val The value to inverse transform
  
  :returns: The original value
  */
  func inverseTransform(val: TypeB) -> TypeA
}

/// Simple implementation of the Transformer protocol
public struct TransformationBox<A, B>: Transformer {
  public typealias TypeA = A
  public typealias TypeB = B
  
  private let forwardTransformClosure: A -> B
  private let inverseTransformClosure: B -> A
  
  public init(forwardTransform: (A -> B), inverseTransform: (B -> A)) {
    self.forwardTransformClosure = forwardTransform
    self.inverseTransformClosure = inverseTransform
  }
  
  public func forwardTransform(val: A) -> B {
    return forwardTransformClosure(val)
  }
  
  public func inverseTransform(val: TypeB) -> TypeA {
    return inverseTransformClosure(val)
  }
}

infix operator <*> { associativity left }

/**
Applies a transformation to a cache closure

:param: cacheLevel The cache closure you want to transform
:param: transformationBox The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func <*><A, B, C: Transformer where C.TypeA == B>(cacheLevel: (key: A, success: B -> Void, failure: NSError? -> Void) -> Void, transformationBox: C) -> BasicCache<A, C.TypeB> {
  return wrapClosureIntoCacheLevel(cacheLevel) <*> transformationBox
}

/**
Applies a transformation to a cache level

:param: cacheLevel The cache level you want to transform
:param: transformationBox The transformation you want to apply

:returns: A new cache level result of the transformation of the original cache level
*/
public func <*><A: CacheLevel, B: Transformer where A.OutputType == B.TypeA>(cacheLevel: A, transformationBox: B) -> BasicCache<A.KeyType, B.TypeB> {
  return BasicCache<A.KeyType, B.TypeB>(getClosure: { (key, success, failure) in
    cacheLevel.get(key, onSuccess: { result in
      success(transformationBox.forwardTransform(result))
      }, onFailure: { error in
        failure(error)
    })
    }, setClosure: { (key, value) in
      cacheLevel.set(transformationBox.inverseTransform(value), forKey: key)
    }, clearClosure: {
      cacheLevel.clear()
    }, memoryClosure: {
      cacheLevel.onMemoryWarning()
  })
}