//
//  ConcurrentOperation.swift
//
//  Created by Caleb Davenport on 7/7/14.
//
//  Learn more at http://blog.calebd.me/swift-concurrent-operations
//

import Foundation

open class ConcurrentOperation: Operation {
  enum State {
    case ready
    case executing
    case finished
    
    func asKeyPath() -> String {
      switch self {
      case .ready:
        return "isReady"
      case .executing:
        return "isExecuting"
      case .finished:
        return "isFinished"
      }
    }
  }
  
  var state: State {
    willSet {
      willChangeValue(forKey: newValue.asKeyPath())
      willChangeValue(forKey: state.asKeyPath())
    }
    
    didSet {
      didChangeValue(forKey: oldValue.asKeyPath())
      didChangeValue(forKey: state.asKeyPath())
    }
  }
  
  override init() {
    state = .ready
    
    super.init()
  }
  
  // MARK: - NSOperation
  
  override open var isReady: Bool {
    return state == .ready
  }
  
  override open var isExecuting: Bool {
    return state == .executing
  }
  
  override open var isFinished: Bool {
    return state == .finished
  }
  
  override open var isAsynchronous: Bool {
    return true
  }
}
