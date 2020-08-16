//import Foundation
//import Quick
//import Nimble
//import Carlos
//import PiedPiper
//
//let switchClosure: (String) -> CacheLevelSwitchResult = { str in
//  if str.count > 5 {
//    return .cacheA
//  } else {
//    return .cacheB
//  }
//}
//
//struct SwitchCacheSharedExamplesContext {
//  static let CacheA = "cacheA"
//  static let CacheB = "cacheB"
//  static let CacheToTest = "sutCache"
//}
//
//class SwitchCacheSharedExamplesConfiguration: QuickConfiguration {
//  override class func configure(_ configuration: Configuration) {
//    sharedExamples("should correctly get") { (sharedExampleContext: @escaping SharedExampleContext) in
//      var cacheA: CacheLevelFake<String, Int>!
//      var cacheB: CacheLevelFake<String, Int>!
//      var finalCache: BasicCache<String, Int>!
//      
//      beforeEach {
//        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
//        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
//        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
//      }
//      
//      context("when calling get") {
//        var fakeRequest: Promise<Int>!
//        var successValue: Int?
//        var errorValue: Error?
//        
//        beforeEach {
//          fakeRequest = Promise<Int>()
//          cacheA.cacheRequestToReturn = fakeRequest.future
//          cacheB.cacheRequestToReturn = fakeRequest.future
//          
//          successValue = nil
//          errorValue = nil
//        }
//        
//        context("when the switch closure returns cacheA") {
//          let key = "quite long key"
//          
//          beforeEach {
//            _ = finalCache.get(key)
//              .onSuccess { value in
//                successValue = value
//              }
//              .onFailure { error in
//                errorValue = error
//              }
//          }
//          
//          it("should not dispatch the call to the second cache") {
//            expect(cacheB.numberOfTimesCalledGet).to(equal(0))
//          }
//          
//          it("should dispatch the call to the first cache") {
//            expect(cacheA.numberOfTimesCalledGet).to(equal(1))
//          }
//          
//          it("should pass the right key") {
//            expect(cacheA.didGetKey).to(equal(key))
//          }
//          
//          context("when the request succeeds") {
//            let value = 2010
//            
//            beforeEach {
//              fakeRequest.succeed(value)
//            }
//            
//            it("should call the original success closure") {
//              expect(successValue).to(equal(value))
//            }
//            
//            it("should not call the original failure closure") {
//              expect(errorValue).to(beNil())
//            }
//          }
//          
//          context("when the request fails") {
//            let errorCode = TestError.simpleError
//            
//            beforeEach {
//              fakeRequest.fail(errorCode)
//            }
//            
//            it("should call the original failure closure") {
//              expect(errorValue as? TestError).to(equal(errorCode))
//            }
//            
//            it("should not call the original success closure") {
//              expect(successValue).to(beNil())
//            }
//          }
//        }
//        
//        context("when the switch closure returns cacheB") {
//          let key = "short"
//          
//          beforeEach {
//            _ = finalCache.get(key)
//              .onSuccess { value in
//                successValue = value
//              }
//              .onFailure { error in
//                errorValue = error
//            }
//          }
//          
//          it("should not dispatch the call to the first cache") {
//            expect(cacheA.numberOfTimesCalledGet).to(equal(0))
//          }
//          
//          it("should dispatch the call to the second cache") {
//            expect(cacheB.numberOfTimesCalledGet).to(equal(1))
//          }
//          
//          it("should pass the right key") {
//            expect(cacheB.didGetKey).to(equal(key))
//          }
//          
//          context("when the request succeeds") {
//            let value = 2010
//            
//            beforeEach {
//              fakeRequest.succeed(value)
//            }
//            
//            it("should call the original success closure") {
//              expect(successValue).to(equal(value))
//            }
//            
//            it("should not call the original failure closure") {
//              expect(errorValue).to(beNil())
//            }
//          }
//          
//          context("when the request fails") {
//            let errorCode = TestError.anotherError
//            
//            beforeEach {
//              fakeRequest.fail(errorCode)
//            }
//            
//            it("should call the original failure closure") {
//              expect(errorValue as? TestError).to(equal(errorCode))
//            }
//            
//            it("should not call the original success closure") {
//              expect(successValue).to(beNil())
//            }
//          }
//        }
//      }
//    }
//    
//    sharedExamples("a switched cache with 2 fetch closures") { (sharedExampleContext: @escaping SharedExampleContext) in
//      var cacheA: CacheLevelFake<String, Int>!
//      var cacheB: CacheLevelFake<String, Int>!
//      var finalCache: BasicCache<String, Int>!
//      
//      beforeEach {
//        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
//        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
//        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
//      }
//      
//      itBehavesLike("should correctly get") {
//        [
//          SwitchCacheSharedExamplesContext.CacheA: cacheA,
//          SwitchCacheSharedExamplesContext.CacheB: cacheB,
//          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
//        ]
//      }
//    }
//    
//    sharedExamples("a switched cache with 2 cache levels") { (sharedExampleContext: @escaping SharedExampleContext) in
//      var cacheA: CacheLevelFake<String, Int>!
//      var cacheB: CacheLevelFake<String, Int>!
//      var finalCache: BasicCache<String, Int>!
//      
//      beforeEach {
//        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
//        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
//        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
//      }
//      
//      itBehavesLike("should correctly get") {
//        [
//          SwitchCacheSharedExamplesContext.CacheA: cacheA,
//          SwitchCacheSharedExamplesContext.CacheB: cacheB,
//          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
//        ]
//      }
//      
//      context("when calling set") {
//        let value = 30
//        var setSucceeded: Bool!
//        var setError: Error?
//        
//        beforeEach {
//          setSucceeded = false
//          setError = nil
//        }
//        
//        context("when the switch closure returns cacheA") {
//          let key = "quite long key"
//          
//          beforeEach {
//            finalCache.set(value, forKey: key).onSuccess {
//              setSucceeded = true
//            }.onFailure {
//              setError = $0
//            }
//          }
//          
//          it("should not dispatch the call to the second cache") {
//            expect(cacheB.numberOfTimesCalledSet).to(equal(0))
//          }
//          
//          it("should dispatch the call to the first cache") {
//            expect(cacheA.numberOfTimesCalledSet).to(equal(1))
//          }
//          
//          it("should pass the right key") {
//            expect(cacheA.didSetKey).to(equal(key))
//          }
//          
//          it("should pass the right value") {
//            expect(cacheA.didSetValue).to(equal(value))
//          }
//          
//          context("when set succeeds") {
//            beforeEach {
//              cacheA.setPromisesReturned.first?.succeed(())
//            }
//            
//            it("should succeed") {
//              expect(setSucceeded).to(beTrue())
//            }
//          }
//          
//          context("when set fails") {
//            let setFailure = TestError.anotherError
//            
//            beforeEach {
//              cacheA.setPromisesReturned.first?.fail(setFailure)
//            }
//            
//            it("should fail") {
//              expect(setError).notTo(beNil())
//            }
//            
//            it("should pass the error through") {
//              expect(setError as? TestError).to(equal(setFailure))
//            }
//          }
//        }
//        
//        context("when the switch closure returns cacheB") {
//          let key = "short"
//          
//          beforeEach {
//            finalCache.set(value, forKey: key).onSuccess {
//              setSucceeded = true
//            }.onFailure {
//              setError = $0
//            }
//          }
//          
//          it("should not dispatch the call to the first cache") {
//            expect(cacheA.numberOfTimesCalledSet).to(equal(0))
//          }
//          
//          it("should dispatch the call to the second cache") {
//            expect(cacheB.numberOfTimesCalledSet).to(equal(1))
//          }
//          
//          it("should pass the right key") {
//            expect(cacheB.didSetKey).to(equal(key))
//          }
//          
//          it("should pass the right value") {
//            expect(cacheB.didSetValue).to(equal(value))
//          }
//          
//          context("when set succeeds") {
//            beforeEach {
//              cacheB.setPromisesReturned.first?.succeed(())
//            }
//            
//            it("should succeed") {
//              expect(setSucceeded).to(beTrue())
//            }
//          }
//          
//          context("when set fails") {
//            let setFailure = TestError.anotherError
//            
//            beforeEach {
//              cacheB.setPromisesReturned.first?.fail(setFailure)
//            }
//            
//            it("should fail") {
//              expect(setError).notTo(beNil())
//            }
//            
//            it("should pass the error through") {
//              expect(setError as? TestError).to(equal(setFailure))
//            }
//          }
//        }
//      }
//      
//      context("when calling clear") {
//        beforeEach {
//          finalCache.clear()
//        }
//        
//        it("should dispatch the call to the first cache") {
//          expect(cacheA.numberOfTimesCalledClear).to(equal(1))
//        }
//        
//        it("should dispatch the call to the second cache") {
//          expect(cacheB.numberOfTimesCalledClear).to(equal(1))
//        }
//      }
//      
//      context("when calling onMemoryWarning") {
//        beforeEach {
//          finalCache.onMemoryWarning()
//        }
//        
//        it("should dispatch the call to the first cache") {
//          expect(cacheA.numberOfTimesCalledOnMemoryWarning).to(equal(1))
//        }
//        
//        it("should dispatch the call to the second cache") {
//          expect(cacheB.numberOfTimesCalledOnMemoryWarning).to(equal(1))
//        }
//      }
//    }
//    
//    sharedExamples("a switched cache with a cache level and a fetch closure") { (sharedExampleContext: @escaping SharedExampleContext) in
//      var cacheA: CacheLevelFake<String, Int>!
//      var cacheB: CacheLevelFake<String, Int>!
//      var finalCache: BasicCache<String, Int>!
//      
//      beforeEach {
//        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
//        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
//        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
//      }
//      
//      itBehavesLike("should correctly get") {
//        [
//          SwitchCacheSharedExamplesContext.CacheA: cacheA,
//          SwitchCacheSharedExamplesContext.CacheB: cacheB,
//          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
//        ]
//      }
//      
//      context("when calling set") {
//        let value = 30
//        var setSucceeded: Bool!
//        var setError: Error?
//        
//        beforeEach {
//          setSucceeded = false
//          setError = nil
//        }
//        
//        context("when the switch closure returns cacheA") {
//          let key = "quite long key"
//          
//          beforeEach {
//            finalCache.set(value, forKey: key).onSuccess {
//              setSucceeded = true
//            }.onFailure {
//              setError = $0
//            }
//          }
//          
//          it("should not dispatch the call to the second cache") {
//            expect(cacheB.numberOfTimesCalledSet).to(equal(0))
//          }
//          
//          it("should dispatch the call to the first cache") {
//            expect(cacheA.numberOfTimesCalledSet).to(equal(1))
//          }
//          
//          it("should pass the right key") {
//            expect(cacheA.didSetKey).to(equal(key))
//          }
//          
//          it("should pass the right value") {
//            expect(cacheA.didSetValue).to(equal(value))
//          }
//          
//          context("when set succeeds") {
//            beforeEach {
//              cacheA.setPromisesReturned.first?.succeed(())
//            }
//            
//            it("should succeed") {
//              expect(setSucceeded).to(beTrue())
//            }
//          }
//          
//          context("when set fails") {
//            let setFailure = TestError.anotherError
//            
//            beforeEach {
//              cacheA.setPromisesReturned.first?.fail(setFailure)
//            }
//            
//            it("should fail") {
//              expect(setError).notTo(beNil())
//            }
//            
//            it("should pass the error through") {
//              expect(setError as? TestError).to(equal(setFailure))
//            }
//          }
//        }
//        
//        context("when the switch closure returns cacheB") {
//          let key = "short"
//          
//          beforeEach {
//            _ = finalCache.set(value, forKey: key)
//          }
//          
//          it("should not dispatch the call to the first cache") {
//            expect(cacheA.numberOfTimesCalledSet).to(equal(0))
//          }
//          
//          it("should not dispatch the call to the second cache") {
//            expect(cacheB.numberOfTimesCalledSet).to(equal(0))
//          }
//        }
//      }
//      
//      context("when calling clear") {
//        beforeEach {
//          finalCache.clear()
//        }
//        
//        it("should dispatch the call to the first cache") {
//          expect(cacheA.numberOfTimesCalledClear).to(equal(1))
//        }
//        
//        it("should not dispatch the call to the second cache") {
//          expect(cacheB.numberOfTimesCalledClear).to(equal(0))
//        }
//      }
//      
//      context("when calling onMemoryWarning") {
//        beforeEach {
//          finalCache.onMemoryWarning()
//        }
//        
//        it("should dispatch the call to the first cache") {
//          expect(cacheA.numberOfTimesCalledOnMemoryWarning).to(equal(1))
//        }
//        
//        it("should not dispatch the call to the second cache") {
//          expect(cacheB.numberOfTimesCalledOnMemoryWarning).to(equal(0))
//        }
//      }
//    }
//    
//    sharedExamples("a switched cache with a fetch closure and a cache level") { (sharedExampleContext: @escaping SharedExampleContext) in
//      var cacheA: CacheLevelFake<String, Int>!
//      var cacheB: CacheLevelFake<String, Int>!
//      var finalCache: BasicCache<String, Int>!
//      
//      beforeEach {
//        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
//        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
//        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
//      }
//      
//      itBehavesLike("should correctly get") {
//        [
//          SwitchCacheSharedExamplesContext.CacheA: cacheA,
//          SwitchCacheSharedExamplesContext.CacheB: cacheB,
//          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
//        ]
//      }
//      
//      context("when calling set") {
//        let value = 30
//        var setSucceeded: Bool!
//        var setError: Error?
//        
//        beforeEach {
//          setSucceeded = false
//          setError = nil
//        }
//        
//        context("when the switch closure returns cacheA") {
//          let key = "quite long key"
//          
//          beforeEach {
//            _ = finalCache.set(value, forKey: key)
//          }
//          
//          it("should not dispatch the call to the second cache") {
//            expect(cacheB.numberOfTimesCalledSet).to(equal(0))
//          }
//          
//          it("should not dispatch the call to the first cache") {
//            expect(cacheA.numberOfTimesCalledSet).to(equal(0))
//          }
//        }
//        
//        context("when the switch closure returns cacheB") {
//          let key = "short"
//          
//          beforeEach {
//            finalCache.set(value, forKey: key).onSuccess {
//              setSucceeded = true
//            }.onFailure {
//              setError = $0
//            }
//          }
//          
//          it("should not dispatch the call to the first cache") {
//            expect(cacheA.numberOfTimesCalledSet).to(equal(0))
//          }
//          
//          it("should dispatch the call to the second cache") {
//            expect(cacheB.numberOfTimesCalledSet).to(equal(1))
//          }
//          
//          it("should pass the right key") {
//            expect(cacheB.didSetKey).to(equal(key))
//          }
//          
//          it("should pass the right value") {
//            expect(cacheB.didSetValue).to(equal(value))
//          }
//          
//          context("when set succeeds") {
//            beforeEach {
//              cacheB.setPromisesReturned.first?.succeed(())
//            }
//            
//            it("should succeed") {
//              expect(setSucceeded).to(beTrue())
//            }
//          }
//          
//          context("when set fails") {
//            let setFailure = TestError.anotherError
//            
//            beforeEach {
//              cacheB.setPromisesReturned.first?.fail(setFailure)
//            }
//            
//            it("should fail") {
//              expect(setError).notTo(beNil())
//            }
//            
//            it("should pass the error through") {
//              expect(setError as? TestError).to(equal(setFailure))
//            }
//          }
//        }
//      }
//      
//      context("when calling clear") {
//        beforeEach {
//          finalCache.clear()
//        }
//        
//        it("should not dispatch the call to the first cache") {
//          expect(cacheA.numberOfTimesCalledClear).to(equal(0))
//        }
//        
//        it("should dispatch the call to the second cache") {
//          expect(cacheB.numberOfTimesCalledClear).to(equal(1))
//        }
//      }
//      
//      context("when calling onMemoryWarning") {
//        beforeEach {
//          finalCache.onMemoryWarning()
//        }
//        
//        it("should not dispatch the call to the first cache") {
//          expect(cacheA.numberOfTimesCalledOnMemoryWarning).to(equal(0))
//        }
//        
//        it("should dispatch the call to the second cache") {
//          expect(cacheB.numberOfTimesCalledOnMemoryWarning).to(equal(1))
//        }
//      }
//    }
//  }
//}
//
//class SwitchCacheTests: QuickSpec {
//  override func spec() {
//    var cacheA: CacheLevelFake<String, Int>!
//    var cacheB: CacheLevelFake<String, Int>!
//    var finalCache: BasicCache<String, Int>!
//    
//    describe("Switching two cache levels") {
//      beforeEach {
//        cacheA = CacheLevelFake<String, Int>()
//        cacheB = CacheLevelFake<String, Int>()
//        finalCache = switchLevels(cacheA: cacheA, cacheB: cacheB, switchClosure: switchClosure)
//      }
//      
//      itBehavesLike("a switched cache with 2 cache levels") {
//        [
//          SwitchCacheSharedExamplesContext.CacheA: cacheA,
//          SwitchCacheSharedExamplesContext.CacheB: cacheB,
//          SwitchCacheSharedExamplesContext.CacheToTest: finalCache
//        ]
//      }
//    }
//  }
//}
