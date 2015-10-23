//
//  ReadWriteLock.swift
//  ReadWriteLock
//
//  Created by John Gallagher on 7/17/14.
//  Copyright © 2014-2015 Big Nerd Ranch. Licensed under MIT.
//

import Foundation

protocol ReadWriteLock {
  func withReadLock<T>(@noescape body: () -> T) -> T
  func withWriteLock<T>(@noescape body: () -> T) -> T
}

final class PThreadReadWriteLock: ReadWriteLock {
  private var lock: UnsafeMutablePointer<pthread_rwlock_t>
  
  init() {
    lock = UnsafeMutablePointer.alloc(1)
    let status = pthread_rwlock_init(lock, nil)
    assert(status == 0)
  }
  
  deinit {
    let status = pthread_rwlock_destroy(lock)
    assert(status == 0)
    lock.dealloc(1)
  }
  
  func withReadLock<T>(@noescape body: () -> T) -> T {
    let result: T
    pthread_rwlock_rdlock(lock)
    result = body()
    pthread_rwlock_unlock(lock)
    return result
  }
  
  func withWriteLock<T>(@noescape body: () -> T) -> T {
    let result: T
    pthread_rwlock_wrlock(lock)
    result = body()
    pthread_rwlock_unlock(lock)
    return result
  }
}