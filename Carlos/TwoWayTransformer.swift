//
//  TwoWayTransformer.swift
//  Carlos
//
//  Created by Vittorio Monaco on 07/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

/// Abstract an object that can transform values to another type and back to the original one
public protocol TwoWayTransformer {
  /// The input type of the transformation
  typealias TypeIn
  
  /// The output type of the transformation
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

/// Simple implementation of the TwoWayTransformer protocol
public struct TwoWayTransformationBox<I, O>: TwoWayTransformer {
  /// The input type of the transformation box
  public typealias TypeIn = I
  
  /// The output type of the transformation box
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