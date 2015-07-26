import Foundation

/*
  Warning! this class contains 2 (two) workarounds in order to have effective generic NSOperations in Swift

  Workaround 1: Generic subclasses of NSOperation can't have @objc implementation of start() or main(), so these methods will never be called (see http://stackoverflow.com/questions/26097581/generic-nsoperation-subclass-loses-nsoperation-functionality/26104946#26104946)

  Workaround 2: Generic subclasses of Objective-C classes can't have generic properties. We have to declare arrays of the generic type in order for the compiler to work... (see http://stackoverflow.com/questions/24161563/swift-compile-error-when-subclassing-nsobject-and-using-generics)
*/
/**
A subclass of NSOperation that wraps a cache request and executes it at a later point
*/
public class DeferredCacheRequestOperation<C: CacheLevel>: GenericOperation {
  private let keyFakeArray: [C.KeyType]
  private let cacheFakeArray: [C]
  private let decoyFakeArray: [CacheRequest<C.OutputType>]
  
  private var key: C.KeyType {
    return keyFakeArray[0]
  }
  
  private var cache: C {
    return cacheFakeArray[0]
  }
  
  private var decoy: CacheRequest<C.OutputType> {
    return decoyFakeArray[0]
  }
  
  /**
  Initializes a new instance of DeferredCacheRequestOperation
  
  :param: decoyRequest The CacheRequest you want to notify when the deferred request will actually succeed or fail
  :param: key The key to use when calling the deferred get
  :param: cache The cache to call get on to
  */
  public init(decoyRequest: CacheRequest<C.OutputType>, key: C.KeyType, cache: C) {
    self.decoyFakeArray = [decoyRequest]
    self.keyFakeArray = [key]
    self.cacheFakeArray = [cache]
    
    super.init()
  }
  
  public override func genericStart() {
    state = .Executing
    
    cache.get(key)
      .onSuccess({ result in
        dispatch_async(dispatch_get_main_queue()) {
          self.decoy.succeed(result)
        }
        self.state = .Finished
      }).onFailure({ error in
        dispatch_async(dispatch_get_main_queue()) {
          self.decoy.fail(error)
        }
        self.state = .Finished
      })
  }
}