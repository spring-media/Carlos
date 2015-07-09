//
//  PoolCache.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 09/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

public class PoolCache<A: Hashable, B, C: CacheLevel where C.KeyType == A, C.OutputType == B>: CacheLevel {
  public typealias KeyType = A
  public typealias OutputType = B
  
  private let internalCache: C
  private var requestsPool: [A: CacheRequest<B>] = [:]
  
  public init(internalCache: C) {
    self.internalCache = internalCache
  }
  
  public func get(fetchable: KeyType) -> CacheRequest<OutputType> {
    let request: CacheRequest<OutputType>
    
    if let pooledRequest = requestsPool[fetchable] {
      Logger.log("Using pooled request \(pooledRequest) for fetchable \(fetchable)")
      request = pooledRequest
    } else {
      request = internalCache.get(fetchable)
      requestsPool[fetchable] = request
      
      Logger.log("Creating a new request \(request) for fetchable \(fetchable)")
      
      request
        .onSuccess({ result in
          self.requestsPool[fetchable] = nil
        })
        .onFailure({ error in
          self.requestsPool[fetchable] = nil
        })
    }
    
    return request
  }
  
  public func set(value: B, forKey fetchable: A) {
    internalCache.set(value, forKey: fetchable)
  }
  
  public func clear() {
    internalCache.clear()
  }
  
  public func onMemoryWarning() {
    internalCache.onMemoryWarning()
  }
}