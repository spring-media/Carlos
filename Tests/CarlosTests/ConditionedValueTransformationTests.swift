import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

struct ConditionedValueTransformationSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

final class ConditionedValueTransformationSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a cache with conditioned value transformation") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Float>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: ConditionedTwoWayTransformationBox<String, Int, Float>!
      var cancellables: Set<AnyCancellable>!
      
      beforeEach {
        cancellables = Set<AnyCancellable>()
        
        cache = sharedExampleContext()[ConditionedValueTransformationSharedExamplesContext.CacheToTest] as? BasicCache<String, Float>
        internalCache = sharedExampleContext()[ConditionedValueTransformationSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ConditionedValueTransformationSharedExamplesContext.Transformer] as? ConditionedTwoWayTransformationBox<String, Int, Float>
      }
      
      afterEach {
        cancellables = nil
      }
      
      context("when calling get with a key that meets the condition") {
        let key = "do"
        var successValue: Float?
        var failureValue: Error?
        var getSubject: PassthroughSubject<Int, Error>!
        
        beforeEach {
          getSubject = PassthroughSubject()
          internalCache.getSubject = getSubject
          successValue = nil
          failureValue = nil
          
          cache.get(key)
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failureValue = error
              }
            }, receiveValue: { successValue = $0 })
            .store(in: &cancellables)
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should forward the key") {
          expect(internalCache.didGetKey).toEventually(equal(key))
        }
        
        context("when the request succeeds") {
          let value = 101
          
          beforeEach {
            getSubject.send(value)
          }
          
          it("should call the transformation closure with the right value") {
            var expected: Float!
            transformer.conditionalTransform(key: key, value: value)
              .sink(receiveCompletion: { _ in }, receiveValue: { expected = $0 })
              .store(in: &cancellables)
            expect(successValue).toEventually(equal(expected))
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.simpleError
          
          beforeEach {
            getSubject.send(completion: .failure(errorCode))
          }
          
          it("should call the original failure closure") {
            expect(failureValue as? TestError).toEventually(equal(errorCode))
          }
        }
      }
      
      context("when calling get with a key that doesn't meet the condition") {
        let key = "don't"
        var successValue: Float?
        var failureValue: Error?
        var getSubject: PassthroughSubject<Int, Error>!
        
        beforeEach {
          getSubject = PassthroughSubject()
          internalCache.getSubject = getSubject
          successValue = nil
          failureValue = nil
          
          cache.get(key)
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failureValue = error
              }
            }, receiveValue: { successValue = $0 })
            .store(in: &cancellables)
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should forward the key") {
          expect(internalCache.didGetKey).toEventually(equal(key))
        }
        
        context("when the request succeeds") {
          let value = -101
          
          beforeEach {
            getSubject.send(value)
          }
          
          it("should not call the original success closure") {
            expect(successValue).toEventually(beNil())
          }
          
          it("should call the original failure closure") {
            expect(failureValue).toEventuallyNot(beNil())
          }
          
          it("should pass the right error code") {
            expect(failureValue as? TestError).toEventually(equal(TestError.anotherError))
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.simpleError
          
          beforeEach {
            getSubject.send(completion: .failure(errorCode))
          }
          
          it("should call the original failure closure") {
            expect(failureValue as? TestError).toEventually(equal(errorCode))
          }
        }
      }
      
      context("when calling get") {
        let key = "12"
        var successValue: Float?
        var failureValue: Error?
        var getSubject: PassthroughSubject<Int, Error>!
        
        beforeEach {
          getSubject = PassthroughSubject()
          internalCache.getSubject = getSubject
          successValue = nil
          failureValue = nil
          
          cache.get(key)
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failureValue = error
              }
            }, receiveValue: { successValue = $0 })
            .store(in: &cancellables)
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should forward the key") {
          expect(internalCache.didGetKey).toEventually(equal(key))
        }
        
        context("when the request succeeds") {
          context("when the transformation closure returns a value") {
            let value = 101
            
            beforeEach {
              getSubject.send(value)
            }
            
            it("should call the transformation closure with the success value") {
              var expected: Float!
              transformer.conditionalTransform(key: key, value: value)
                .sink(receiveCompletion: { _ in }, receiveValue: { expected = $0 })
                .store(in: &cancellables)
              expect(successValue).toEventually(equal(expected))
            }
          }
          
          context("when the transformation closure returns nil") {
            let value = -101
            
            beforeEach {
              getSubject.send(value)
            }
            
            it("should not call the original success closure") {
              expect(successValue).toEventually(beNil())
            }
            
            it("should call the original failure closure") {
              expect(failureValue).toEventuallyNot(beNil())
            }
            
            it("should pass the right error code") {
              expect(failureValue as? TestError).toEventually(equal(TestError.simpleError))
            }
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.anotherError
          
          beforeEach {
            getSubject.send(completion: .failure(errorCode))
          }
          
          it("should call the original failure closure") {
            expect(failureValue as? TestError).toEventually(equal(errorCode))
          }
        }
      }
      
      context("when calling set") {
        var failed: Error?
        var succeeded: Bool!
        var canceled: Bool!
        
        beforeEach {
          canceled = false
          succeeded = false
          failed = nil
        }
        
        context("when the condition is met") {
          let key = "10"
          let value: Float = 222
          
          beforeEach {
            cache.set(value, forKey: key)
              .handleEvents(receiveCancel: { canceled = true })
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failed = error
                }
              }, receiveValue: { _ in succeeded = true })
              .store(in: &cancellables)
          }
          
          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).toEventually(equal(1))
          }
          
          it("should forward the key") {
            expect(internalCache.didSetKey).toEventually(equal(key))
          }
          
          it("should pass the right value") {
            expect(internalCache.didSetValue).toEventually(equal(Int(value)))
          }
          
          context("when the set closure succeeds") {
            beforeEach {
              internalCache.setPublishers[key]?.send()
            }
            
            it("should succeed the future") {
              expect(succeeded).toEventually(beTrue())
            }
          }
          
          context("when the set clousure is canceled") {
            beforeEach {
              cancellables.first?.cancel()
            }
            
            it("should cancel the future") {
              expect(canceled).toEventually(beTrue())
            }
          }
          
          context("when the set closure fails") {
            let error = TestError.anotherError
            
            beforeEach {
              internalCache.setPublishers[key]?.send(completion: .failure(error))
            }
            
            it("should fail the future") {
              expect(failed as? TestError).toEventually(equal(error))
            }
          }
        }
        
        context("when the condition is not met") {
          let key = "Test"
          let value: Float = -222
          
          beforeEach {
            cache.set(value, forKey: key)
              .handleEvents(receiveCancel: { canceled = true })
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failed = error
                }
              }, receiveValue: { _ in succeeded = true })
              .store(in: &cancellables)
          }
          
          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).toEventually(equal(0))
          }
          
          it("should fail the future") {
            expect(failed).toEventuallyNot(beNil())
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

final class ConditionedValueTransformationTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Float>!
    var internalCache: CacheLevelFake<String, Int>!
    let transformer: ConditionedTwoWayTransformationBox<String, Int, Float> = ConditionedTwoWayTransformationBox(conditionalTransformClosure: { (key, value) in
      if key == "do" {
        return Just(Float(value * 2)).setFailureType(to: Error.self).eraseToAnyPublisher()
      } else if key == "don't" {
        return Fail(error: TestError.anotherError).eraseToAnyPublisher()
      }
      
      if value > 0 {
        return Just(Float(value)).setFailureType(to: Error.self).eraseToAnyPublisher()
      }
      
      return Fail(error: TestError.simpleError).eraseToAnyPublisher()
    }, conditionalInverseTransformClosure: { (key, value) in
      if key == "do" {
        return Just(Int(value / 2)).setFailureType(to: Error.self).eraseToAnyPublisher()
      } else if key == "don't" {
        return Fail(error: TestError.anotherError).eraseToAnyPublisher()
      }
      
      if value > 0 {
        return Just(Int(value)).setFailureType(to: Error.self).eraseToAnyPublisher()
      }
      
      return Fail(error: TestError.simpleError).eraseToAnyPublisher()
    })
    
    describe("Conditioned post processing on a CacheLevel with the protocol extension") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.conditionedValueTransformation(transformer: transformer)
      }
      
      itBehavesLike("a cache with conditioned value transformation") {
        [
          ConditionedValueTransformationSharedExamplesContext.CacheToTest: cache as Any,
          ConditionedValueTransformationSharedExamplesContext.InternalCache: internalCache as Any,
          ConditionedValueTransformationSharedExamplesContext.Transformer: transformer as Any
        ]
      }
    }
  }
}
