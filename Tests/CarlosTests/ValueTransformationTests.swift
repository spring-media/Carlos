import Foundation

import Quick
import Nimble

import Carlos
import Combine

struct ValueTransformationsSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

final class ValueTransformationSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a cache with transformed values") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, String>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: TwoWayTransformationBox<Int, String>!
      var cancellable: AnyCancellable?
      
      var cancellables: Set<AnyCancellable>!
      
      beforeEach {
        cancellables = Set()
        
        cache = sharedExampleContext()[ValueTransformationsSharedExamplesContext.CacheToTest] as? BasicCache<String, String>
        internalCache = sharedExampleContext()[ValueTransformationsSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ValueTransformationsSharedExamplesContext.Transformer] as? TwoWayTransformationBox<Int, String>
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
        
        cancellables = nil
      }
      
      context("when calling get") {
        let key = "12"
        var successValue: String?
        var failureValue: Error?
        var fakeRequest: PassthroughSubject<Int, Error>!
        var canceled: Bool!
        
        beforeEach {
          canceled = false
          failureValue = nil
          successValue = nil
          
          fakeRequest = PassthroughSubject()
          internalCache.getSubject = fakeRequest
          
          cancellable = cache.get(key)
            .handleEvents(receiveCancel: {
              canceled = true
              
            })
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failureValue = error
              }
            }, receiveValue: { successValue = $0 })
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalCache.didGetKey).toEventually(equal(key))
        }
        
        context("when the request succeeds") {
          context("when the value can be successfully transformed") {
            let value = 101
            
            beforeEach {
              fakeRequest.send(value)
            }
            
            it("should call the original success closure") {
              expect(successValue).toEventuallyNot(beNil())
            }
            
            it("should transform the value") {
              var expected: String!
              transformer.transform(value)
                .sink(receiveCompletion: { _ in }, receiveValue: { expected = $0 })
                .store(in: &cancellables)
              
              expect(successValue).toEventually(equal(expected))
            }
            
            it("should not call the original cancel closure") {
              expect(canceled).toEventually(beFalse())
            }
            
            it("should not call the original failure closure") {
              expect(failureValue).toEventually(beNil())
            }
          }
          
          context("when the value transformation returns nil") {
            let value = -101
            
            beforeEach {
              successValue = nil
              fakeRequest.send(value)
            }
            
            it("should not call the original success closure") {
              expect(successValue).toEventually(beNil())
            }
            
            it("should call the original failure closure") {
              expect(failureValue).toEventuallyNot(beNil())
            }
            
            it("should fail with the right code") {
              expect(failureValue as? TestError).toEventually(equal(TestError.anotherError))
            }
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.anotherError
          
          beforeEach {
            fakeRequest.send(completion: .failure(errorCode))
          }
          
          it("should call the original failure closure") {
            expect(failureValue).toEventuallyNot(beNil())
          }
          
          it("should fail with the right code") {
            expect(failureValue as? TestError).toEventually(equal(errorCode))
          }
          
          it("should not call the original success closure") {
            expect(successValue).toEventually(beNil())
          }
          
          it("should not call the original cancel closure") {
            expect(canceled).toEventually(beFalse())
          }
        }
        
        context("when the request is canceled") {
          beforeEach {
            cancellable?.cancel()
          }
          
          it("should call the original cancel closure") {
            expect(canceled).toEventually(beTrue())
          }
          
          it("should not call the original failure closure") {
            expect(failureValue).toEventually(beNil())
          }
          
          it("should not call the original success closure") {
            expect(successValue).toEventually(beNil())
          }
        }
      }
      
      context("when calling set") {
        var setSucceeded: Bool!
        var setError: Error?
        
        beforeEach {
          setSucceeded = false
          setError = nil
        }
        
        context("when the inverse transformation succeeds") {
          let key = "test key to set"
          let value = "199"
          
          beforeEach {
            cancellable = cache.set(value, forKey: key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  setError = error
                }
              }, receiveValue: { setSucceeded = true })
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).toEventually(equal(1))
          }
          
          it("should pass the key") {
            expect(internalCache.didSetKey).toEventually(equal(key))
          }
          
          it("should transform the value first") {
            var expected: Int!
            transformer.inverseTransform(value)
              .sink(receiveCompletion: { _ in }, receiveValue: { expected = $0 })
              .store(in: &cancellables)
            expect(internalCache.didSetValue).toEventually(equal(expected))
          }
          
          context("when the set succeeds") {
            beforeEach {
              internalCache.setPublishers[key]?.send()
            }
            
            it("should succeed") {
              expect(setSucceeded).toEventually(beTrue())
            }
          }
          
          context("when the set fails") {
            beforeEach {
              internalCache.setPublishers[key]?.send(completion: .failure(TestError.anotherError))
            }
            
            it("should fail") {
              expect(setError).toEventuallyNot(beNil())
            }
            
            it("should pass the error through") {
              expect(setError as? TestError).toEventually(equal(TestError.anotherError))
            }
          }
        }
        
        context("when the inverse transformation fails") {
          let key = "test key to set"
          let value = "will fail"
          
          beforeEach {
            cancellable = cache.set(value, forKey: key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  setError = error
                }
              }, receiveValue: {
                setSucceeded = true
              })
          }
          
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).toEventually(equal(0))
          }
          
          it("should fail") {
            expect(setError).toEventuallyNot(beNil())
          }
          
          it("should pass the transformation error") {
            expect(setError as? TestError).toEventually(equal(TestError.anotherError))
          }
        }
      }
      
      context("when calling clear") {
        beforeEach {
          cache.clear()
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledClear).toEventually(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          cache.onMemoryWarning()
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }
      }
    }
  }
}

final class ValueTransformationTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, String>!
    var internalCache: CacheLevelFake<String, Int>!
    var transformer: TwoWayTransformationBox<Int, String>!
    let forwardTransformationClosure: (Int) -> AnyPublisher<String, Error> = {
      if $0 > 0 {
        return Just("\($0 + 1)").setFailureType(to: Error.self).eraseToAnyPublisher()
      }
      
      return Fail(error: TestError.anotherError).eraseToAnyPublisher()
    }
    let inverseTransformationClosure: (String) -> AnyPublisher<Int, Error> = {
      guard let intValue = Int($0) else {
        return Fail(error: TestError.anotherError).eraseToAnyPublisher()
      }
      
      return Just(intValue).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    describe("Value transformation using a transformer and a cache, with the instance function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = TwoWayTransformationBox(transform: forwardTransformationClosure, inverseTransform: inverseTransformationClosure)
        cache = internalCache.transformValues(transformer)
      }
      
      itBehavesLike("a cache with transformed values") {
        [
          ValueTransformationsSharedExamplesContext.CacheToTest: cache as Any,
          ValueTransformationsSharedExamplesContext.InternalCache: internalCache as Any,
          ValueTransformationsSharedExamplesContext.Transformer: transformer as Any
        ]
      }
    }
  }
}
