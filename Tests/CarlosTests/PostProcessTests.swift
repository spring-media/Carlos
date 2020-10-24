import Foundation

import Nimble
import Quick

import Carlos
import Combine

struct PostProcessSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

final class PostProcessSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_: Configuration) {
    sharedExamples("a fetch closure with post-processing step") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: OneWayTransformationBox<Int, Int>!
      var cancellables: Set<AnyCancellable>!

      beforeEach {
        cancellables = Set<AnyCancellable>()

        cache = sharedExampleContext()[PostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[PostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[PostProcessSharedExamplesContext.Transformer] as? OneWayTransformationBox<Int, Int>
      }

      afterEach {
        cancellables = nil
      }

      context("when calling get") {
        let key = "12"
        var successValue: Int?
        var failureValue: Error?
        var fakeRequest: PassthroughSubject<Int, Error>!

        beforeEach {
          fakeRequest = PassthroughSubject()
          internalCache.getSubject = fakeRequest
          successValue = nil
          failureValue = nil

          cache.get(key).sink(receiveCompletion: { completion in
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
              fakeRequest.send(value)
            }

            it("should call the transformer with the success value") {
              var expected: Int!
              transformer.transform(value)
                .sink(receiveCompletion: { _ in }, receiveValue: { expected = $0 })
                .store(in: &cancellables)

              expect(successValue).toEventually(equal(expected))
            }
          }

          context("when the transformation closure returns nil") {
            let value = -101

            beforeEach {
              fakeRequest.send(value)
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
            fakeRequest.send(completion: .failure(errorCode))
          }

          it("should call the original failure closure") {
            expect(failureValue as? TestError).toEventually(equal(errorCode))
          }
        }
      }
    }

    sharedExamples("a cache with post-processing step") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<String, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: OneWayTransformationBox<Int, Int>!
      var cancellables: Set<AnyCancellable>!

      beforeEach {
        cancellables = Set()
        cache = sharedExampleContext()[PostProcessSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
        internalCache = sharedExampleContext()[PostProcessSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[PostProcessSharedExamplesContext.Transformer] as? OneWayTransformationBox<Int, Int>
      }

      afterEach {
        cancellables = nil
      }

      itBehavesLike("a fetch closure with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache as Any,
          PostProcessSharedExamplesContext.InternalCache: internalCache as Any,
          PostProcessSharedExamplesContext.Transformer: transformer as Any
        ]
      }

      context("when calling set") {
        let key = "10"
        let value = 222

        beforeEach {
          cache.set(value, forKey: key)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
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

final class PostProcessTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<String, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    var transformer: OneWayTransformationBox<Int, Int>!
    let transformationClosure: (Int) -> AnyPublisher<Int, Error> = {
      if $0 > 0 {
        return Just($0 + 1).setFailureType(to: Error.self).eraseToAnyPublisher()
      }

      return Fail(error: TestError.simpleError).eraseToAnyPublisher()
    }

    describe("Post processing using a transformer and a cache, with the instance function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = internalCache.postProcess(transformer)
      }

      itBehavesLike("a cache with post-processing step") {
        [
          PostProcessSharedExamplesContext.CacheToTest: cache as Any,
          PostProcessSharedExamplesContext.InternalCache: internalCache as Any,
          PostProcessSharedExamplesContext.Transformer: transformer as Any
        ]
      }
    }
  }
}
