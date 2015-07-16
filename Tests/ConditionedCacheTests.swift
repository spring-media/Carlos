import Foundation
import Quick
import Nimble
import Carlos

private struct ConditionedCacheSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let ErrorCode = "errorCode"
}

class ConditionedCacheSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a conditioned cache") { (sharedExampleContext: SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var errorCode: Int!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedCacheSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        errorCode = sharedExampleContext()[ConditionedCacheSharedExamplesContext.ErrorCode] as? Int
      }
      
      context("when calling get") {
        let value = 221
        var fakeRequest: CacheRequest<Int>!
        var successSentinel: Bool?
        var successValue: Int?
        var failureSentinel: Bool?
        var failureValue: NSError?
        
        beforeEach {
          fakeRequest = CacheRequest<Int>()
          internalCache.cacheRequestToReturn = fakeRequest
        }
        
        context("when the condition is satisfied") {
          let key = "this key works"
          
          beforeEach {
            cache.get(key).onSuccess({ success in
              successSentinel = true
              successValue = value
            }).onFailure({ error in
              failureValue = error
              failureSentinel = true
            })
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).to(equal(1))
          }
          
          it("should pass the right key") {
            expect(internalCache.didGetKey).to(equal(key))
          }
          
          context("when the request succeeds") {
            beforeEach {
              fakeRequest.succeed(value)
            }
            
            it("should call the original closure") {
              expect(successSentinel).notTo(beNil())
            }
            
            it("should pass the right value") {
              expect(successValue).to(equal(value))
            }
          }
          
          context("when the request fails") {
            let errorCode = -230
            
            beforeEach {
              fakeRequest.fail(NSError(domain: "test", code: errorCode, userInfo: nil))
            }
            
            it("should call the original closure") {
              expect(failureSentinel).notTo(beNil())
            }
            
            it("should pass the right error") {
              expect(failureValue?.code).to(equal(errorCode))
            }
          }
        }
        
        context("when the condition is not satisfied") {
          let key = ":("
          
          beforeEach {
            cache.get(key).onSuccess({ success in
              successSentinel = true
              successValue = value
            }).onFailure({ error in
              failureValue = error
              failureSentinel = true
            })
          }
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).to(equal(0))
          }
          
          it("should call the failure closure") {
            expect(failureSentinel).notTo(beNil())
          }
          
          it("should pass the provided error") {
            expect(failureValue?.code).to(equal(errorCode))
          }
        }
      }
      
      context("when calling set") {
        let key = "test-key"
        let value = 201
        
        beforeEach {
          cache.set(value, forKey: key)
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledSet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalCache.didSetKey).to(equal(key))
        }
        
        it("should pass the right value") {
          expect(internalCache.didSetValue).to(equal(value))
        }
      }
      
      context("when calling clear") {
        beforeEach {
          cache.clear()
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledClear).to(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          cache.onMemoryWarning()
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
      }
    }
  }
}

class ConditionedCacheTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    let errorCode = 101
    
    describe("The conditioned function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = conditioned(internalCache, { key in
          return (count(key) >= 5, NSError(domain: "Test", code: errorCode, userInfo: nil))
        })
      }
      
      itBehavesLike("a conditioned cache") {
        [
          ConditionedCacheSharedExamplesContext.CacheToTest: cache,
          ConditionedCacheSharedExamplesContext.InternalCache: internalCache,
          ConditionedCacheSharedExamplesContext.ErrorCode: errorCode
        ]
      }
    }
    
    describe("The conditioned cache operator") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = { key in
          return (count(key) >= 5, NSError(domain: "Test", code: errorCode, userInfo: nil))
          } <?> internalCache
      }
      
      itBehavesLike("a conditioned cache") {
        [
          ConditionedCacheSharedExamplesContext.CacheToTest: cache,
          ConditionedCacheSharedExamplesContext.InternalCache: internalCache,
          ConditionedCacheSharedExamplesContext.ErrorCode: errorCode
        ]
      }
    }
  }
}