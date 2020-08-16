//import Foundation
//import Quick
//import Nimble
//import Carlos
//import PiedPiper
//
//struct ValueTransformationsSharedExamplesContext {
//  static let CacheToTest = "cache"
//  static let InternalCache = "internalCache"
//  static let Transformer = "transformer"
//}
//
//class ValueTransformationSharedExamplesConfiguration: QuickConfiguration {
//  override class func configure(_ configuration: Configuration) {
//    sharedExamples("a cache with transformed values") { (sharedExampleContext: @escaping SharedExampleContext) in
//      var cache: BasicCache<String, String>!
//      var internalCache: CacheLevelFake<String, Int>!
//      var transformer: TwoWayTransformationBox<Int, String>!
//      
//      beforeEach {
//        cache = sharedExampleContext()[ValueTransformationsSharedExamplesContext.CacheToTest] as? BasicCache<String, String>
//        internalCache = sharedExampleContext()[ValueTransformationsSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
//        transformer = sharedExampleContext()[ValueTransformationsSharedExamplesContext.Transformer] as? TwoWayTransformationBox<Int, String>
//      }
//      
//      context("when calling get") {
//        let key = "12"
//        var successValue: String?
//        var failureValue: Error?
//        var fakeRequest: Promise<Int>!
//        var canceled: Bool!
//        
//        beforeEach {
//          canceled = false
//          failureValue = nil
//          successValue = nil
//          
//          fakeRequest = Promise<Int>()
//          internalCache.cacheRequestToReturn = fakeRequest.future
//          
//          cache.get(key).onSuccess { successValue = $0 }.onFailure { failureValue = $0 }.onCancel { canceled = true }
//        }
//        
//        it("should forward the call to the internal cache") {
//          expect(internalCache.numberOfTimesCalledGet).to(equal(1))
//        }
//        
//        it("should pass the right key") {
//          expect(internalCache.didGetKey).to(equal(key))
//        }
//        
//        context("when the request succeeds") {
//          context("when the value can be successfully transformed") {
//            let value = 101
//            
//            beforeEach {
//              fakeRequest.succeed(value)
//            }
//            
//            it("should call the original success closure") {
//              expect(successValue).notTo(beNil())
//            }
//            
//            it("should transform the value") {
//              var expected: String!
//              transformer.transform(value).onSuccess { expected = $0 }
//              expect(successValue).to(equal(expected))
//            }
//            
//            it("should not call the original cancel closure") {
//              expect(canceled).to(beFalse())
//            }
//            
//            it("should not call the original failure closure") {
//              expect(failureValue).to(beNil())
//            }
//          }
//          
//          context("when the value transformation returns nil") {
//            let value = -101
//            
//            beforeEach {
//              successValue = nil
//              fakeRequest.succeed(value)
//            }
//            
//            it("should not call the original success closure") {
//              expect(successValue).to(beNil())
//            }
//            
//            it("should call the original failure closure") {
//              expect(failureValue).notTo(beNil())
//            }
//            
//            it("should fail with the right code") {
//              expect(failureValue as? TestError).to(equal(TestError.anotherError))
//            }
//          }
//        }
//        
//        context("when the request fails") {
//          let errorCode = TestError.anotherError
//          
//          beforeEach {
//            fakeRequest.fail(errorCode)
//          }
//          
//          it("should call the original failure closure") {
//            expect(failureValue).notTo(beNil())
//          }
//          
//          it("should fail with the right code") {
//            expect(failureValue as? TestError).to(equal(errorCode))
//          }
//          
//          it("should not call the original success closure") {
//            expect(successValue).to(beNil())
//          }
//          
//          it("should not call the original cancel closure") {
//            expect(canceled).to(beFalse())
//          }
//        }
//        
//        context("when the request is canceled") {
//          beforeEach {
//            fakeRequest.cancel()
//          }
//          
//          it("should call the original cancel closure") {
//            expect(canceled).to(beTrue())
//          }
//          
//          it("should not call the original failure closure") {
//            expect(failureValue).to(beNil())
//          }
//          
//          it("should not call the original success closure") {
//            expect(successValue).to(beNil())
//          }
//        }
//      }
//      
//      context("when calling set") {
//        var setSucceeded: Bool!
//        var setError: Error?
//        
//        beforeEach {
//          setSucceeded = false
//          setError = nil
//        }
//        
//        context("when the inverse transformation succeeds") {
//          let key = "test key to set"
//          let value = "199"
//          
//          beforeEach {
//            cache.set(value, forKey: key).onSuccess {
//              setSucceeded = true
//            }.onFailure {
//              setError = $0
//            }
//          }
//          
//          it("should forward the call to the internal cache") {
//            expect(internalCache.numberOfTimesCalledSet).to(equal(1))
//          }
//          
//          it("should pass the key") {
//            expect(internalCache.didSetKey).to(equal(key))
//          }
//          
//          it("should transform the value first") {
//            var expected: Int!
//            transformer.inverseTransform(value).onSuccess { expected = $0 }
//            expect(internalCache.didSetValue).to(equal(expected))
//          }
//          
//          context("when the set succeeds") {
//            beforeEach {
//              internalCache.setPromisesReturned.first?.succeed(())
//            }
//            
//            it("should succeed") {
//              expect(setSucceeded).to(beTrue())
//            }
//          }
//          
//          context("when the set fails") {
//            beforeEach {
//              internalCache.setPromisesReturned.first?.fail(TestError.anotherError)
//            }
//            
//            it("should fail") {
//              expect(setError).notTo(beNil())
//            }
//            
//            it("should pass the error through") {
//              expect(setError as? TestError).to(equal(TestError.anotherError))
//            }
//          }
//        }
//        
//        context("when the inverse transformation fails") {
//          let key = "test key to set"
//          let value = "will fail"
//          
//          beforeEach {
//            cache.set(value, forKey: key).onSuccess {
//              setSucceeded = true
//            }.onFailure {
//              setError = $0
//            }
//          }
//          
//          it("should not forward the call to the internal cache") {
//            expect(internalCache.numberOfTimesCalledSet).to(equal(0))
//          }
//          
//          it("should fail") {
//            expect(setError).notTo(beNil())
//          }
//          
//          it("should pass the transformation error") {
//            expect(setError as? TestError).to(equal(TestError.anotherError))
//          }
//        }
//      }
//      
//      context("when calling clear") {
//        beforeEach {
//          cache.clear()
//        }
//        
//        it("should forward the call to the internal cache") {
//          expect(internalCache.numberOfTimesCalledClear).to(equal(1))
//        }
//      }
//      
//      context("when calling onMemoryWarning") {
//        beforeEach {
//          cache.onMemoryWarning()
//        }
//        
//        it("should forward the call to the internal cache") {
//          expect(internalCache.numberOfTimesCalledOnMemoryWarning).to(equal(1))
//        }
//      }
//    }
//  }
//}
//
//class ValueTransformationTests: QuickSpec {
//  override func spec() {
//    var cache: BasicCache<String, String>!
//    var internalCache: CacheLevelFake<String, Int>!
//    var transformer: TwoWayTransformationBox<Int, String>!
//    let forwardTransformationClosure: (Int) -> Future<String> = {
//      let result = Promise<String>()
//      if $0 > 0 {
//        result.succeed("\($0 + 1)")
//      } else {
//        result.fail(TestError.anotherError)
//      }
//      return result.future
//    }
//    let inverseTransformationClosure: (String) -> Future<Int> = {
//      return Future(value: Int($0), error: TestError.anotherError)
//    }
//        
//    describe("Value transformation using a transformer and a cache, with the instance function") {
//      beforeEach {
//        internalCache = CacheLevelFake<String, Int>()
//        transformer = TwoWayTransformationBox(transform: forwardTransformationClosure, inverseTransform: inverseTransformationClosure)
//        cache = internalCache.transformValues(transformer)
//      }
//      
//      itBehavesLike("a cache with transformed values") {
//        [
//          ValueTransformationsSharedExamplesContext.CacheToTest: cache,
//          ValueTransformationsSharedExamplesContext.InternalCache: internalCache,
//          ValueTransformationsSharedExamplesContext.Transformer: transformer
//        ]
//      }
//    }
//  }
//}
