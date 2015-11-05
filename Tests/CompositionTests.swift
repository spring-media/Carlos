import Foundation
import Quick
import Nimble
import Carlos

struct ComposedCacheSharedExamplesContext {
  static let CacheToTest = "composedCache"
  static let FirstComposedCache = "cache1"
  static let SecondComposedCache = "cache2"
}

class CompositionSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("get without considering set calls") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      context("when calling get") {
        let key = "test key"
        var cache1Request: Promise<Int>!
        var cache2Request: Promise<Int>!
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var successValue: Int?
        var resultRequest: Future<Int>!
        
        beforeEach {
          cache1Request = Promise<Int>()
          cache1.cacheRequestToReturn = cache1Request.future
          
          cache2Request = Promise<Int>()
          cache2.cacheRequestToReturn = cache2Request.future
          
          for cache in [cache1, cache2] {
            cache.numberOfTimesCalledGet = 0
            cache.numberOfTimesCalledSet = 0
          }
          
          resultRequest = composedCache.get(key).onSuccess({ result in
            successSentinel = true
            successValue = result
          }).onFailure({ _ in
            failureSentinel = true
          })
        }
        
        it("should not call any success closure") {
          expect(successSentinel).to(beNil())
        }
        
        it("should not call any failure closure") {
          expect(failureSentinel).to(beNil())
        }
        
        it("should call get on the first cache") {
          expect(cache1.numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should not call get on the second cache") {
          expect(cache2.numberOfTimesCalledGet).to(equal(0))
        }
        
        context("when the first request succeeds") {
          let value = 1022
          
          beforeEach {
            cache1Request.succeed(value)
          }
          
          it("should call the success closure") {
            expect(successSentinel).notTo(beNil())
          }
          
          it("should pass the right value") {
            expect(successValue).to(equal(value))
          }
          
          it("should not call the failure closure") {
            expect(failureSentinel).to(beNil())
          }
          
          it("should not call get on the second cache") {
            expect(cache2.numberOfTimesCalledGet).to(equal(0))
          }
        }
        
        context("when the first request fails") {
          beforeEach {
            successSentinel = nil
            failureSentinel = nil
            
            cache1Request.fail(TestError.SimpleError)
          }
          
          it("should not call the success closure") {
            expect(successSentinel).to(beNil())
          }
          
          it("should not call the failure closure") {
            expect(failureSentinel).to(beNil())
          }
          
          it("should call get on the second cache") {
            expect(cache2.numberOfTimesCalledGet).to(equal(1))
          }
          
          it("should not do other get calls on the first cache") {
            expect(cache1.numberOfTimesCalledGet).to(equal(1))
          }
          
          context("when the second request succeeds") {
            let value = -122
            
            beforeEach {
              cache2Request.succeed(value)
            }
            
            it("should call the success closure") {
              expect(successSentinel).notTo(beNil())
            }
            
            it("should pass the right value") {
              expect(successValue).to(equal(value))
            }
            
            it("should not call the failure closure") {
              expect(failureSentinel).to(beNil())
            }
          }
          
          context("when the second request fails") {
            beforeEach {
              cache2Request.fail(TestError.SimpleError)
            }
            
            it("should not call the success closure") {
              expect(successSentinel).to(beNil())
            }
            
            it("should call the failure closure") {
              expect(failureSentinel).notTo(beNil())
            }
            
            it("should not do other get calls on the first cache") {
              expect(cache1.numberOfTimesCalledGet).to(equal(1))
            }
            
            it("should not do other get calls on the second cache") {
              expect(cache2.numberOfTimesCalledGet).to(equal(1))
            }
          }
        }
      }
    }
    
    sharedExamples("get on caches") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      context("when calling get") {
        let key = "test key"
        var cache1Request: Promise<Int>!
        var cache2Request: Promise<Int>!
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var successValue: Int?
        var resultRequest: Future<Int>!
        
        beforeEach {
          cache1Request = Promise<Int>()
          cache1.cacheRequestToReturn = cache1Request.future
          
          cache2Request = Promise<Int>()
          cache2.cacheRequestToReturn = cache2Request.future
          
          for cache in [cache1, cache2] {
            cache.numberOfTimesCalledGet = 0
            cache.numberOfTimesCalledSet = 0
          }
          
          resultRequest = composedCache.get(key).onSuccess({ result in
            successSentinel = true
            successValue = result
          }).onFailure({ _ in
            failureSentinel = true
          })
        }
        
        itBehavesLike("get without considering set calls") {
          [
            ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
            ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
            ComposedCacheSharedExamplesContext.CacheToTest: composedCache
          ]
        }
        
        context("when the first request fails") {
          beforeEach {
            successSentinel = nil
            failureSentinel = nil
            
            cache1Request.fail(TestError.SimpleError)
          }
          
          context("when the second request succeeds") {
            let value = -122
            
            beforeEach {
              cache2Request.succeed(value)
            }
            
            it("should set the value on the first cache") {
              expect(cache1.numberOfTimesCalledSet).to(equal(1))
            }
            
            it("should set the value on the first cache with the right key") {
              expect(cache1.didSetKey).to(equal(key))
            }
            
            it("should set the right value on the first cache") {
              expect(cache1.didSetValue).to(equal(value))
            }
            
            it("should not set the same value again on the second cache") {
              expect(cache2.numberOfTimesCalledSet).to(equal(0))
            }
          }
        }
      }
    }
    
    sharedExamples("first cache is a cache") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      context("when calling set") {
        let key = "this key"
        let value = 102
        
        beforeEach {
          composedCache.set(value, forKey: key)
        }
        
        it("should call set on the first cache") {
          expect(cache1.numberOfTimesCalledSet).to(equal(1))
        }
        
        it("should pass the right key on the first cache") {
          expect(cache1.didSetKey).to(equal(key))
        }
        
        it("should pass the right value on the first cache") {
          expect(cache1.didSetValue).to(equal(value))
        }
      }
      
      context("when calling clear") {
        beforeEach {
          composedCache.clear()
        }
        
        it("should call clear on the first cache") {
          expect(cache1.numberOfTimesCalledClear).to(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          composedCache.onMemoryWarning()
        }
        
        it("should call onMemoryWarning on the first cache") {
          expect(cache1.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
      }
    }
    
    sharedExamples("second cache is a cache") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
          
      context("when calling set") {
        let key = "this key"
        let value = 102
        
        beforeEach {
          composedCache.set(value, forKey: key)
        }
        
        it("should call set on the second cache") {
          expect(cache2.numberOfTimesCalledSet).to(equal(1))
        }
        
        it("should pass the right key on the second cache") {
          expect(cache2.didSetKey).to(equal(key))
        }
        
        it("should pass the right value on the second cache") {
          expect(cache2.didSetValue).to(equal(value))
        }
      }
      
      context("when calling clear") {
        beforeEach {
          composedCache.clear()
        }
        
        it("should call clear on the second cache") {
          expect(cache2.numberOfTimesCalledClear).to(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          composedCache.onMemoryWarning()
        }
        
        it("should call onMemoryWarning on the second cache") {
          expect(cache2.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
      }
    }
    
    sharedExamples("a composition of two fetch closures") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      itBehavesLike("get without considering set calls") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    sharedExamples("a composition of a fetch closure and a cache") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      itBehavesLike("get without considering set calls") {
        [
        ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
        ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
        ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
      
      itBehavesLike("second cache is a cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    sharedExamples("a composition of a cache and a fetch closure") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }

      itBehavesLike("get on caches") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }

      itBehavesLike("first cache is a cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    sharedExamples("a composed cache") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      itBehavesLike("get on caches") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
        
      itBehavesLike("first cache is a cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
      
      itBehavesLike("second cache is a cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
  }
}

class CacheLevelCompositionTests: QuickSpec {
  override func spec() {
    var cache1: CacheLevelFake<String, Int>!
    var cache2: CacheLevelFake<String, Int>!
    var composedCache: BasicCache<String, Int>!
    
    describe("Cache composition using two cache levels with the global function") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = compose(cache1, secondCache: cache2)
      }
      
      itBehavesLike("a composed cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using two cache levels with the instance function") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1.compose(cache2)
      }
      
      itBehavesLike("a composed cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using two cache levels with the operator") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1 >>> cache2
      }
      
      itBehavesLike("a composed cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using a cache level and a fetch closure, with the global function") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = compose(cache1, fetchClosure: cache2.get)
      }
      
      itBehavesLike("a composition of a cache and a fetch closure") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using a cache level and a fetch closure, with the instance function") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1.compose(cache2.get)
      }
      
      itBehavesLike("a composition of a cache and a fetch closure") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using a cache level and a fetch closure, with the operator") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1 >>> cache2.get
      }
      
      itBehavesLike("a composition of a cache and a fetch closure") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using a fetch closure and a cache level, with the global function") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = compose(cache1.get, cache: cache2)
      }
      
      itBehavesLike("a composition of a fetch closure and a cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using a fetch closure and a cache level, with the operator") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1.get >>> cache2
      }
      
      itBehavesLike("a composition of a fetch closure and a cache") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using two fetch closures, with the global function") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = compose(cache1.get, secondFetcher: cache2.get)
      }
      
      itBehavesLike("a composition of two fetch closures") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
    
    describe("Cache composition using two fetch closures, with the operator") {
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1.get >>> cache2.get
      }
      
      itBehavesLike("a composition of two fetch closures") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
  }
}