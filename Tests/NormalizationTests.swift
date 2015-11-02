import Foundation
import Quick
import Nimble
import Carlos

private struct NormalizedCacheSharedExamplesContext {
  static let CacheToTest = "normalizedCache"
  static let OriginalCache = "originalCache"
}

class NormalizationSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("no-op if the original cache is a BasicCache") { (sharedExampleContext: SharedExampleContext) in
      var cacheToTest: BasicCache<String, Int>!
      var originalCache: BasicCache<String, Int>!
      
      beforeEach {
        cacheToTest = sharedExampleContext()[NormalizedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        originalCache = sharedExampleContext()[NormalizedCacheSharedExamplesContext.OriginalCache] as? BasicCache<String, Int>
      }
      
      it("should have a valid cache to test") {
        expect(cacheToTest).notTo(beNil())
      }
      
      it("should return the same value for the normalized cache") {
        expect(cacheToTest).to(beIdenticalTo(originalCache))
      }
    }
    
    sharedExamples("wrap the original cache into a BasicCache") { (sharedExampleContext: SharedExampleContext) in
      var cacheToTest: BasicCache<String, Int>!
      var originalCache: CacheLevelFake<String, Int>!
      
      beforeEach {
        cacheToTest = sharedExampleContext()[NormalizedCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        originalCache = sharedExampleContext()[NormalizedCacheSharedExamplesContext.OriginalCache] as? CacheLevelFake<String, Int>
      }
      
      context("when calling get") {
        let key = "key to test"
        var request: Promise<Int>!
        var expectedRequest: Promise<Int>!
        
        beforeEach {
          expectedRequest = Promise<Int>()
          originalCache.cacheRequestToReturn = expectedRequest
          request = cacheToTest.get(key)
        }
        
        it("should call the closure") {
          expect(originalCache.numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(originalCache.didGetKey).to(equal(key))
        }
        
        it("should not modify the request") {
          expect(request).to(beIdenticalTo(expectedRequest))
        }
      }
      
      context("when calling set") {
        let key = "test key"
        let value = 101
        
        beforeEach {
          cacheToTest.set(value, forKey: key)
        }
        
        it("should call the closure") {
          expect(originalCache.numberOfTimesCalledSet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(originalCache.didSetKey).to(equal(key))
        }
        
        it("should pass the right value") {
          expect(originalCache.didSetValue).to(equal(value))
        }
      }
      
      context("when calling clear") {
        beforeEach {
          cacheToTest.clear()
        }
        
        it("should call the closure") {
          expect(originalCache.numberOfTimesCalledClear).to(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          cacheToTest.onMemoryWarning()
        }
        
        it("should call the closure") {
          expect(originalCache.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
      }
    }
  }
}

class NormalizationTests: QuickSpec {
  override func spec() {
    var cacheToTest: BasicCache<String, Int>!
    
    describe("Normalization through the global function") {
      context("when normalizing a BasicCache") {
        var originalCache: BasicCache<String, Int>!
        
        beforeEach {
          originalCache = CacheLevelFake().transformKeys({ Promise(value: $0) })
          cacheToTest = normalize(originalCache)
        }
        
        itBehavesLike("no-op if the original cache is a BasicCache") {
          [
            NormalizedCacheSharedExamplesContext.OriginalCache: originalCache,
            NormalizedCacheSharedExamplesContext.CacheToTest: cacheToTest
          ]
        }
      }
      
      context("when normalizing another type of cache") {
        var originalCache: CacheLevelFake<String, Int>!
        
        beforeEach {
          originalCache = CacheLevelFake()
          cacheToTest = normalize(originalCache)
        }
        
        itBehavesLike("wrap the original cache into a BasicCache") {
          [
            NormalizedCacheSharedExamplesContext.OriginalCache: originalCache,
            NormalizedCacheSharedExamplesContext.CacheToTest: cacheToTest
          ]
        }
      }
    }
    
    describe("Normalization through the protocol extension") {
      context("when normalizing a BasicCache") {
        var originalCache: BasicCache<String, Int>!
        
        beforeEach {
          originalCache = CacheLevelFake().transformKeys({ Promise(value: $0) })
          cacheToTest = originalCache.normalize()
        }
        
        itBehavesLike("no-op if the original cache is a BasicCache") {
          [
            NormalizedCacheSharedExamplesContext.OriginalCache: originalCache,
            NormalizedCacheSharedExamplesContext.CacheToTest: cacheToTest
          ]
        }
      }
      
      context("when normalizing another type of cache") {
        var originalCache: CacheLevelFake<String, Int>!
        
        beforeEach {
          originalCache = CacheLevelFake()
          cacheToTest = originalCache.normalize()
        }
        
        itBehavesLike("wrap the original cache into a BasicCache") {
          [
            NormalizedCacheSharedExamplesContext.OriginalCache: originalCache,
            NormalizedCacheSharedExamplesContext.CacheToTest: cacheToTest
          ]
        }
      }
    }
  }
}