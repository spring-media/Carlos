//
//  Errors.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 09/07/15.
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