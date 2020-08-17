import Foundation
//import Quick
//import Nimble
//import Carlos
//import PiedPiper
//
var kCurrentQueue = DispatchSpecificKey<UnsafeMutableRawPointer>()
//
//func getMutablePointer (object: AnyObject) -> UnsafeMutableRawPointer {
//  return UnsafeMutableRawPointer(bitPattern: UInt(bitPattern: ObjectIdentifier(object)))!
//}
//
//struct DispatchedShareExamplesContext {
//  static let CacheToTest = "cache"
//  static let InternalCache = "internalCache"
//  static let QueueToUse = "queue"
//}
//
//class DispatchedSharedExamplesConfiguration: QuickConfiguration {
//  override class func configure(_ configuration: Configuration) {
//    sharedExamples("a dispatched cache") { (sharedExampleContext: @escaping SharedExampleContext) in
//      var cache: BasicCache<String, Int>!
//      var queue: DispatchQueue!
//      var internalCache: CacheLevelFake<String, Int>!
//      
//      beforeEach {
//        cache = sharedExampleContext()[DispatchedShareExamplesContext.CacheToTest] as? BasicCache<String, Int>
//        internalCache = sharedExampleContext()[DispatchedShareExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
//        queue = sharedExampleContext()[DispatchedShareExamplesContext.QueueToUse] as? DispatchQueue
//      }
//      
//      context("when calling get") {
//        var fakeRequest: Promise<Int>!
//        let key = "key_test"
//        var successSentinel: Bool?
//        var failureSentinel: Bool?
//        var successValue: Int?
//        
//        beforeEach {
//          successSentinel = nil
//          failureSentinel = nil
//          successValue = nil
//          
//          fakeRequest = Promise<Int>()
//          internalCache.cacheRequestToReturn = fakeRequest.future
//          
//          cache.get(key).onSuccess({ value in
//            successSentinel = true
//            successValue = value
//          }).onFailure({ _ in
//            failureSentinel = true
//          })
//        }
//        
//        it("should forward the call to the internal cache") {
//          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
//        }
//        
//        it("should pass the right key") {
//          expect(internalCache.didGetKey).toEventually(equal(key))
//        }
//        
//        it("should forward the calls on the right queue") {
//          expect(internalCache.queueUsedForTheLastCall).toEventually(equal(getMutablePointer(object: queue)))
//        }
//        
//        context("when the request succeeds") {
//          let successValuePassed = 10
//          
//          beforeEach {
//            fakeRequest.succeed(successValuePassed)
//          }
//          
//          it("should call the success closure") {
//              expect(successSentinel).toEventuallyNot(beNil())
//          }
//          
//          it("should pass the right value") {
//            expect(successValue).toEventually(equal(successValuePassed))
//          }
//        }
//        
//        context("when the request fails") {
//          beforeEach {
//            fakeRequest.fail(TestError.simpleError)
//          }
//              
//          it("should call the failure closure") {
//            expect(failureSentinel).toEventuallyNot(beNil())
//          }
//        }
//      }
//      
//      context("when calling set") {
//        let key = "test_key"
//        let value = 30
//        var setSucceeded: Bool!
//        var setError: Error?
//        
//        beforeEach {
//          setSucceeded = false
//          setError = nil
//        
//          cache.set(value, forKey: key).onSuccess {
//            setSucceeded = true
//          }.onFailure {
//            setError = $0
//          }
//        }
//        
//        it("should forward it to the internal cache") {
//          expect(internalCache.numberOfTimesCalledSet).toEventually(equal(1))
//        }
//        
//        it("should set the right key") {
//          expect(internalCache.didSetKey).toEventually(equal(key))
//        }
//        
//        it("should set the right value") {
//          expect(internalCache.didSetValue).toEventually(equal(value))
//        }
//        
//        it("should forward the calls on the right queue") {
//          expect(internalCache.queueUsedForTheLastCall).toEventually(equal(getMutablePointer(object: queue)))
//        }
//        
//        //TODO: Find a way to call succeed() and fail(_) after some time to take into account the gcd.async call
//        pending("when set succeeds") {
//          beforeEach {
//            internalCache.setPromisesReturned.first?.succeed(())
//          }
//          
//          it("should succeed") {
//            expect(setSucceeded).toEventually(beTrue())
//          }
//        }
//        
//        pending("when set fails") {
//          let setFailure = TestError.anotherError
//          
//          beforeEach {
//            internalCache.setPromisesReturned.first?.fail(setFailure)
//          }
//          
//          it("should fail") {
//            expect(setError).toEventuallyNot(beNil())
//          }
//          
//          it("should pass the error through") {
//            expect(setError as? TestError).toEventually(equal(setFailure))
//          }
//        }
//      }
//      
//      context("when calling onMemoryWarning") {
//        beforeEach {
//          cache.onMemoryWarning()
//        }
//        
//        it("should forward it to the internal cache") {
//          expect(internalCache.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
//        }
//        
//        it("should forward the calls on the right queue") {
//          expect(internalCache.queueUsedForTheLastCall).toEventually(equal(getMutablePointer(object: queue)))
//        }
//      }
//      
//      context("when calling clear") {
//        beforeEach {
//          cache.clear()
//        }
//        
//        it("should forward it to the internal cache") {
//          expect(internalCache.numberOfTimesCalledClear).toEventually(equal(1))
//        }
//        
//        it("should forward the calls on the right queue") {
//          expect(internalCache.queueUsedForTheLastCall).toEventually(equal(getMutablePointer(object: queue)))
//        }
//      }
//    }
//  }
//}
//
func currentQueueSpecific() -> UnsafeMutableRawPointer! {
  return DispatchQueue.getSpecific(key: kCurrentQueue)
}
//
//class DispatchedCacheTests: QuickSpec {
//  var queue: DispatchQueue!
//  
//  override func spec() {
//    var cache: CacheLevelFake<String, Int>!
//    var composedCache: BasicCache<String, Int>!
//    
//    beforeSuite {
//      self.queue = DispatchQueue(label: "Test queue", attributes: .concurrent)
//      self.queue.setSpecific(key: kCurrentQueue, value: getMutablePointer(object: self.queue))
//    }
//    
//    describe("Dispatched cache obtained through the protocol extension") {
//      beforeEach {
//        cache = CacheLevelFake()
//        composedCache = cache.dispatch(self.queue)
//      }
//      
//      itBehavesLike("a dispatched cache") {
//        [
//          DispatchedShareExamplesContext.CacheToTest: composedCache,
//          DispatchedShareExamplesContext.InternalCache: cache,
//          DispatchedShareExamplesContext.QueueToUse: self.queue
//        ]
//      }
//    }
//  }
//}
