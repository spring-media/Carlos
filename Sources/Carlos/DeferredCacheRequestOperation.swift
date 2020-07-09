import Foundation
import PiedPiper

/*
  Warning! this class contains a workaround in order to have effective generic NSOperations in Swift

  Workaround 1: Generic subclasses of NSOperation can't have @objc implementation of start() or main(), so these methods will never be called (see http://stackoverflow.com/questions/26097581/generic-nsoperation-subclass-loses-nsoperation-functionality/26104946#26104946)
*/
/**
A subclass of NSOperation that wraps a cache request and executes it at a later point
*/
public final class DeferredResultOperation<C: CacheLevel>: GenericOperation {
  private let key: C.KeyType
  private let cache: C
  private let decoy: Promise<C.OutputType>
  
  /**
  Initializes a new instance of DeferredResultOperation
  
  - parameter decoyRequest: The Promise you want to notify when the deferred request will actually succeed or fail
  - parameter key: The key to use when calling the deferred get
  - parameter cache: The cache to call get on to
  */
  public init(decoyRequest: Promise<C.OutputType>, key: C.KeyType, cache: C) {
    self.decoy = decoyRequest
    self.key = key
    self.cache = cache
    
    super.init()
  }
  
  public override func genericStart() {
    state = .executing
    
    cache.get(key)
      .onSuccess { result in
        GCD.main {
          self.decoy.succeed(result)
        }
        self.state = .finished
      }
      .onFailure { error in
        GCD.main {
          self.decoy.fail(error)
        }
        self.state = .finished
      }
      .onCancel {
        GCD.main {
          self.decoy.cancel()
        }
        self.state = .finished
      }
    }
}
