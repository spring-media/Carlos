import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

struct PoolCacheSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
}

final class PoolCacheSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a pooled cache") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: PoolCache<CacheLevelFake<String, Int>>!
      var internalCache: CacheLevelFake<String, Int>!
      var cancellables: Set<AnyCancellable>!
      
      beforeEach {
        cancellables = Set()
        cache = sharedExampleContext()[PoolCacheSharedExamplesContext.CacheToTest] as? PoolCache<CacheLevelFake<String, Int>>
        internalCache = sharedExampleContext()[PoolCacheSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
      }
      
      afterEach {
        cancellables = nil
      }
      
      context("when calling get") {
        var fakeRequest: PassthroughSubject<Int, Error>!
        let key = "key_test"
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var successValue: Int?
        
        beforeEach {
          successSentinel = nil
          failureSentinel = nil
          successValue = nil
          
          fakeRequest = PassthroughSubject()
          internalCache.getSubject = fakeRequest
          
          cache.get(key).sink(receiveCompletion: { completion in
            if case .failure = completion {
              failureSentinel = true
            }
          }, receiveValue: { value in
            successSentinel = true
            successValue = value
          })
          .store(in: &cancellables)
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalCache.didGetKey).toEventually(equal(key))
        }
        
        context("as long as the request doesn't succeed or fail, when other requests with different keys are made") {
          var fakeRequest2: PassthroughSubject<Int, Error>!
          let otherKey = "key_test_2"
          
          beforeEach {
            fakeRequest2 = PassthroughSubject()
            internalCache.getSubject = fakeRequest2
            
            cache.get(otherKey)
              .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
              .store(in: &cancellables)
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).toEventually(equal(2))
          }
          
          it("should pass the right key") {
            expect(internalCache.didGetKey).toEventually(equal(otherKey))
          }
          
          context("as long as the request doesn't succeed or fail, when other requests with the same key are made") {
            beforeEach {
              cache.get(otherKey)
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &cancellables)
            }
            
            it("should not forward the call to the internal cache") {
              expect(internalCache.numberOfTimesCalledGet).toEventually(equal(2))
            }
          }
        }
        
        context("as long as the request doesn't succeed or fail, when other requests with the same key are made") {
          var otherSuccessSentinels: [Bool?]!
          var otherFailureSentinels: [Bool?]!
          var otherSuccessValues: [Int?]!
          let numberOfOtherRequests = 2
          
          beforeEach {
            otherSuccessSentinels = []
            otherFailureSentinels = []
            otherSuccessValues = []
            
            for _ in 0..<numberOfOtherRequests {
              otherSuccessSentinels.append(nil)
              otherFailureSentinels.append(nil)
              otherSuccessValues.append(nil)
              let currentIndex = otherSuccessValues.count - 1
              cache.get(key).sink(receiveCompletion: { completion in
                if case .failure = completion {
                  otherFailureSentinels[currentIndex] = true
                }
              }, receiveValue: { value in
                otherSuccessSentinels[currentIndex] = true
                otherSuccessValues[currentIndex] = value
              }).store(in: &cancellables)
            }
          }
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
          }
          
          context("when the first request succeeds") {
            let successValuePassed = 10
            
            beforeEach {
              fakeRequest.send(successValuePassed)
            }
            
            it("should call the closure on the first request") {
              expect(successSentinel).toEventuallyNot(beNil())
            }
            
            it("should pass the right value on the first request") {
              expect(successValue).toEventually(equal(successValuePassed))
            }
            
            it("should call the closure on the other requests") {
              expect(otherSuccessSentinels).toEventually(allPass({ $0 != nil }))
            }
            
            it("should pass the right value on the other requests") {
              expect(otherSuccessValues).toEventually(allPass({ $0! == successValuePassed }))
            }
            
            it("should not call get on the internal cache") {
              expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
            }
          }
          
          context("when the first request fails") {
            beforeEach {
              fakeRequest.send(completion: .failure(TestError.simpleError))
            }
            
            it("should call the closure on the first request") {
              expect(failureSentinel).toEventuallyNot(beNil())
            }
            
            it("should call the closure on the other requests") {
              expect(otherFailureSentinels).toEventually(allPass({ $0 != nil }))
            }
            
            it("should not call get on the internal cache") {
              expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
            }
            
            context("when other requests are done") {
              beforeEach {
                cache.get(key)
                  .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                  .store(in: &cancellables)
              }
              
              it("should forward the call to the internal cache") {
                expect(internalCache.numberOfTimesCalledGet).toEventually(equal(2))
              }
            }
          }
        }
      }
      
      context("when calling set") {
        let key = "test_key"
        let value = 30
        var setSucceeded: Bool!
        var setError: Error?

        beforeEach {
          setSucceeded = false
          setError = nil

          cache.set(value, forKey: key)
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                setError = error
              }
            }, receiveValue: { setSucceeded = true })
            .store(in: &cancellables)
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

        context("when set succeeds") {
          beforeEach {
            internalCache.setPublishers[key]?.send()
          }

          it("should succeed") {
            expect(setSucceeded).toEventually(beTrue())
          }
        }

        context("when set fails") {
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

        context("when calling it multiple times") {
          beforeEach {
            cache.set(value, forKey: key)
              .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
              .store(in: &cancellables)
            cache.set(value, forKey: key)
              .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
              .store(in: &cancellables)
          }

          it("should not pool these calls") {
            expect(internalCache.numberOfTimesCalledSet).toEventually(equal(3))
          }
        }
      }

      context("when calling clear") {
        beforeEach {
          cache.clear()
        }

        it("should forward it to the internal cache") {
          expect(internalCache.numberOfTimesCalledClear).toEventually(equal(1))
        }

        context("when calling it multiple times") {
          beforeEach {
            cache.clear()
            cache.clear()
          }

          it("should not pool these calls") {
            expect(internalCache.numberOfTimesCalledClear).toEventually(equal(3))
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

        context("when calling it multiple times") {
          beforeEach {
            cache.onMemoryWarning()
            cache.onMemoryWarning()
          }

          it("should not pool these calls") {
            expect(internalCache.numberOfTimesCalledOnMemoryWarning).toEventually(equal(3))
          }
        }
      }
    }
  }
}

final class PoolCacheTests: QuickSpec {
  override func spec() {
    var cache: PoolCache<CacheLevelFake<String, Int>>!
    var internalCache: CacheLevelFake<String, Int>!
    
    describe("PoolCache") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = PoolCache<CacheLevelFake<String, Int>>(internalCache: internalCache)
      }
      
      itBehavesLike("a pooled cache") {
        [
          PoolCacheSharedExamplesContext.CacheToTest: cache,
          PoolCacheSharedExamplesContext.InternalCache: internalCache
        ]
      }
    }
        
    describe("The pooled instance function, applied to a cache level") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.pooled()
      }
      
      itBehavesLike("a pooled cache") {
        [
          PoolCacheSharedExamplesContext.CacheToTest: cache,
          PoolCacheSharedExamplesContext.InternalCache: internalCache
        ]
      }
    }
  }
}
