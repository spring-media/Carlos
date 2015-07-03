//
//  Cache.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

public protocol Fetcher {
  typealias FetchableType

  func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void)
  func set(value: NSData, forKey key: FetchableType)
  func clear()
}

public protocol KeyType {
  var key: String { get }
}

public protocol NetworkFetchable: KeyType {
  var URL: NSURL { get }
}

public class NetworkFetcher: Fetcher {
  public typealias FetchableType = NetworkFetchable
}

public class Cache: Fetcher {
  public typealias FetchableType = KeyType

  private let fetchers: [Fetcher]

  public init(fetchers: [Fetcher] = []) {
    self.fetchers = fetchers
  }

  public func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    lookup(key, levels: fetchers, success: success, failure: failure)
  }

  private func lookup(key: FetchableType, levels: [Fetcher], success: (NSData) -> Void, failure: (NSError?) -> Void) {
    if levels.isEmpty {
      failure(nil)
    } else {
      levels.first?.get(key, onSuccess: { data in
        success(data)
      }, onFailure: { error in
        self.lookup(key, levels: Array(levels[1..<levels.count]), success: { data in
          self.set(data, forKey: key)
          success(data)
        }, failure: failure)
      })
    }
  }

  public func set(value: NSData, forKey key: FetchableType) {
    fetchers.first?.set(value, forKey: key)
  }

  public func clear() {
    for fetcher in fetchers {
      fetcher.clear()
    }
  }
}