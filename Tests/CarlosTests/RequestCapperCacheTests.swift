import Foundation
import Quick
import Nimble
@testable import Carlos
import PiedPiper

struct RequestCapperCacheSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let RequestCap = "requestCap"
}

class RequestCappingSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a request capped cache") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: RequestCapperCache<CacheLevelFake<String, Int>>!
      var internalCache: CacheLevelFake<String, Int>!
      var requestCap: Int!
      
      beforeEach {
        cache = sharedExampleContext()[RequestCapperCacheSharedExamplesContext.CacheToTest] as? RequestCapperCache<CacheLevelFake<String, Int>>
        internalCache = sharedExampleContext()[RequestCapperCacheSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        requestCap = sharedExampleContext()[RequestCapperCacheSharedExamplesContext.RequestCap] as? Int
      }
      
      context("when calling get") {
        let key = "test-key"
        let value = 10211
        var successSentinel: Bool?
        var failureSentinel: Bool?
        var successValue: Int?
        var requestToReturn: Promise<Int>!
        
        beforeEach {
          successSentinel = nil
          failureSentinel = nil
          
          requestToReturn = Promise<Int>()
          internalCache.cacheRequestToReturn = requestToReturn.future
          
          _ = cache.get(key).onSuccess({ value in
            successSentinel = true
            successValue = value
          }).onFailure({ _ in
            failureSentinel = true
          })
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalCache.didGetKey).toEventually(equal(key))
        }
        
        context("when the request succeeds") {
          beforeEach {
            requestToReturn.succeed(value)
          }
          
          it("should call the original success closure") {
            expect(successSentinel).toEventually(beTrue())
          }
          
          it("should not call the original failure closure") {
            expect(failureSentinel).toEventually(beNil())
          }
          
          it("should pass the right value to the success closure") {
            expect(successValue).toEventually(equal(value))
          }
        }
        
        context("when the request fails") {
          beforeEach {
            requestToReturn.fail(TestError.simpleError)
          }
          
          it("should call the original failure closure") {
            expect(failureSentinel).toEventually(beTrue())
          }
          
          it("should not call the original success closure") {
            expect(successSentinel).toEventually(beNil())
          }
        }
        
        context("when more requests are made that don't exceed the cap") {
          var morePendingRequests: [Promise<Int>] = []
          
          beforeEach {
            morePendingRequests = []
            
            for _ in (1..<requestCap).enumerated() {
              let fakeRequest = Promise<Int>()
              internalCache.cacheRequestToReturn = fakeRequest.future
              
              _ = cache.get(key)
              
              morePendingRequests.append(fakeRequest)
            }
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).toEventually(equal(requestCap))
          }
          
          context("when the requests exceed the cap") {
            var exceedingRequestSuccess: Bool?
            var exceedingRequestFailure: Bool?
            var exceedingRequestValue: Int?
            var exceedingRequest: Promise<Int>!
            
            beforeEach {
              exceedingRequestSuccess = nil
              exceedingRequestFailure = nil
              exceedingRequestValue = nil
              
              exceedingRequest = Promise<Int>()
              internalCache.cacheRequestToReturn = exceedingRequest.future
              
              cache.get(key).onSuccess({ value in
                exceedingRequestSuccess = true
                exceedingRequestValue = value
              }).onFailure({ _ in
                exceedingRequestFailure = true
              })
            }
            
            it("should not forward the call to the internal cache") {
              expect(internalCache.numberOfTimesCalledGet).toEventually(equal(requestCap))
            }
            
            it("should not call the success closure") {
              expect(exceedingRequestSuccess).toEventually(beNil())
            }
            
            it("should not call the failure closure") {
              expect(exceedingRequestFailure).toEventually(beNil())
            }
            
            context("when one of the ongoing requests succeeds") {
              let pendingSuccess = 989
              let ongoingRequestIndex = 0
              
              beforeEach {
                morePendingRequests[ongoingRequestIndex].succeed(pendingSuccess)
              }
              
              xit("should forward the pending call to the internal cache") {
                expect(internalCache.numberOfTimesCalledGet).toEventually(equal(requestCap + 1), timeout: 3)
              }
              
              context("when the pending call succeeds") {
                let exceedingValue = -121
                
                beforeEach {
                  exceedingRequest.succeed(exceedingValue)
                }
                
                it("should call the original success closure") {
                  expect(exceedingRequestSuccess).toEventually(beTrue())
                }
                
                it("should not call the original failure closure") {
                  expect(exceedingRequestFailure).toEventually(beNil())
                }
                
                it("should pass the right value to the closure") {
                  expect(exceedingRequestValue).toEventually(equal(exceedingValue))
                }
              }
              
              context("when the pending call fails") {
                beforeEach {
                  exceedingRequest.fail(TestError.anotherError)
                }
                
                it("should call the original failure closure") {
                  expect(exceedingRequestFailure).toEventually(beTrue())
                }
                
                it("should not call the original success closure") {
                  expect(exceedingRequestSuccess).toEventually(beNil())
                }
              }
            }
            
            context("when one of the ongoing requests fails") {
              let ongoingRequestIndex = 0
              
              beforeEach {
                morePendingRequests[ongoingRequestIndex].fail(TestError.simpleError)
              }
              
              xit("should forward the pending call to the internal cache") {
                expect(internalCache.numberOfTimesCalledGet).toEventually(equal(requestCap + 1), timeout: 3)
              }
              
              context("when the pending call succeeds") {
                let exceedingValue = -1212
                
                beforeEach {
                  exceedingRequest.succeed(exceedingValue)
                }
                
                it("should call the original success closure") {
                  expect(exceedingRequestSuccess).toEventually(beTrue())
                }
                
                it("should not call the original failure closure") {
                  expect(exceedingRequestFailure).toEventually(beNil())
                }
                
                it("should pass the right value to the closure") {
                  expect(exceedingRequestValue).toEventually(equal(exceedingValue))
                }
              }
              
              context("when the pending call fails") {
                beforeEach {
                  exceedingRequest.fail(TestError.anotherError)
                }
                
                it("should call the original failure closure") {
                  expect(exceedingRequestFailure).toEventually(beTrue())
                }
                
                it("should not call the original success closure") {
                  expect(exceedingRequestSuccess).toEventually(beNil())
                }
              }
            }
          }
        }
      }
      
      context("when calling set") {
        let key = "test_key"
        let value = 1021
        var setSucceeded: Bool!
        var setError: Error?
        
        beforeEach {
          setSucceeded = false
          setError = nil
        
          cache.set(value, forKey: key).onSuccess {
            setSucceeded = true
          }.onFailure {
            setError = $0
          }
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledSet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalCache.didSetKey).to(equal(key))
        }
        
        it("should pass the right value") {
          expect(internalCache.didSetValue).to(equal(value))
        }
        
        context("when set succeeds") {
          beforeEach {
            internalCache.setPromisesReturned.first?.succeed(())
          }
          
          it("should succeed") {
            expect(setSucceeded).to(beTrue())
          }
        }
        
        context("when set fails") {
          let setFailure = TestError.anotherError
          
          beforeEach {
            internalCache.setPromisesReturned.first?.fail(setFailure)
          }
          
          it("should fail") {
            expect(setError).notTo(beNil())
          }
          
          it("should pass the error through") {
            expect(setError as? TestError).to(equal(setFailure))
          }
        }
        
        context("when calling set multiple times") {
          var moreTimes: Int!
          
          beforeEach {
            moreTimes = requestCap + 1
            internalCache.numberOfTimesCalledSet = 0
            
            for _ in 0..<moreTimes {
              _ = cache.set(value, forKey: key)
            }
          }
          
          it("should not cap these requests") {
            expect(internalCache.numberOfTimesCalledSet).to(equal(moreTimes))
          }
        }
      }
      
      context("when calling clear") {
        beforeEach {
          cache.clear()
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledClear).to(equal(1))
        }
        
        context("when calling clear multiple times") {
          var moreTimes: Int!
          
          beforeEach {
            moreTimes = requestCap + 1
            internalCache.numberOfTimesCalledClear = 0
            
            for _ in 0..<moreTimes {
              cache.clear()
            }
          }
          
          it("should not cap these requests") {
            expect(internalCache.numberOfTimesCalledClear).to(equal(moreTimes))
          }
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          cache.onMemoryWarning()
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
        
        context("when calling onMemoryWarning multiple times") {
          var moreTimes: Int!
          
          beforeEach {
            moreTimes = requestCap + 1
            internalCache.numberOfTimesCalledOnMemoryWarning = 0
            
            for _ in 0..<moreTimes {
              cache.onMemoryWarning()
            }
          }
          
          it("should not cap these requests") {
            expect(internalCache.numberOfTimesCalledOnMemoryWarning).to(equal(moreTimes))
          }
        }
      }
    }
  }
}

class RequestCapperCacheTests: QuickSpec {
  override func spec() {
    var cache: RequestCapperCache<CacheLevelFake<String, Int>>!
    var internalCache: CacheLevelFake<String, Int>!
    let requestCap = 3
    
    xdescribe("RequestCapperCache") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = RequestCapperCache<CacheLevelFake<String, Int>>(internalCache: internalCache, requestCap: requestCap)
      }
      
      itBehavesLike("a request capped cache") {
        [
          RequestCapperCacheSharedExamplesContext.CacheToTest: cache,
          RequestCapperCacheSharedExamplesContext.InternalCache: internalCache,
          RequestCapperCacheSharedExamplesContext.RequestCap: requestCap
        ]
      }
    }
    
    xdescribe("The capRequests instance function, when applied on a cache level") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.capRequests(requestCap)
      }
      
      itBehavesLike("a request capped cache") {
        [
          RequestCapperCacheSharedExamplesContext.CacheToTest: cache,
          RequestCapperCacheSharedExamplesContext.InternalCache: internalCache,
          RequestCapperCacheSharedExamplesContext.RequestCap: requestCap
        ]
      }
    }
  }
}
