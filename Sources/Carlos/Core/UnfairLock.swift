//
//  UnfairLock.swift
//
//
//  Created by Lisovyi, Ivan on 16.08.20.
//

import Foundation

final class UnfairLock {
  private var _lock: UnsafeMutablePointer<os_unfair_lock>

  init() {
    _lock = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
    _lock.initialize(to: os_unfair_lock())
  }

  deinit {
    _lock.deallocate()
  }

  func locked<ReturnValue>(_ f: () throws -> ReturnValue) rethrows -> ReturnValue {
    os_unfair_lock_lock(_lock)
    defer { os_unfair_lock_unlock(_lock) }
    return try f()
  }

  func assertOwned() {
    os_unfair_lock_assert_owner(_lock)
  }

  func assertNotOwned() {
    os_unfair_lock_assert_not_owner(_lock)
  }
}
