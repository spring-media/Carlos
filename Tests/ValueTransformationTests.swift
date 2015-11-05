import Foundation
import Quick
import Nimble
import Carlos

struct ValueTransformationsSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

class ValueTransformationSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a cache with transformed values") { (sharedExampleContext: SharedExampleContext) in
      var cache: BasicCache<String, String>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: TwoWayTransformationBox<Int, String>!
      
      beforeEach {
        cache = sharedExampleContext()[ValueTransformationsSharedExamplesContext.CacheToTest] as? BasicCache<String, String>
        internalCache = sharedExampleContext()[ValueTransformationsSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ValueTransformationsSharedExamplesContext.Transformer] as? TwoWayTransformationBox<Int, String>
      }
      
      context("when calling get") {
        let key = "12"
        var successValue: String?
        var failureValue: ErrorType?
        var fakeRequest: Promise<Int>!
        
        beforeEach {
          fakeRequest = Promise<Int>()
          internalCache.cacheRequestToReturn = fakeRequest.future
          
          cache.get(key).onSuccess { successValue = $0 }.onFailure { failureValue = $0 }
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalCache.didGetKey).to(equal(key))
        }
        
        context("when the request succeeds") {
          context("when the value can be successfully transformed") {
            let value = 101
            
            beforeEach {
              fakeRequest.succeed(value)
            }
            
            it("should call the original success closure") {
              expect(successValue).notTo(beNil())
            }
            
            it("should transform the value") {
              var expected: String!
              transformer.transform(value).onSuccess { expected = $0 }
              expect(successValue).to(equal(expected))
            }
          }
          
          context("when the value transformation returns nil") {
            let value = -101
            
            beforeEach {
              successValue = nil
              fakeRequest.succeed(value)
            }
            
            it("should not call the original success closure") {
              expect(successValue).to(beNil())
            }
            
            it("should call the original failure closure") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail with the right code") {
              expect(failureValue as? TestError).to(equal(TestError.AnotherError))
            }
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.AnotherError
          
          beforeEach {
            fakeRequest.fail(errorCode)
          }
          
          it("should call the original failure closure") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail with the right code") {
            expect(failureValue as? TestError).to(equal(errorCode))
          }
        }
      }
      
      context("when calling set") {
        context("when the inverse transformation succeeds") {
          let key = "test key to set"
          let value = "199"
          
          beforeEach {
            cache.set(value, forKey: key)
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).to(equal(1))
          }
          
          it("should pass the key") {
            expect(internalCache.didSetKey).to(equal(key))
          }
          
          it("should transform the value first") {
            var expected: Int!
            transformer.inverseTransform(value).onSuccess { expected = $0 }
            expect(internalCache.didSetValue).to(equal(expected))
          }
        }
        
        context("when the inverse transformation fails") {
          let key = "test key to set"
          let value = "will fail"
          
          beforeEach {
            cache.set(value, forKey: key)
          }
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).to(equal(0))
          }
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

class ValueTransformationTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, String>!
    var internalCache: CacheLevelFake<String, Int>!
    var transformer: TwoWayTransformationBox<Int, String>!
    let forwardTransformationClosure: Int -> Future<String> = {
      let result = Promise<String>()
      if $0 > 0 {
        result.succeed("\($0 + 1)")
      } else {
        result.fail(TestError.AnotherError)
      }
      return result.future
    }
    let inverseTransformationClosure: String -> Future<Int> = {
      return Promise(value: Int($0), error: TestError.AnotherError).future
    }
    
    describe("Value transformation using a transformer and a cache, with the global function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = TwoWayTransformationBox(transform: forwardTransformationClosure, inverseTransform: inverseTransformationClosure)
        cache = transformValues(internalCache, transformer: transformer)
      }
      
      itBehavesLike("a cache with transformed values") {
        [
          ValueTransformationsSharedExamplesContext.CacheToTest: cache,
          ValueTransformationsSharedExamplesContext.InternalCache: internalCache,
          ValueTransformationsSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Value transformation using a transformer and a cache, with the instance function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = TwoWayTransformationBox(transform: forwardTransformationClosure, inverseTransform: inverseTransformationClosure)
        cache = internalCache.transformValues(transformer)
      }
      
      itBehavesLike("a cache with transformed values") {
        [
          ValueTransformationsSharedExamplesContext.CacheToTest: cache,
          ValueTransformationsSharedExamplesContext.InternalCache: internalCache,
          ValueTransformationsSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Value transformation using a transformer and a cache, with the operator") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = TwoWayTransformationBox(transform: forwardTransformationClosure, inverseTransform: inverseTransformationClosure)
        cache = internalCache =>> transformer
      }
      
      itBehavesLike("a cache with transformed values") {
        [
          ValueTransformationsSharedExamplesContext.CacheToTest: cache,
          ValueTransformationsSharedExamplesContext.InternalCache: internalCache,
          ValueTransformationsSharedExamplesContext.Transformer: transformer
        ]
      }
    }
  }
}