import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

struct ConditionedPostProcessSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

final class ConditionedPostProcessSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a fetch closure with conditioned post-processing") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: ConditionedOneWayTransformationBox<String, Int, Int>!
      var cancellables: Set<AnyCancellable>!
      
      beforeEach {
        cancellables = Set()
        
        cache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.Transformer] as? ConditionedOneWayTransformationBox<String, Int, Int>
      }
      
      afterEach {
        cancellables = nil
      }
      
      context("when calling get with a key that triggers some post-processing") {
        let key = "do"
        var successValue: Int?
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
            var expected: Int!
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
      
      context("when calling get with a key that triggers failure on the post-processing") {
        let key = "don't"
        var successValue: Int?
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
        var successValue: Int?
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
              var expected: Int!
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
    }
    
    sharedExamples("a cache with conditioned post-processing") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: ConditionedOneWayTransformationBox<String, Int, Int>!
      
      beforeEach {
        cache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[ConditionedPostProcessSharedExamplesContext.Transformer] as? ConditionedOneWayTransformationBox<String, Int, Int>
      }
      
      itBehavesLike("a fetch closure with conditioned post-processing") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache as Any,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache as Any,
          ConditionedPostProcessSharedExamplesContext.Transformer: transformer as Any
        ]
      }
      
      context("when calling set") {
        let key = "10"
        let value = 222
        
        beforeEach {
          _ = cache.set(value, forKey: key)
        }
        
        it("should forward the call to the internal cache") {
          expect(internalCache.numberOfTimesCalledSet).toEventually(equal(1))
        }
        
        it("should forward the key") {
          expect(internalCache.didSetKey).toEventually(equal(key))
        }
        
        it("should pass the right value") {
          expect(internalCache.didSetValue).toEventually(equal(value))
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

final class ConditionedOutputPostProcessingTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    let transformer: ConditionedOneWayTransformationBox<String, Int, Int> = ConditionedOneWayTransformationBox(conditionalTransformClosure: { (key, value) in
      if key == "do" {
        return Just(value * 2).setFailureType(to: Error.self).eraseToAnyPublisher()
      } else if key == "don't" {
        return Fail(error: TestError.anotherError).eraseToAnyPublisher()
      }
      
      if value > 0 {
        return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
      }
      
      return Fail(error: TestError.simpleError).eraseToAnyPublisher()
    })
    
    describe("Conditioned post processing on a CacheLevel with the protocol extension") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        cache = internalCache.conditionedPostProcess(transformer)
      }
      
      itBehavesLike("a cache with conditioned post-processing") {
        [
          ConditionedPostProcessSharedExamplesContext.CacheToTest: cache as Any,
          ConditionedPostProcessSharedExamplesContext.InternalCache: internalCache as Any,
          ConditionedPostProcessSharedExamplesContext.Transformer: transformer as Any
        ]
      }
    }
  }
}
