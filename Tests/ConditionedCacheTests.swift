import Foundation
import Quick
import Nimble
import Carlos
import PiedPiper

struct ConditionedCacheSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
}

class ConditionedCacheSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a conditioned fetch closure") { (sharedExampleContext: SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedCacheSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
      }
      
      context("when calling get") {
        let value = 221
        var fakeRequest: Promise<Int>!
        var successSentinel: Bool?
        var successValue: Int?
        var failureSentinel: Bool?
        var failureValue: ErrorType?
        var cancelSentinel: Bool?
        
        beforeEach {
          failureSentinel = nil
          failureValue = nil
          successSentinel = nil
          successValue = nil
          cancelSentinel = nil
          
          fakeRequest = Promise<Int>()
          internalCache.cacheRequestToReturn = fakeRequest.future
        }
        
        context("when the condition is satisfied") {
          let key = "this key works"
          
          beforeEach {
            cache.get(key).onSuccess { success in
              successSentinel = true
              successValue = value
            }.onFailure { error in
              failureValue = error
              failureSentinel = true
            }.onCancel {
              cancelSentinel = true
            }
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
            
            it("should not call the cancel closure") {
              expect(cancelSentinel).to(beNil())
            }
            
            it("should not call the failure closure") {
              expect(failureSentinel).to(beNil())
            }
          }
          
          context("when the request is canceled") {
            beforeEach {
              fakeRequest.cancel()
            }
            
            it("should call the original closure") {
              expect(cancelSentinel).to(beTrue())
            }
            
            it("should not call the success closure") {
              expect(successSentinel).to(beNil())
            }
            
            it("should not call the failure closure") {
              expect(failureSentinel).to(beNil())
            }
          }
          
          context("when the request fails") {
            let errorCode = TestError.SimpleError
            
            beforeEach {
              fakeRequest.fail(errorCode)
            }
            
            it("should call the original closure") {
              expect(failureSentinel).notTo(beNil())
            }
            
            it("should pass the right error") {
              expect(failureValue as? TestError).to(equal(errorCode))
            }
            
            it("should not call the cancel closure") {
              expect(cancelSentinel).to(beNil())
            }
            
            it("should not call the success closure") {
              expect(successSentinel).to(beNil())
            }
          }
        }
        
        context("when the condition is not satisfied") {
          let key = ":("
          
          beforeEach {
            cache.get(key).onSuccess { success in
              successSentinel = true
              successValue = value
            }.onFailure { error in
              failureValue = error
              failureSentinel = true
            }
          }
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).to(equal(0))
          }
          
          it("should call the failure closure") {
            expect(failureSentinel).notTo(beNil())
          }
          
          it("should pass the provided error") {
            expect(failureValue as? ConditionError).to(equal(ConditionError.MyError))
          }
          
          it("should not call the cancel closure") {
            expect(cancelSentinel).to(beNil())
          }
          
          it("should not call the success closure") {
            expect(successSentinel).to(beNil())
          }
        }
      }
    }
    
    sharedExamples("a conditioned cache") { (sharedExampleContext: SharedExampleContext) in
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

private enum ConditionError: ErrorType {
  case MyError
  case AnotherError
}

class ConditionedCacheTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    let closure: (String -> Future<Bool>) = { key in
      if key.characters.count >= 5 {
        return Promise(value: true).future
      } else {
        return Promise(error: ConditionError.MyError).future
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
    
    describe("The conditioned function, applied to a cache level") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = conditioned(internalCache, condition: closure)
      }
      
      itBehavesLike("a conditioned cache") {
        [
          ConditionedCacheSharedExamplesContext.CacheToTest: cache,
          ConditionedCacheSharedExamplesContext.InternalCache: internalCache
        ]
      }
    }
    
    describe("The conditioned cache operator, applied to a cache level") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = closure <?> internalCache
      }
      
      itBehavesLike("a conditioned cache") {
        [
          ConditionedCacheSharedExamplesContext.CacheToTest: cache,
          ConditionedCacheSharedExamplesContext.InternalCache: internalCache
        ]
      }
    }
    
    describe("The conditioned function, applied to a fetch closure") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = conditioned(internalCache.get, condition: closure)
      }
      
      itBehavesLike("a conditioned fetch closure") {
        [
          ConditionedCacheSharedExamplesContext.CacheToTest: cache,
          ConditionedCacheSharedExamplesContext.InternalCache: internalCache
        ]
      }
    }
    
    describe("The conditioned cache operator, applied to a fetch closure") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = closure <?> internalCache.get
      }
      
      itBehavesLike("a conditioned fetch closure") {
        [
          ConditionedCacheSharedExamplesContext.CacheToTest: cache,
          ConditionedCacheSharedExamplesContext.InternalCache: internalCache
        ]
      }
    }
  }
}