import Foundation
import Quick
import Nimble
import Carlos
import PiedPiper

struct PoolCacheSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
}

class PoolCacheSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a pooled cache") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: PoolCache<CacheLevelFake<String, Int>>!
      var internalCache: CacheLevelFake<String, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[PoolCacheSharedExamplesContext.CacheToTest] as? PoolCache<CacheLevelFake<String, Int>>
        internalCache = sharedExampleContext()[PoolCacheSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
      }
      
      context("when calling get") {
        var fakeRequest: Promise<Int>!
        let key = "key_test"
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var successValue: Int?
        
        beforeEach {
          successSentinel = nil
          failureSentinel = nil
          successValue = nil
          
          fakeRequest = Promise<Int>()
          internalCache.cacheRequestToReturn = fakeRequest.future
          
          cache.get(key).onSuccess({ value in
            successSentinel = true
            successValue = value
          }).onFailure({ _ in
            failureSentinel = true
          })
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalCache.didGetKey).to(equal(key))
        }
        
        context("as long as the request doesn't succeed or fail, when other requests with different keys are made") {
          var fakeRequest2: Promise<Int>!
          let otherKey = "key_test_2"
          
          beforeEach {
            fakeRequest2 = Promise<Int>()
            internalCache.cacheRequestToReturn = fakeRequest2.future
            
            _ = cache.get(otherKey)
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).to(equal(2))
          }
          
          it("should pass the right key") {
            expect(internalCache.didGetKey).to(equal(otherKey))
          }
          
          context("as long as the request doesn't succeed or fail, when other requests with the same key are made") {
            beforeEach {
              _ = cache.get(otherKey)
            }
            
            it("should not forward the call to the internal cache") {
              expect(internalCache.numberOfTimesCalledGet).to(equal(2))
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
              cache.get(key).onSuccess({ value in
                otherSuccessSentinels[currentIndex] = true
                otherSuccessValues[currentIndex] = value
              }).onFailure({ _ in
                otherFailureSentinels[currentIndex] = true
              })
            }
          }
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).to(equal(1))
          }
          
          context("when the first request succeeds") {
            let successValuePassed = 10
            
            beforeEach {
              fakeRequest.succeed(successValuePassed)
            }
            
            it("should call the closure on the first request") {
              expect(successSentinel).notTo(beNil())
            }
            
            it("should pass the right value on the first request") {
              expect(successValue).to(equal(successValuePassed))
            }
            
            it("should call the closure on the other requests") {
              expect(otherSuccessSentinels).to(allPass({ $0 != nil }))
            }
            
            it("should pass the right value on the other requests") {
              expect(otherSuccessValues).to(allPass({ $0! == successValuePassed }))
            }
            
            it("should not call get on the internal cache") {
              expect(internalCache.numberOfTimesCalledGet).to(equal(1))
            }
            
            context("when other requests are done") {
              beforeEach {
                _ = cache.get(key)
              }
              
              it("should forward the call to the internal cache") {
                expect(internalCache.numberOfTimesCalledGet).to(equal(2))
              }
            }
          }
          
          context("when the first request fails") {
            beforeEach {
              fakeRequest.fail(TestError.simpleError)
            }
            
            it("should call the closure on the first request") {
              expect(failureSentinel).notTo(beNil())
            }
            
            it("should call the closure on the other requests") {
              expect(otherFailureSentinels).to(allPass({ $0 != nil }))
            }
            
            it("should not call get on the internal cache") {
              expect(internalCache.numberOfTimesCalledGet).to(equal(1))
            }
            
            context("when other requests are done") {
              beforeEach {
                _ = cache.get(key)
              }
              
              it("should forward the call to the internal cache") {
                expect(internalCache.numberOfTimesCalledGet).to(equal(2))
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
        
          cache.set(value, forKey: key).onSuccess {
            setSucceeded = true
          }.onFailure {
            setError = $0
          }
        }
        
        it("should forward it to the internal cache") {
          expect(internalCache.numberOfTimesCalledSet).to(equal(1))
        }
        
        it("should set the right key") {
          expect(internalCache.didSetKey).to(equal(key))
        }
        
        it("should set the right value") {
          expect(internalCache.didSetValue).to(equal(value))
        }
        
        context("when set succeeds") {
          beforeEach {
            internalCache.setPromisesReturned.first?.succeed()
          }
          
          it("should succeed") {
            expect(setSucceeded).to(beTrue())
          }
        }
        
        context("when set fails") {
          let setFailure = TestError.anotherError
          
          beforeEach {
            internalCache.setPromisesReturned.first?.fail(setFailure)
          }
          
          it("should fail") {
            expect(setError).notTo(beNil())
          }
          
          it("should pass the error through") {
            expect(setError as? TestError).to(equal(setFailure))
          }
        }
        
        context("when calling it multiple times") {
          beforeEach {
            cache.set(value, forKey: key)
            cache.set(value, forKey: key)
          }
          
          it("should not pool these calls") {
            expect(internalCache.numberOfTimesCalledSet).to(equal(3))
          }
        }
      }
      
      context("when calling clear") {
        beforeEach {
          cache.clear()
        }
        
        it("should forward it to the internal cache") {
          expect(internalCache.numberOfTimesCalledClear).to(equal(1))
        }
        
        context("when calling it multiple times") {
          beforeEach {
            cache.clear()
            cache.clear()
          }
          
          it("should not pool these calls") {
            expect(internalCache.numberOfTimesCalledClear).to(equal(3))
          }
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          cache.onMemoryWarning()
        }
        
        it("should forward it to the internal cache") {
          expect(internalCache.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
        
        context("when calling it multiple times") {
          beforeEach {
            cache.onMemoryWarning()
            cache.onMemoryWarning()
          }
          
          it("should not pool these calls") {
            expect(internalCache.numberOfTimesCalledOnMemoryWarning).to(equal(3))
          }
        }
      }
    }
  }
}

class PoolCacheTests: QuickSpec {
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
