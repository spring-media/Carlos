import Foundation
import Quick
import Nimble
import Carlos

private struct PostProcessSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

class PostProcessSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a fetch closure with post-processing step") { (sharedExampleContext: SharedExampleContext) in
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
        var failureValue: ErrorType?
        var fakeRequest: CacheRequest<Int>!
        
        beforeEach {
          fakeRequest = CacheRequest<Int>()
          internalCache.cacheRequestToReturn = fakeRequest
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
              expect(successValue).to(equal(transformer.transform(value)))
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
              expect(failureValue as? FetchError).to(equal(FetchError.ValueTransformationFailed))
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
    
    sharedExamples("a cache with post-processing step") { (sharedExampleContext: SharedExampleContext) in
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

class PostProcessTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    var transformer: OneWayTransformationBox<Int, Int>!
    let transformationClosure: Int -> Int? = {
      if $0 > 0 {
        return $0 + 1
      } else {
        return nil
      }
    }
    
    describe("Post processing using a transformer and a cache, with the global function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = postProcess(internalCache, transformer: transformer)
      }
      
      itBehavesLike("a cache with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
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
    
    describe("Post processing using a transformer and a cache, with the operator") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = internalCache ~>> transformer
      }
      
      itBehavesLike("a cache with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Post processing using a transformation closure and a cache, with the global function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = postProcess(internalCache, transformerClosure: transformationClosure)
      }
      
      itBehavesLike("a cache with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Post processing using a transformation closure and a cache, with the instance function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = internalCache.postProcess(transformationClosure)
      }
      
      itBehavesLike("a cache with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Post processing using a transformation closure and a cache, with the operator") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = internalCache ~>> transformationClosure
      }
      
      itBehavesLike("a cache with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Post processing using a transformation closure and a fetch closure, with the global function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        let fetchClosure = internalCache.get
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = postProcess(fetchClosure, transformerClosure: transformationClosure)
      }
      
      itBehavesLike("a fetch closure with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Post processing using a transformation closure and a fetch closure, with the operator") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        let fetchClosure = internalCache.get
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = fetchClosure ~>> transformationClosure
      }
      
      itBehavesLike("a fetch closure with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Post processing using a transformer and a fetch closure, with the global function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        let fetchClosure = internalCache.get
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = postProcess(fetchClosure, transformer: transformer)
      }
      
      itBehavesLike("a fetch closure with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Post processing using a transformer and a fetch closure, with the operator") {
      
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        let fetchClosure = internalCache.get
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = fetchClosure ~>> transformer
      }
      
      itBehavesLike("a fetch closure with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache,
          PostProcessSharedExamplesContext.InternalCache: internalCache,
          PostProcessSharedExamplesContext.Transformer: transformer
        ]
      }
    }
  }
}