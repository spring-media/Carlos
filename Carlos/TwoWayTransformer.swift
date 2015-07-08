//
//  TwoWayTransformer.swift
//  Carlos
//
//  Created by Vittorio Monaco on 07/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// Abstract an object that can transform values to another type and back to the original one
public protocol TwoWayTransformer: OneWayTransformer {
  /**
  Apply the inverse transformation from B to A
  
  :param: val The value to inverse transform
  
  :returns: The original value
  */
  func inverseTransform(val: TypeOut) -> TypeIn
}

/// Simple implementation of the TwoWayTransformer protocol
public struct TwoWayTransformationBox<I, O>: TwoWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = I
  
  /// The output type of the transformation box
  public typealias TypeOut = O
  
  private let transformClosure: I -> O
  private let inverseTransformClosure: O -> I
  
  public init(transform: (I -> O), inverseTransform: (O -> I)) {
    self.transformClosure = transform
    self.inverseTransformClosure = inverseTransform
  }
  
  public func transform(val: I) -> O {
    return transformClosure(val)
  }
  
  public func inverseTransform(val: O) -> I {
    return inverseTransformClosure(val)
  }
}