import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

var kCurrentQueue = DispatchSpecificKey<UnsafeMutableRawPointer>()

func getMutablePointer (object: AnyObject) -> UnsafeMutableRawPointer {
  return UnsafeMutableRawPointer(bitPattern: UInt(bitPattern: ObjectIdentifier(object)))!
}

struct DispatchedShareExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let QueueToUse = "queue"
}

final class DispatchedSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a dispatched cache") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var queue: DispatchQueue!
      var internalCache: CacheLevelFake<String, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[DispatchedShareExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[DispatchedShareExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        queue = sharedExampleContext()[DispatchedShareExamplesContext.QueueToUse] as? DispatchQueue
      }
      
      context("when calling get") {
        var fakeRequest: PassthroughSubject<Int, Error>!
        let key = "key_test"
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var successValue: Int?
        var cancellable: AnyCancellable?
        
        beforeEach {
          successSentinel = nil
          failureSentinel = nil
          successValue = nil
          
          fakeRequest = PassthroughSubject()
          internalCache.getSubject = fakeRequest
          
          cancellable = cache.get(key)
            .sink(receiveCompletion: { completion in
              if case .failure = completion {
                failureSentinel = true
              }
            }, receiveValue: { value in
              successSentinel = true
              successValue = value
            })
        }
        
        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
        }

        it("should pass the right key") {
          expect(internalCache.didGetKey).toEventually(equal(key))
        }

        it("should forward the calls on the right queue") {
          expect(internalCache.queueUsedForTheLastCall).toEventually(equal(getMutablePointer(object: queue)))
        }

        context("when the request succeeds") {
          let successValuePassed = 10
          
          beforeEach {
            fakeRequest.send(successValuePassed)
          }
          
          it("should call the success closure") {
            expect(successSentinel).toEventuallyNot(beNil())
          }

          it("should pass the right value") {
            expect(successValue).toEventually(equal(successValuePassed))
          }
        }
        
        context("when the request fails") {
          beforeEach {
            fakeRequest.send(completion: .failure(TestError.simpleError))
          }

          it("should call the failure closure") {
            expect(failureSentinel).toEventuallyNot(beNil())
          }
        }
      }
      
      context("when calling set") {
        let key = "test_key"
        let value = 30
        var setSucceeded: Bool!
        var setError: Error?
        var cancellable: AnyCancellable?

        beforeEach {
          setSucceeded = false
          setError = nil

          cancellable = cache.set(value, forKey: key)
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                setError = error
              }
            }, receiveValue: { value in
              setSucceeded = true
            })
        }

        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }

        it("should forward it to the internal cache") {
          expect(internalCache.numberOfTimesCalledSet).toEventually(equal(1))
        }

        it("should set the right key") {
          expect(internalCache.didSetKey).toEventually(equal(key))
        }

        it("should set the right value") {
          expect(internalCache.didSetValue).toEventually(equal(value))
        }

        it("should forward the calls on the right queue") {
          expect(internalCache.queueUsedForTheLastCall).toEventually(equal(getMutablePointer(object: queue)))
        }

        //TODO: Find a way to call succeed() and fail(_) after some time to take into account the gcd.async call
        pending("when set succeeds") {
          beforeEach {
            internalCache.setPublishers[key]?.send()
          }

          it("should succeed") {
            expect(setSucceeded).toEventually(beTrue())
          }
        }

        pending("when set fails") {
          let setFailure = TestError.anotherError

          beforeEach {
            internalCache.setPublishers[key]?.send(completion: .failure(setFailure))
          }

          it("should fail") {
            expect(setError).toEventuallyNot(beNil())
          }

          it("should pass the error through") {
            expect(setError as? TestError).toEventually(equal(setFailure))
          }
        }
      }

      context("when calling onMemoryWarning") {
        beforeEach {
          cache.onMemoryWarning()
        }

        it("should forward it to the internal cache") {
          expect(internalCache.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }

        it("should forward the calls on the right queue") {
          expect(internalCache.queueUsedForTheLastCall).toEventually(equal(getMutablePointer(object: queue)))
        }
      }

      context("when calling clear") {
        beforeEach {
          cache.clear()
        }

        it("should forward it to the internal cache") {
          expect(internalCache.numberOfTimesCalledClear).toEventually(equal(1))
        }

        it("should forward the calls on the right queue") {
          expect(internalCache.queueUsedForTheLastCall).toEventually(equal(getMutablePointer(object: queue)))
        }
      }
    }
  }
}

func currentQueueSpecific() -> UnsafeMutableRawPointer! {
  return DispatchQueue.getSpecific(key: kCurrentQueue)
}

final class DispatchedCacheTests: QuickSpec {
  var queue: DispatchQueue!
  
  override func spec() {
    var cache: CacheLevelFake<String, Int>!
    var composedCache: BasicCache<String, Int>!
    
    beforeSuite {
      self.queue = DispatchQueue(label: "Test queue", attributes: .concurrent)
      self.queue.setSpecific(key: kCurrentQueue, value: getMutablePointer(object: self.queue))
    }
    
    describe("Dispatched cache obtained through the protocol extension") {
      beforeEach {
        cache = CacheLevelFake()
        composedCache = cache.dispatch(self.queue)
      }
      
      itBehavesLike("a dispatched cache") {
        [
          DispatchedShareExamplesContext.CacheToTest: composedCache,
          DispatchedShareExamplesContext.InternalCache: cache,
          DispatchedShareExamplesContext.QueueToUse: self.queue
        ]
      }
    }
  }
}
