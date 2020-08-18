import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

struct ConditionedCacheSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
}

final class ConditionedCacheSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a conditioned fetch closure") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var cancellable: AnyCancellable?
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedCacheSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
      }
      
      context("when calling get") {
        let value = 221
        var fakeRequest: PassthroughSubject<Int, Error>!
        var successSentinel: Bool?
        var successValue: Int?
        var failureSentinel: Bool?
        var failureValue: Error?
        var cancelSentinel: Bool?
        
        beforeEach {
          failureSentinel = nil
          failureValue = nil
          successSentinel = nil
          successValue = nil
          cancelSentinel = nil
          
          fakeRequest = PassthroughSubject()
          internalCache.getSubject = fakeRequest
        }
        
        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }
        
        context("when the condition is satisfied") {
          let key = "this key works"
          
          beforeEach {
            cancellable = cache.get(key)
              .handleEvents(receiveCancel: { cancelSentinel = true })
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failureSentinel = true
                  failureValue = error
                }
              }, receiveValue: { value in
                successSentinel = true
                successValue = value
              })
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
          }
          
          it("should pass the right key") {
            expect(internalCache.didGetKey).toEventually(equal(key))
          }
          
          context("when the request succeeds") {
            beforeEach {
              fakeRequest.send(value)
            }
            
            it("should call the original closure") {
              expect(successSentinel).toEventuallyNot(beNil())
            }
            
            it("should pass the right value") {
              expect(successValue).toEventually(equal(value))
            }
            
            it("should not call the cancel closure") {
              expect(cancelSentinel).toEventually(beNil())
            }
            
            it("should not call the failure closure") {
              expect(failureSentinel).toEventually(beNil())
            }
          }
          
          context("when the request is canceled") {
            beforeEach {
              cancellable?.cancel()
            }
            
            it("should call the original closure") {
              expect(cancelSentinel).toEventually(beTrue())
            }
            
            it("should not call the success closure") {
              expect(successSentinel).toEventually(beNil())
            }
            
            it("should not call the failure closure") {
              expect(failureSentinel).toEventually(beNil())
            }
          }
          
          context("when the request fails") {
            let errorCode = TestError.simpleError
            
            beforeEach {
              fakeRequest.send(completion: .failure(errorCode))
            }
            
            it("should call the original closure") {
              expect(failureSentinel).toEventuallyNot(beNil())
            }
            
            it("should pass the right error") {
              expect(failureValue as? TestError).toEventually(equal(errorCode))
            }
            
            it("should not call the cancel closure") {
              expect(cancelSentinel).toEventually(beNil())
            }
            
            it("should not call the success closure") {
              expect(successSentinel).toEventually(beNil())
            }
          }
        }
        
        context("when the condition is not satisfied") {
          let key = ":("
          
          beforeEach {
            cancellable = cache.get(key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failureSentinel = true
                  failureValue = error
                }
              }, receiveValue: { value in
                successSentinel = true
                successValue = value
              })
          }
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).toEventually(equal(0))
          }
          
          it("should call the failure closure") {
            expect(failureSentinel).toEventuallyNot(beNil())
          }
          
          it("should pass the provided error") {
            expect(failureValue as? ConditionError).toEventually(equal(ConditionError.MyError))
          }
          
          it("should not call the cancel closure") {
            expect(cancelSentinel).toEventually(beNil())
          }
          
          it("should not call the success closure") {
            expect(successSentinel).toEventually(beNil())
          }
        }
      }
    }
    
    sharedExamples("a conditioned cache") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedCacheSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
      }
      
      itBehavesLike("a conditioned fetch closure") {
        [
          ConditionedCacheSharedExamplesContext.CacheToTest: cache,
          ConditionedCacheSharedExamplesContext.InternalCache: internalCache,
        ]
      }
      
      context("when calling set") {
        let key = "test-key"
        let value = 201
        
        beforeEach {
          _ = cache.set(value, forKey: key).sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledSet).toEventually(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalCache.didSetKey).toEventually(equal(key))
        }
        
        it("should pass the right value") {
          expect(internalCache.didSetValue).toEventually(equal(value))
        }
      }
      
      context("when calling clear") {
        beforeEach {
          cache.clear()
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledClear).toEventually(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          cache.onMemoryWarning()
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }
      }
    }
  }
}

private enum ConditionError: Error {
  case MyError
  case AnotherError
}

final class ConditionedCacheTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    let closure: ((String) -> AnyPublisher<Bool, Error>) = { key in
      if key.count >= 5 {
        return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
      } else {
        return Fail(error: ConditionError.MyError).eraseToAnyPublisher()
      }
    }
    
    describe("The conditioned instance function, applied to a cache level") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.conditioned(closure)
      }
      
      itBehavesLike("a conditioned cache") {
        [
          ConditionedCacheSharedExamplesContext.CacheToTest: cache,
          ConditionedCacheSharedExamplesContext.InternalCache: internalCache
        ]
      }
    }
  }
}
