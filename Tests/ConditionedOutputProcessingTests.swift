import Foundation
import Quick
import Nimble
import Carlos

struct ConditionedPostProcessSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let TransformationWrapper = "transformer"
}

class ConditionedPostProcessSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a fetch closure with conditioned post-processing") { (sharedExampleContext: SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformationWrapper: TransformationWrapper!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformationWrapper = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.TransformationWrapper] as? TransformationWrapper
      }
      
      context("when calling get with a key that triggers some post-processing") {
        let key = "do"
        var successValue: Int?
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
            var expected: Int!
            transformationWrapper.transformationClosure(key: key, value: value).onSuccess { expected = $0 }
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
      
      context("when calling get with a key that triggers failure on the post-processing") {
        let key = "don't"
        var successValue: Int?
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
        var successValue: Int?
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
              var expected: Int!
              transformationWrapper.transformationClosure(key: key, value: value).onSuccess { expected = $0 }
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
    }
    
    sharedExamples("a cache with conditioned post-processing") { (sharedExampleContext: SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: TransformationWrapper!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.TransformationWrapper] as? TransformationWrapper
      }
      
      itBehavesLike("a fetch closure with conditioned post-processing") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache,
          ConditionedPostProcessSharedExamplesContext.TransformationWrapper: transformer
        ]
      }
      
      context("when calling set") {
        let key = "10"
        let value = 222
        
        beforeEach {
          cache.set(value, forKey: key)
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

private class TransformationWrapper {
  let transformationClosure: (key: String, value: Int) -> Future<Int>
  
  init(closure: (key: String, value: Int) -> Future<Int>) {
    self.transformationClosure = closure
  }
}

class ConditionedOutputPostProcessingTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    var transformationClosure: (key: String, value: Int) -> Future<Int> = { (key, value) in
      let result = Promise<Int>()
      
      if key == "do" {
        result.succeed(value * 2)
      } else if key == "don't" {
        result.fail(TestError.AnotherError)
      } else {
        if value > 0 {
          result.succeed(value)
        } else {
          result.fail(TestError.SimpleError)
        }
      }
      
      return result.future
    }
    
    describe("Conditioned post processing on a CacheLevel with the protocol extension") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.conditionedPostProcess(transformationClosure)
      }
      
      itBehavesLike("a cache with conditioned post-processing") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache,
          ConditionedPostProcessSharedExamplesContext.TransformationWrapper: TransformationWrapper(closure: transformationClosure)
        ]
      }
    }
    
    describe("Conditioned post processing on a CacheLevel with the operator") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache ?>> transformationClosure
      }
      
      itBehavesLike("a cache with conditioned post-processing") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache,
          ConditionedPostProcessSharedExamplesContext.TransformationWrapper: TransformationWrapper(closure: transformationClosure)
        ]
      }
    }
    
    describe("Conditioned post processing on a fetch closure with the operator") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.get ?>> transformationClosure
      }
      
      itBehavesLike("a fetch closure with conditioned post-processing") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache,
          ConditionedPostProcessSharedExamplesContext.TransformationWrapper: TransformationWrapper(closure: transformationClosure)
        ]
      }
    }
  }
}