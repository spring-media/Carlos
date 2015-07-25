//
//  ConcurrentOperation.swift
//
//  Created by Caleb Davenport on 7/7/14.
//
//  Learn more at http://blog.calebd.me/swift-concurrent-operations
//

import Foundation

public class ConcurrentOperation: NSOperation {
  enum State {
    case Ready
    case Executing
    case Finished
    
    func asKeyPath() -> String {
      switch self {
      case .Ready:
        return "isReady"
      case .Executing:
        return "isExecuting"
      case .Finished:
        return "isFinished"
      }
    }
  }
  
  var state: State {
    willSet {
      willChangeValueForKey(newValue.asKeyPath())
      willChangeValueForKey(state.asKeyPath())
    }
    
    didSet {
      didChangeValueForKey(oldValue.asKeyPath())
      didChangeValueForKey(state.asKeyPath())
    }
  }
  
  override init() {
    state = .Ready
    
    super.init()
  }
  
  // MARK: - NSOperation
  
  override public var ready: Bool {
    return state == .Ready
  }
  
  override public var executing: Bool {
    return state == .Executing
  }
  
  override public var finished: Bool {
    return state == .Finished
  }
  
  override public var asynchronous: Bool {
    return true
  }
}