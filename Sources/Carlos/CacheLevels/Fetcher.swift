//
//  Fetcher.swift
//
//
//  Created by Lisovyi, Ivan on 24.10.20.
//

import Combine
import Foundation

/// An abstraction for a generic cache level that can only fetch values but not store them
public protocol Fetcher: CacheLevel {}

/// Extending the Fetcher protocol to have a default no-op implementation for clear, onMemoryWarning and set
extension Fetcher {
  /// No-op
  public func remove(_ key: KeyType) -> AnyPublisher<Void, Error> {
    Empty(completeImmediately: true).eraseToAnyPublisher()
  }

  /// No-op
  public func clear() {}

  /// No-op
  public func onMemoryWarning() {}

  /// No-op
  public func set(_: OutputType, forKey _: KeyType) -> AnyPublisher<Void, Error> {
    Empty(completeImmediately: true).eraseToAnyPublisher()
  }
}
