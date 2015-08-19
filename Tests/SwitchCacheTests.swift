import Foundation
import Quick
import Nimble
import Carlos

let switchClosure: (String) -> CacheLevelSwitchResult = { str in
  if str.characters.count > 5 {
    return .CacheA
  } else {
    return .CacheB
  }
}

private struct SwitchCacheSharedExamplesContext {
  static let CacheA = "cacheA"
  static let CacheB = "cacheB"
  static let CacheToTest = "sutCache"
}

class SwitchCacheSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("should correctly get") { (sharedExampleContext: SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      
      beforeEach {
        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      context("when calling get") {
        var fakeRequest: CacheRequest<Int>!
        var result: CacheRequest<Int>!
        var successValue: Int?
        var errorValue: ErrorType?
        
        beforeEach {
          fakeRequest = CacheRequest<Int>()
          cacheA.cacheRequestToReturn = fakeRequest
          cacheB.cacheRequestToReturn = fakeRequest
          
          successValue = nil
          errorValue = nil
        }
        
        context("when the switch closure returns cacheA") {
          let key = "quite long key"
          
          beforeEach {
            result = finalCache.get(key)
              .onSuccess { value in
                successValue = value
              }
              .onFailure { error in
                errorValue = error
              }
          }
          
          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledGet).to(equal(0))
          }
          
          it("should dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledGet).to(equal(1))
          }
          
          it("should pass the right key") {
            expect(cacheA.didGetKey).to(equal(key))
          }
          
          context("when the request succeeds") {
            let value = 2010
            
            beforeEach {
              fakeRequest.succeed(value)
            }
            
            it("should call the original success closure") {
              expect(successValue).to(equal(value))
            }
            
            it("should not call the original failure closure") {
              expect(errorValue).to(beNil())
            }
          }
          
          context("when the request fails") {
            let errorCode = TestError.SimpleError
            
            beforeEach {
              fakeRequest.fail(errorCode)
            }
            
            it("should call the original failure closure") {
              expect(errorValue as? TestError).to(equal(errorCode))
            }
            
            it("should not call the original success closure") {
              expect(successValue).to(beNil())
            }
          }
        }
        
        context("when the switch closure returns cacheB") {
          let key = "short"
          
          beforeEach {
            result = finalCache.get(key)
              .onSuccess { value in
                successValue = value
              }
              .onFailure { error in
                errorValue = error
            }
          }
          
          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledGet).to(equal(0))
          }
          
          it("should dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledGet).to(equal(1))
          }
          
          it("should pass the right key") {
            expect(cacheB.didGetKey).to(equal(key))
          }
          
          context("when the request succeeds") {
            let value = 2010
            
            beforeEach {
              fakeRequest.succeed(value)
            }
            
            it("should call the original success closure") {
              expect(successValue).to(equal(value))
            }
            
            it("should not call the original failure closure") {
              expect(errorValue).to(beNil())
            }
          }
          
          context("when the request fails") {
            let errorCode = TestError.AnotherError
            
            beforeEach {
              fakeRequest.fail(errorCode)
            }
            
            it("should call the original failure closure") {
              expect(errorValue as? TestError).to(equal(errorCode))
            }
            
            it("should not call the original success closure") {
              expect(successValue).to(beNil())
            }
          }
        }
      }
    }
    
    sharedExamples("a switched cache with 2 fetch closures") { (sharedExampleContext: SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      
      beforeEach {
        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      itBehavesLike("should correctly get") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA,
          SwitchCacheSharedExamplesContext.CacheB: cacheB,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
        ]
      }
    }
    
    sharedExamples("a switched cache with 2 cache levels") { (sharedExampleContext: SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      
      beforeEach {
        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      itBehavesLike("should correctly get") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA,
          SwitchCacheSharedExamplesContext.CacheB: cacheB,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
        ]
      }
      
      context("when calling set") {
        let value = 30
        
        context("when the switch closure returns cacheA") {
          let key = "quite long key"
          
          beforeEach {
            finalCache.set(value, forKey: key)
          }
          
          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).to(equal(0))
          }
          
          it("should dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).to(equal(1))
          }
          
          it("should pass the right key") {
            expect(cacheA.didSetKey).to(equal(key))
          }
          
          it("should pass the right value") {
            expect(cacheA.didSetValue).to(equal(value))
          }
        }
        
        context("when the switch closure returns cacheB") {
          let key = "short"
          
          beforeEach {
            finalCache.set(value, forKey: key)
          }
          
          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).to(equal(0))
          }
          
          it("should dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).to(equal(1))
          }
          
          it("should pass the right key") {
            expect(cacheB.didSetKey).to(equal(key))
          }
          
          it("should pass the right value") {
            expect(cacheB.didSetValue).to(equal(value))
          }
        }
      }
      
      context("when calling clear") {
        beforeEach {
          finalCache.clear()
        }
        
        it("should dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledClear).to(equal(1))
        }
        
        it("should dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledClear).to(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          finalCache.onMemoryWarning()
        }
        
        it("should dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
        
        it("should dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
      }
    }
    
    sharedExamples("a switched cache with a cache level and a fetch closure") { (sharedExampleContext: SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      
      beforeEach {
        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      itBehavesLike("should correctly get") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA,
          SwitchCacheSharedExamplesContext.CacheB: cacheB,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
        ]
      }
      
      context("when calling set") {
        let value = 30
        
        context("when the switch closure returns cacheA") {
          let key = "quite long key"
          
          beforeEach {
            finalCache.set(value, forKey: key)
          }
          
          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).to(equal(0))
          }
          
          it("should dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).to(equal(1))
          }
          
          it("should pass the right key") {
            expect(cacheA.didSetKey).to(equal(key))
          }
          
          it("should pass the right value") {
            expect(cacheA.didSetValue).to(equal(value))
          }
        }
        
        context("when the switch closure returns cacheB") {
          let key = "short"
          
          beforeEach {
            finalCache.set(value, forKey: key)
          }
          
          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).to(equal(0))
          }
          
          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).to(equal(0))
          }
        }
      }
      
      context("when calling clear") {
        beforeEach {
          finalCache.clear()
        }
        
        it("should dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledClear).to(equal(1))
        }
        
        it("should not dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledClear).to(equal(0))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          finalCache.onMemoryWarning()
        }
        
        it("should dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
        
        it("should not dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledOnMemoryWarning).to(equal(0))
        }
      }
    }
    
    sharedExamples("a switched cache with a fetch closure and a cache level") { (sharedExampleContext: SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      
      beforeEach {
        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }
      
      itBehavesLike("should correctly get") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA,
          SwitchCacheSharedExamplesContext.CacheB: cacheB,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
        ]
      }
      
      context("when calling set") {
        let value = 30
        
        context("when the switch closure returns cacheA") {
          let key = "quite long key"
          
          beforeEach {
            finalCache.set(value, forKey: key)
          }
          
          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).to(equal(0))
          }
          
          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).to(equal(0))
          }
        }
        
        context("when the switch closure returns cacheB") {
          let key = "short"
          
          beforeEach {
            finalCache.set(value, forKey: key)
          }
          
          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).to(equal(0))
          }
          
          it("should dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).to(equal(1))
          }
          
          it("should pass the right key") {
            expect(cacheB.didSetKey).to(equal(key))
          }
          
          it("should pass the right value") {
            expect(cacheB.didSetValue).to(equal(value))
          }
        }
      }
      
      context("when calling clear") {
        beforeEach {
          finalCache.clear()
        }
        
        it("should not dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledClear).to(equal(0))
        }
        
        it("should dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledClear).to(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          finalCache.onMemoryWarning()
        }
        
        it("should not dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledOnMemoryWarning).to(equal(0))
        }
        
        it("should dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
      }
    }
  }
}

class SwitchCacheTests: QuickSpec {
  override func spec() {
    var cacheA: CacheLevelFake<String, Int>!
    var cacheB: CacheLevelFake<String, Int>!
    var finalCache: BasicCache<String, Int>!
    
    describe("Switching two cache levels") {
      beforeEach {
        cacheA = CacheLevelFake<String, Int>()
        cacheB = CacheLevelFake<String, Int>()
        finalCache = switchLevels(cacheA, cacheB: cacheB, switchClosure: switchClosure)
      }
      
      itBehavesLike("a switched cache with 2 cache levels") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA,
          SwitchCacheSharedExamplesContext.CacheB: cacheB,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
        ]
      }
    }
    
    describe("Switching two fetch closures") {
      beforeEach {
        cacheA = CacheLevelFake<String, Int>()
        cacheB = CacheLevelFake<String, Int>()
        finalCache = switchLevels(cacheA.get, cacheB: cacheB.get, switchClosure: switchClosure)
      }
      
      itBehavesLike("a switched cache with 2 fetch closures") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA,
          SwitchCacheSharedExamplesContext.CacheB: cacheB,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
        ]
      }
    }
    
    describe("Switching a cache level and a fetch closure") {
      beforeEach {
        cacheA = CacheLevelFake<String, Int>()
        cacheB = CacheLevelFake<String, Int>()
        finalCache = switchLevels(cacheA, cacheB: cacheB.get, switchClosure: switchClosure)
      }
      
      itBehavesLike("a switched cache with a cache level and a fetch closure") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA,
          SwitchCacheSharedExamplesContext.CacheB: cacheB,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
        ]
      }
    }

    describe("Switching a fetch closure and a cache level") {
      beforeEach {
        cacheA = CacheLevelFake<String, Int>()
        cacheB = CacheLevelFake<String, Int>()
        finalCache = switchLevels(cacheA.get, cacheB: cacheB, switchClosure: switchClosure)
      }
      
      itBehavesLike("a switched cache with a fetch closure and a cache level") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA,
          SwitchCacheSharedExamplesContext.CacheB: cacheB,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
        ]
      }
    }
  }
}