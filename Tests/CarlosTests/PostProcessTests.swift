import Foundation
import Quick
import Nimble
@testable import Carlos
import PiedPiper

struct PostProcessSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

class PostProcessSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a fetch closure with post-processing step") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: OneWayTransformationBox<Int, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[PostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[PostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[PostProcessSharedExamplesContext.Transformer] as? OneWayTransformationBox<Int, Int>
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
            
            it("should call the transformer with the success value") {
              var expected: Int!
              transformer.transform(value).onSuccess { expected = $0 }
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
    
    sharedExamples("a cache with post-processing step") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: OneWayTransformationBox<Int, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[PostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[PostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[PostProcessSharedExamplesContext.Transformer] as? OneWayTransformationBox<Int, Int>
      }
      
      itBehavesLike("a fetch closure with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
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

class PostProcessTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    var transformer: OneWayTransformationBox<Int, Int>!
    let transformationClosure: (Int) -> Future<Int> = {
      let result = Promise<Int>()
      if $0 > 0 {
        result.succeed($0 + 1)
      } else {
        result.fail(TestError.simpleError)
      }
      return result.future
    }
    
    describe("Post processing using a transformer and a cache, with the instance function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = internalCache.postProcess(transformer)
      }
      
      itBehavesLike("a cache with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
  }
}
