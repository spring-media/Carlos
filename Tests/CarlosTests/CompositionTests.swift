import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

struct ComposedCacheSharedExamplesContext {
  static let CacheToTest = "composedCache"
  static let FirstComposedCache = "cache1"
  static let SecondComposedCache = "cache2"
}

final class CompositionSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("get without considering set calls") { (sharedExampleContext: @escaping SharedExampleContext) in
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
        
        var cancellable: AnyCancellable?
        var cache1Subject: PassthroughSubject<Int, Error>!
        var cache2Subject: PassthroughSubject<Int, Error>!
        
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var cancelSentinel: Bool!
        var successValue: Int?
        
        beforeEach {
          cancelSentinel = false
          successSentinel = nil
          successValue = nil
          failureSentinel = nil
          
          cache1Subject = PassthroughSubject()
          cache1.getSubject = cache1Subject
          
          cache2Subject = PassthroughSubject()
          cache2.getSubject = cache2Subject
          
          for cache in [cache1, cache2] {
            cache?.numberOfTimesCalledGet = 0
            cache?.numberOfTimesCalledSet = 0
          }
          
          cancellable = composedCache.get(key)
            .handleEvents(receiveCancel: { cancelSentinel = true })
            .sink(receiveCompletion: { completion in
              if case .failure = completion {
                failureSentinel = true
              }
            }, receiveValue: { value in
              successSentinel = true
              successValue = value
            })
        }
        
        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }
        
        it("should not call any success closure") {
          expect(successSentinel).toEventually(beNil())
        }
        
        it("should not call any failure closure") {
          expect(failureSentinel).toEventually(beNil())
        }
        
        it("should not call any cancel closure") {
          expect(cancelSentinel).toEventually(beFalse())
        }
        
        it("should call get on the first cache") {
          expect(cache1.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should not call get on the second cache") {
          expect(cache2.numberOfTimesCalledGet).toEventually(equal(0))
        }
        
        context("when the first request succeeds") {
          let value = 1022
          
          beforeEach {
            cache1Subject.send(value)
          }
          
          it("should call the success closure") {
            expect(successSentinel).toEventuallyNot(beNil())
          }
          
          it("should pass the right value") {
            expect(successValue).toEventually(equal(value))
          }
          
          it("should not call the failure closure") {
            expect(failureSentinel).toEventually(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(cancelSentinel).toEventually(beFalse())
          }
          
          it("should not call get on the second cache") {
            expect(cache2.numberOfTimesCalledGet).toEventually(equal(0))
          }
        }
        
        context("when the request is canceled") {
          beforeEach {
            cancellable?.cancel()
          }
          
          it("should not call the success closure") {
            expect(successSentinel).toEventually(beNil())
          }
          
          it("should not call the failure closure") {
            expect(failureSentinel).toEventually(beNil())
          }
          
          it("should call the cancel closure") {
            expect(cancelSentinel).toEventually(beTrue())
          }
        }
        
        context("when the first request fails") {
          beforeEach {
            cache1Subject.send(completion: .failure(TestError.simpleError))
          }
          
          it("should not call the success closure") {
            expect(successSentinel).toEventually(beNil())
          }
          
          it("should not call the failure closure") {
            expect(failureSentinel).toEventually(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(cancelSentinel).toEventually(beFalse())
          }
          
          it("should call get on the second cache") {
            expect(cache2.numberOfTimesCalledGet).toEventually(equal(1))
          }
          
          it("should not do other get calls on the first cache") {
            expect(cache1.numberOfTimesCalledGet).toEventually(equal(1))
          }
          
          context("when the second request succeeds") {
            let value = -122
            
            beforeEach {
              cache2Subject.send(value)
            }
            
            it("should call the success closure") {
              expect(successSentinel).toEventuallyNot(beNil())
            }
            
            it("should pass the right value") {
              expect(successValue).toEventually(equal(value))
            }
            
            it("should not call the failure closure") {
              expect(failureSentinel).toEventually(beNil())
            }
            
            it("should not call the cancel closure") {
              expect(cancelSentinel).toEventually(beFalse())
            }
          }
          
          context("when the second request fails") {
            beforeEach {
              cache2Subject.send(completion: .failure(TestError.simpleError))
            }
            
            it("should not call the success closure") {
              expect(successSentinel).toEventually(beNil())
            }
            
            it("should call the failure closure") {
              expect(failureSentinel).toEventuallyNot(beNil())
            }
            
            it("should not call the cancel closure") {
              expect(cancelSentinel).toEventually(beFalse())
            }
            
            it("should not do other get calls on the first cache") {
              expect(cache1.numberOfTimesCalledGet).toEventually(equal(1))
            }
            
            it("should not do other get calls on the second cache") {
              expect(cache2.numberOfTimesCalledGet).toEventually(equal(1))
            }
          }
        }
      }
    }
    
    sharedExamples("get on caches") { (sharedExampleContext: @escaping SharedExampleContext) in
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
        
        var cancellable: AnyCancellable?
        var cache1Subject: PassthroughSubject<Int, Error>!
        var cache2Subject: PassthroughSubject<Int, Error>!
        
        
        beforeEach {
          cache1Subject = PassthroughSubject()
          cache1.getSubject = cache1Subject
          
          cache2Subject = PassthroughSubject()
          cache2.getSubject = cache2Subject
          
          for cache in [cache1, cache2] {
            cache?.numberOfTimesCalledGet = 0
            cache?.numberOfTimesCalledSet = 0
          }
          
          cancellable = composedCache.get(key).sink(receiveCompletion: { _ in}, receiveValue: { _ in })
        }
        
        afterEach {
          cancellable?.cancel()
          cancellable = nil
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
            cache1Subject.send(completion: .failure(TestError.simpleError))
          }
          
          context("when the second request succeeds") {
            let value = -122
            
            beforeEach {
              cache2Subject.send(value)
            }
            
            it("should set the value on the first cache") {
              expect(cache1.numberOfTimesCalledSet).toEventually(equal(1))
            }
            
            it("should set the value on the first cache with the right key") {
              expect(cache1.didSetKey).toEventually(equal(key))
            }
            
            it("should set the right value on the first cache") {
              expect(cache1.didSetValue).toEventually(equal(value))
            }
            
            it("should not set the same value again on the second cache") {
              expect(cache2.numberOfTimesCalledSet).toEventually(equal(0))
            }
          }
        }
      }
    }
    
    sharedExamples("both caches are caches") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var cache2: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
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
      
      context("when calling set") {
        let key = "this key"
        let value = 102
        var succeeded: Bool!
        var failed: Error?
        var canceled: Bool!
        var cancellable: AnyCancellable?
        
        beforeEach {
          succeeded = false
          failed = nil
          canceled = false
          
          cancellable = composedCache.set(value, forKey: key)
            .handleEvents(receiveCancel: { canceled = true })
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failed = error
              }
            }, receiveValue: { _ in succeeded = true })
        }
        
        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }
        
        it("should call set on the first cache") {
          expect(cache1.numberOfTimesCalledSet).toEventually(equal(1))
        }
        
        it("should pass the right key on the first cache") {
          expect(cache1.didSetKey).toEventually(equal(key))
        }
        
        it("should pass the right value on the first cache") {
          expect(cache1.didSetValue).toEventually(equal(value))
        }
        
        context("when the set closure succeeds") {
          beforeEach {
            cache1.setPublishers[key]?.send()
          }
          
          it("should call set on the second cache") {
            expect(cache2.numberOfTimesCalledSet).toEventually(equal(1))
          }
          
          it("should pass the right key on the second cache") {
            expect(cache2.didSetKey).toEventually(equal(key))
          }
          
          it("should pass the right value on the second cache") {
            expect(cache2.didSetValue).toEventually(equal(value))
          }
          
          context("when the set closure succeeds") {
            beforeEach {
              cache2.setPublishers[key]?.send()
            }
            
            it("should succeed the future") {
              expect(succeeded).toEventually(beTrue())
            }
          }
          
          context("when the set closure fails") {
            let error = TestError.anotherError
            
            beforeEach {
              cache2.setPublishers[key]?.send(completion: .failure(error))
            }
            
            it("should fail the future") {
              expect(failed as? TestError).toEventually(equal(error))
            }
          }
        }
        
        context("when the set clousure is canceled") {
          beforeEach {
            cancellable?.cancel()
          }
          
          it("should cancel the future") {
            expect(canceled).toEventually(beTrue())
          }
        }
        
        context("when the set closure fails") {
          let error = TestError.anotherError
          
          beforeEach {
            cache1.setPublishers[key]?.send(completion: .failure(error))
          }
          
          it("should fail the future") {
            expect(failed as? TestError).toEventually(equal(error))
          }
        }
      }
    }
    
    sharedExamples("first cache is a cache") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache1: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      context("when calling set") {
        let key = "this key"
        let value = 102
        var failed: Error?
        var canceled: Bool!
        var cancellable: AnyCancellable?
        
        beforeEach {
          failed = nil
          canceled = false
          
          cancellable = composedCache.set(value, forKey: key)
            .handleEvents(receiveCancel: { canceled = true })
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failed = error
              }
            }, receiveValue: { _ in })
        }
        
        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }
        
        it("should call set on the first cache") {
          expect(cache1.numberOfTimesCalledSet).toEventually(equal(1))
        }
        
        it("should pass the right key on the first cache") {
          expect(cache1.didSetKey).toEventually(equal(key))
        }
        
        it("should pass the right value on the first cache") {
          expect(cache1.didSetValue).toEventually(equal(value))
        }
        
        context("when the set clousure is canceled") {
          beforeEach {
            cancellable?.cancel()
          }
          
          it("should cancel the future") {
            expect(canceled).toEventually(beTrue())
          }
        }
        
        context("when the set closure fails") {
          let error = TestError.anotherError
          
          beforeEach {
            cache1.setPublishers[key]?.send(completion: .failure(error))
          }
          
          it("should fail the future") {
            expect(failed as? TestError).toEventually(equal(error))
          }
        }
      }
      
      context("when calling clear") {
        beforeEach {
          composedCache.clear()
        }
        
        it("should call clear on the first cache") {
          expect(cache1.numberOfTimesCalledClear).toEventually(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          composedCache.onMemoryWarning()
        }
        
        it("should call onMemoryWarning on the first cache") {
          expect(cache1.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }
      }
    }
    
    sharedExamples("second cache is a cache") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache2: CacheLevelFake<String, Int>!
      var cache1: CacheLevelFake<String, Int>!
      var composedCache: BasicCache<String, Int>!
      
      beforeEach {
        cache1 = sharedExampleContext()[ComposedCacheSharedExamplesContext.FirstComposedCache] as? CacheLevelFake<String, Int>
        cache2 = sharedExampleContext()[ComposedCacheSharedExamplesContext.SecondComposedCache] as? CacheLevelFake<String, Int>
        composedCache = sharedExampleContext()[ComposedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      context("when calling set") {
        let key = "this key"
        let value = 102
        var succeeded: Bool!
        var failed: Error?
        var canceled: Bool!
        var cancellable: AnyCancellable?
        
        beforeEach {
          succeeded = false
          failed = nil
          canceled = false
          
          cancellable = composedCache.set(value, forKey: key)
            .handleEvents(receiveCancel: { canceled = true })
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failed = error
              }
            }, receiveValue: { _ in succeeded = true })
        }
        
        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }
        
        it("should call set on the second cache") {
          expect(cache2.numberOfTimesCalledSet).toEventually(equal(1))
        }
        
        it("should pass the right key on the second cache") {
          expect(cache2.didSetKey).toEventually(equal(key))
        }
        
        it("should pass the right value on the second cache") {
          expect(cache2.didSetValue).toEventually(equal(value))
        }
        
        context("when the set closure succeeds") {
          beforeEach {
            cache1.setPublishers[key]?.send()
            cache2.setPublishers[key]?.send()
          }
          
          it("should succeed the future") {
            expect(succeeded).toEventually(beTrue())
          }
        }
        
        context("when the set clousure is canceled") {
          beforeEach {
            cancellable?.cancel()
          }
          
          it("should cancel the future") {
            expect(canceled).toEventually(beTrue())
          }
        }
        
        context("when the set closure fails") {
          let error = TestError.anotherError
          
          beforeEach {
            cache1.setPublishers[key]?.send(completion: .failure(error))
            cache2.setPublishers[key]?.send(completion: .failure(error))
          }
          
          it("should fail the future") {
            expect(failed as? TestError).toEventually(equal(error))
          }
        }
      }
      
      context("when calling clear") {
        beforeEach {
          composedCache.clear()
        }
        
        it("should call clear on the second cache") {
          expect(cache2.numberOfTimesCalledClear).toEventually(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          composedCache.onMemoryWarning()
        }
        
        it("should call onMemoryWarning on the second cache") {
          expect(cache2.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }
      }
    }
    
    sharedExamples("a composition of two fetch closures") { (sharedExampleContext: @escaping SharedExampleContext) in
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
    
    sharedExamples("a composition of a fetch closure and a cache") { (sharedExampleContext: @escaping SharedExampleContext) in
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
    
    sharedExamples("a composition of a cache and a fetch closure") { (sharedExampleContext: @escaping SharedExampleContext) in
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
    
    sharedExamples("a composed cache") { (sharedExampleContext: @escaping SharedExampleContext) in
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
      
      itBehavesLike("both caches are caches") {
        [
          ComposedCacheSharedExamplesContext.FirstComposedCache: cache1,
          ComposedCacheSharedExamplesContext.SecondComposedCache: cache2,
          ComposedCacheSharedExamplesContext.CacheToTest: composedCache
        ]
      }
    }
  }
}

final class CacheLevelCompositionTests: QuickSpec {
  override func spec() {
    var cache1: CacheLevelFake<String, Int>!
    var cache2: CacheLevelFake<String, Int>!
    var composedCache: BasicCache<String, Int>!
    
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
  }
}
