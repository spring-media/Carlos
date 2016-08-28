import Foundation
import Quick
import Nimble
import Carlos
import PiedPiper

struct ConditionedValueTransformationSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

class ConditionedValueTransformationSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a cache with conditioned value transformation") { (sharedExampleContext: SharedExampleContext) in
      var cache: BasicCache<String, Float>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: ConditionedTwoWayTransformationBox<String, Int, Float>!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedValueTransformationSharedExamplesContext.CacheToTest] as? BasicCache<String, Float>
        internalCache = sharedExampleContext()[ConditionedValueTransformationSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ConditionedValueTransformationSharedExamplesContext.Transformer] as? ConditionedTwoWayTransformationBox<String, Int, Float>
      }
      
      context("when calling get with a key that meets the condition") {
        let key = "do"
        var successValue: Float?
        var failureValue: ErrorType?
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
            var expected: Float!
            transformer.conditionalTransform(key, value: value).onSuccess { expected = $0 }
            expect(successValue).to(equal(expected))
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.SimpleError
          
          beforeEach {
            fakeRequest.fail(errorCode)
          }
          
          it("should call the original failure closure") {
            expect(failureValue as? TestError).to(equal(errorCode))
          }
        }
      }
      
      context("when calling get with a key that doesn't meet the condition") {
        let key = "don't"
        var successValue: Float?
        var failureValue: ErrorType?
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
            expect(failureValue as? TestError).to(equal(TestError.AnotherError))
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.SimpleError
          
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
        var successValue: Float?
        var failureValue: ErrorType?
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
              var expected: Float!
              transformer.conditionalTransform(key, value: value).onSuccess { expected = $0 }
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
              expect(failureValue as? TestError).to(equal(TestError.SimpleError))
            }
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.AnotherError
          
          beforeEach {
            fakeRequest.fail(errorCode)
          }
          
          it("should call the original failure closure") {
            expect(failureValue as? TestError).to(equal(errorCode))
          }
        }
      }
      
      context("when calling set") {
        var failed: ErrorType?
        var succeeded: Bool!
        var canceled: Bool!
        
        beforeEach {
          canceled = false
          succeeded = false
          failed = nil
        }
        
        context("when the condition is met") {
          let key = "10"
          let value: Float = 222
          
          beforeEach {
            cache.set(value, forKey: key)
              .onSuccess { _ in succeeded = true }
              .onFailure { failed = $0 }
              .onCancel { canceled = true }
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).to(equal(1))
          }
          
          it("should forward the key") {
            expect(internalCache.didSetKey).to(equal(key))
          }
          
          it("should pass the right value") {
            expect(internalCache.didSetValue).to(equal(Int(value)))
          }
          
          context("when the set closure succeeds") {
            beforeEach {
              internalCache.setPromisesReturned[0].succeed()
            }
            
            it("should succeed the future") {
              expect(succeeded).to(beTrue())
            }
          }
          
          context("when the set clousure is canceled") {
            beforeEach {
              internalCache.setPromisesReturned[0].cancel()
            }
            
            it("should cancel the future") {
              expect(canceled).to(beTrue())
            }
          }
          
          context("when the set closure fails") {
            let error = TestError.AnotherError
            
            beforeEach {
              internalCache.setPromisesReturned[0].fail(error)
            }
            
            it("should fail the future") {
              expect(failed as? TestError).to(equal(error))
            }
          }
        }
        
        context("when the condition is not met") {
          let key = "Test"
          let value: Float = -222
          
          beforeEach {
            cache.set(value, forKey: key)
              .onSuccess { _ in succeeded = true }
              .onFailure { failed = $0 }
              .onCancel { canceled = true }
          }
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).to(equal(0))
          }
          
          it("should fail the future") {
            expect(failed).notTo(beNil())
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

class ConditionedValueTransformationTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Float>!
    var internalCache: CacheLevelFake<String, Int>!
    let transformer: ConditionedTwoWayTransformationBox<String, Int, Float>= ConditionedTwoWayTransformationBox(conditionalTransformClosure: { (key, value) in
      let result = Promise<Float>()
      
      if key == "do" {
        result.succeed(Float(value * 2))
      } else if key == "don't" {
        result.fail(TestError.AnotherError)
      } else {
        if value > 0 {
          result.succeed(Float(value))
        } else {
          result.fail(TestError.SimpleError)
        }
      }
      
      return result.future
    }, conditionalInverseTransformClosure: { (key, value) in
      let result = Promise<Int>()
      
      if key == "do" {
        result.succeed(Int(value / 2))
      } else if key == "don't" {
        result.fail(TestError.AnotherError)
      } else {
        if value > 0 {
          result.succeed(Int(value))
        } else {
          result.fail(TestError.SimpleError)
        }
      }
      
      return result.future
    })
    
    describe("Conditioned post processing on a CacheLevel with the protocol extension") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.conditionedValueTransformation(transformer)
      }
      
      itBehavesLike("a cache with conditioned value transformation") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache,
          ConditionedPostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Conditioned post processing on a CacheLevel with the operator") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache ?>> transformer
      }
      
      itBehavesLike("a cache with conditioned value transformation") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache,
          ConditionedPostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
  }
}