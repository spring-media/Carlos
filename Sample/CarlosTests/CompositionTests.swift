import Foundation
import Quick
import Nimble
import Carlos

class CompositionSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("get without considering set calls") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()["cache1"] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()["cache2"] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()["composedCache"] as? BasicCache<String, Int>
      }
      
      context("when calling get") {
        let key = "test key"
        var cache1Request: CacheRequest<Int>!
        var cache2Request: CacheRequest<Int>!
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var successValue: Int?
        var resultRequest: CacheRequest<Int>!
        
        beforeEach {
          cache1Request = CacheRequest<Int>()
          cache1.cacheRequestToReturn = cache1Request
          
          cache2Request = CacheRequest<Int>()
          cache2.cacheRequestToReturn = cache2Request
          
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
            
            cache1Request.fail(nil)
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
              cache2Request.fail(nil)
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
        cache1 = sharedExampleContext()["cache1"] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()["cache2"] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()["composedCache"] as? BasicCache<String, Int>
      }
      
      context("when calling get") {
        let key = "test key"
        var cache1Request: CacheRequest<Int>!
        var cache2Request: CacheRequest<Int>!
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var successValue: Int?
        var resultRequest: CacheRequest<Int>!
        
        beforeEach {
          cache1Request = CacheRequest<Int>()
          cache1.cacheRequestToReturn = cache1Request
          
          cache2Request = CacheRequest<Int>()
          cache2.cacheRequestToReturn = cache2Request
          
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
            "cache1": cache1,
            "cache2": cache2,
            "composedCache": composedCache
          ]
        }
        
        context("when the first request fails") {
          beforeEach {
            successSentinel = nil
            failureSentinel = nil
            
            cache1Request.fail(nil)
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
        cache1 = sharedExampleContext()["cache1"] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()["cache2"] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()["composedCache"] as? BasicCache<String, Int>
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
        cache1 = sharedExampleContext()["cache1"] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()["cache2"] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()["composedCache"] as? BasicCache<String, Int>
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
        cache1 = sharedExampleContext()["cache1"] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()["cache2"] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()["composedCache"] as? BasicCache<String, Int>
      }
      
      itBehavesLike("get without considering set calls") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    sharedExamples("a composition of a fetch closure and a cache") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()["cache1"] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()["cache2"] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()["composedCache"] as? BasicCache<String, Int>
      }
      
      itBehavesLike("get without considering set calls") {
        [
        "cache1": cache1,
        "cache2": cache2,
        "composedCache": composedCache
        ]
      }
      
      itBehavesLike("second cache is a cache") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    sharedExamples("a composition of a cache and a fetch closure") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()["cache1"] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()["cache2"] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()["composedCache"] as? BasicCache<String, Int>
      }

      itBehavesLike("get on caches") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }

      itBehavesLike("first cache is a cache") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    sharedExamples("a composed cache") { (sharedExampleContext: SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()["cache1"] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()["cache2"] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()["composedCache"] as? BasicCache<String, Int>
      }
      
      itBehavesLike("get on caches") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
        
      itBehavesLike("first cache is a cache") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
      
      itBehavesLike("second cache is a cache") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
  }
}

class CompositionTests: QuickSpec {
  override func spec() {
    describe("Cache composition using two cache levels with the global function") {
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = compose(cache1, cache2)
      }
      
      itBehavesLike("a composed cache") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    describe("Cache composition using two cache levels with the operator") {
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1 >>> cache2
      }
      
      itBehavesLike("a composed cache") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    describe("Cache composition using a cache level and a fetch closure, with the global function") {
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = compose(cache1, cache2.get)
      }
      
      itBehavesLike("a composition of a cache and a fetch closure") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    describe("Cache composition using a cache level and a fetch closure, with the operator") {
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1 >>> cache2.get
      }
      
      itBehavesLike("a composition of a cache and a fetch closure") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    describe("Cache composition using a fetch closure and a cache level, with the global function") {
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = compose(cache1.get, cache2)
      }
      
      itBehavesLike("a composition of a fetch closure and a cache") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    describe("Cache composition using a fetch closure and a cache level, with the operator") {
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1.get >>> cache2
      }
      
      itBehavesLike("a composition of a fetch closure and a cache") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    describe("Cache composition using two fetch closures, with the global function") {
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = compose(cache1.get, cache2.get)
      }
      
      itBehavesLike("a composition of two fetch closures") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
    
    describe("Cache composition using two fetch closures, with the operator") {
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = CacheLevelFake<String, Int>()
        cache2 = CacheLevelFake<String, Int>()
        
        composedCache = cache1.get >>> cache2.get
      }
      
      itBehavesLike("a composition of two fetch closures") {
        [
          "cache1": cache1,
          "cache2": cache2,
          "composedCache": composedCache
        ]
      }
    }
  }
}