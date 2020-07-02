import Foundation
import Quick
import Nimble
import Carlos
import PiedPiper

struct ConditionedPostProcessSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

class ConditionedPostProcessSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a fetch closure with conditioned post-processing") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: ConditionedOneWayTransformationBox<String, Int, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.Transformer] as? ConditionedOneWayTransformationBox<String, Int, Int>
      }
      
      context("when calling get with a key that triggers some post-processing") {
        let key = "do"
        var successValue: Int?
        var failureValue: Error?
        var fakeRequest: Promise<Int>!
        
        beforeEach {
          fakeRequest = Promise<Int>()
          internalCache.cacheRequestToReturn = fakeRequest.future
          successValue = nil
          failureValue = nil
          
          cache.get(key).onSuccess { successValue = $0 }.onFailure { failureValue = $0 }
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should forward the key") {
          expect(internalCache.didGetKey).to(equal(key))
        }
        
        context("when the request succeeds") {
          let value = 101
          
          beforeEach {
            fakeRequest.succeed(value)
          }
          
          it("should call the transformation closure with the right value") {
            var expected: Int!
            transformer.conditionalTransform(key: key, value: value).onSuccess { expected = $0 }
            expect(successValue).to(equal(expected))
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.simpleError
          
          beforeEach {
            fakeRequest.fail(errorCode)
          }
          
          it("should call the original failure closure") {
            expect(failureValue as? TestError).to(equal(errorCode))
          }
        }
      }
      
      context("when calling get with a key that triggers failure on the post-processing") {
        let key = "don't"
        var successValue: Int?
        var failureValue: Error?
        var fakeRequest: Promise<Int>!
        
        beforeEach {
          fakeRequest = Promise<Int>()
          internalCache.cacheRequestToReturn = fakeRequest.future
          successValue = nil
          failureValue = nil
          
          cache.get(key).onSuccess { successValue = $0 }.onFailure { failureValue = $0 }
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should forward the key") {
          expect(internalCache.didGetKey).to(equal(key))
        }
        
        context("when the request succeeds") {
          let value = -101
          
          beforeEach {
            fakeRequest.succeed(value)
          }
          
          it("should not call the original success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should call the original failure closure") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should pass the right error code") {
            expect(failureValue as? TestError).to(equal(TestError.anotherError))
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.simpleError
          
          beforeEach {
            fakeRequest.fail(errorCode)
          }
          
          it("should call the original failure closure") {
            expect(failureValue as? TestError).to(equal(errorCode))
          }
        }
      }
      
      context("when calling get") {
        let key = "12"
        var successValue: Int?
        var failureValue: Error?
        var fakeRequest: Promise<Int>!
        
        beforeEach {
          fakeRequest = Promise<Int>()
          internalCache.cacheRequestToReturn = fakeRequest.future
          successValue = nil
          failureValue = nil
          
          cache.get(key).onSuccess { successValue = $0 }.onFailure { failureValue = $0 }
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should forward the key") {
          expect(internalCache.didGetKey).to(equal(key))
        }
        
        context("when the request succeeds") {
          context("when the transformation closure returns a value") {
            let value = 101
            
            beforeEach {
              fakeRequest.succeed(value)
            }
            
            it("should call the transformation closure with the success value") {
              var expected: Int!
              transformer.conditionalTransform(key: key, value: value).onSuccess { expected = $0 }
              expect(successValue).to(equal(expected))
            }
          }
          
          context("when the transformation closure returns nil") {
            let value = -101
            
            beforeEach {
              fakeRequest.succeed(value)
            }
            
            it("should not call the original success closure") {
              expect(successValue).to(beNil())
            }
            
            it("should call the original failure closure") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should pass the right error code") {
              expect(failureValue as? TestError).to(equal(TestError.simpleError))
            }
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.anotherError
          
          beforeEach {
            fakeRequest.fail(errorCode)
          }
          
          it("should call the original failure closure") {
            expect(failureValue as? TestError).to(equal(errorCode))
          }
        }
      }
    }
    
    sharedExamples("a cache with conditioned post-processing") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: ConditionedOneWayTransformationBox<String, Int, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.Transformer] as? ConditionedOneWayTransformationBox<String, Int, Int>
      }
      
      itBehavesLike("a fetch closure with conditioned post-processing") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache,
          ConditionedPostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
      
      context("when calling set") {
        let key = "10"
        let value = 222
        
        beforeEach {
          _ = cache.set(value, forKey: key)
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledSet).to(equal(1))
        }
        
        it("should forward the key") {
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

class ConditionedOutputPostProcessingTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    let transformer: ConditionedOneWayTransformationBox<String, Int, Int> = ConditionedOneWayTransformationBox(conditionalTransformClosure: { (key, value) in
      let result = Promise<Int>()
      
      if key == "do" {
        result.succeed(value * 2)
      } else if key == "don't" {
        result.fail(TestError.anotherError)
      } else {
        if value > 0 {
          result.succeed(value)
        } else {
          result.fail(TestError.simpleError)
        }
      }
      
      return result.future
    })
    
    describe("Conditioned post processing on a CacheLevel with the protocol extension") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.conditionedPostProcess(transformer)
      }
      
      itBehavesLike("a cache with conditioned post-processing") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache,
          ConditionedPostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
  }
}
