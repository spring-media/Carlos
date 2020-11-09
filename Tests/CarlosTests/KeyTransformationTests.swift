import Foundation

import Nimble
import Quick

import Carlos
import Combine

struct KeyTransformationsSharedExamplesContext {
  static let CacheToTest = "cache"
  static let InternalCache = "internalCache"
  static let Transformer = "transformer"
}

final class KeyTransformationSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_: Configuration) {
    sharedExamples("a fetch closure with transformed keys") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<Int, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: OneWayTransformationBox<Int, String>!
      var cancellable: AnyCancellable?

      beforeEach {
        cache = sharedExampleContext()[KeyTransformationsSharedExamplesContext.CacheToTest] as? BasicCache<Int, Int>
        internalCache = sharedExampleContext()[KeyTransformationsSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[KeyTransformationsSharedExamplesContext.Transformer] as? OneWayTransformationBox<Int, String>
      }

      context("when calling get") {
        var successValue: Int?
        var failureValue: Error?
        var fakeRequest: PassthroughSubject<Int, Error>!
        var canceled: Bool!

        beforeEach {
          canceled = false
          failureValue = nil
          successValue = nil
        }

        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }

        context("when the transformation closure returns a value") {
          let key = 12

          beforeEach {
            fakeRequest = PassthroughSubject()
            internalCache.getSubject = fakeRequest

            cancellable = cache.get(key)
              .handleEvents(receiveCancel: { canceled = true })
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failureValue = error
                }
              }, receiveValue: { successValue = $0 })
          }

          it("should forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
          }

          it("should transform the key first") {
            var expected: String!
            _ = transformer.transform(key)
              .sink(receiveCompletion: { _ in }, receiveValue: { expected = $0 })

            expect(internalCache.didGetKey).toEventually(equal(expected))
          }

          context("when the request succeeds") {
            let value = 101

            beforeEach {
              fakeRequest.send(value)
            }

            it("should call the original success closure") {
              expect(successValue).toEventually(equal(value))
            }

            it("should not call the original failure closure") {
              expect(failureValue).toEventually(beNil())
            }

            it("should not call the original cancel closure") {
              expect(canceled).toEventually(beFalse())
            }
          }

          context("when the request is canceled") {
            beforeEach {
              cancellable?.cancel()
            }

            it("should not call the original failure closure") {
              expect(failureValue).toEventually(beNil())
            }

            it("should not call the original success closure") {
              expect(successValue).toEventually(beNil())
            }

            it("should call the original cancel closure") {
              expect(canceled).toEventually(beTrue())
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

            it("should not call the original success closure") {
              expect(successValue).toEventually(beNil())
            }

            it("should not call the original cancel closure") {
              expect(canceled).toEventually(beFalse())
            }
          }
        }

        context("when the transformation closure returns nil") {
          let key = -12

          beforeEach {
            fakeRequest = PassthroughSubject()
            internalCache.getSubject = fakeRequest

            _ = cache.get(key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failureValue = error
                }
              }, receiveValue: { successValue = $0 })
          }

          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledGet).toEventually(equal(0))
          }

          it("should not call the original success closure") {
            expect(successValue).toEventually(beNil())
          }

          it("should not call the original cancel closure") {
            expect(canceled).toEventually(beFalse())
          }

          it("should call the original failure closure") {
            expect(failureValue).toEventuallyNot(beNil())
          }

          it("should pass the right error code") {
            expect(failureValue as? TestError).toEventually(equal(TestError.simpleError))
          }
        }
      }
    }

    sharedExamples("a cache with transformed keys") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cache: BasicCache<Int, Int>!
      var internalCache: CacheLevelFake<String, Int>!
      var transformer: OneWayTransformationBox<Int, String>!

      beforeEach {
        cache = sharedExampleContext()[KeyTransformationsSharedExamplesContext.CacheToTest] as? BasicCache<Int, Int>
        internalCache = sharedExampleContext()[KeyTransformationsSharedExamplesContext.InternalCache] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[KeyTransformationsSharedExamplesContext.Transformer] as? OneWayTransformationBox<Int, String>
      }

      itBehavesLike("a fetch closure with transformed keys") {
        [
          KeyTransformationsSharedExamplesContext.CacheToTest: cache as Any,
          KeyTransformationsSharedExamplesContext.InternalCache: internalCache as Any,
          KeyTransformationsSharedExamplesContext.Transformer: transformer as Any
        ]
      }

      context("when calling set") {
        var setSucceeded: Bool!
        var setError: Error?
        var cancellable: AnyCancellable?

        beforeEach {
          setSucceeded = false
          setError = nil
        }

        afterEach {
          cancellable?.cancel()
          cancellable = nil
        }

        context("when the transformation closure returns a value") {
          let key = 10
          let value = 222

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

          it("should transform the key first") {
            var expected: String!
            _ = transformer.transform(key)
              .sink(receiveCompletion: { _ in }, receiveValue: { expected = $0 })
            expect(internalCache.didSetKey).toEventually(equal(expected))
          }

          it("should pass the right value") {
            expect(internalCache.didSetValue).toEventually(equal(value))
          }

          context("when the set succeeds") {
            beforeEach {
              internalCache.setPublishers["\(key + 1)"]?.send()
            }

            it("should succeed") {
              expect(setSucceeded).toEventually(beTrue())
            }
          }

          context("when the set fails") {
            beforeEach {
              internalCache.setPublishers["\(key + 1)"]?.send(completion: .failure(TestError.anotherError))
            }

            it("should fail") {
              expect(setError).toEventuallyNot(beNil())
            }

            it("should pass the error through") {
              expect(setError as? TestError).toEventually(equal(TestError.anotherError))
            }
          }
        }

        context("when the transformation closure fails") {
          let key = -10
          let value = 222

          beforeEach {
            cancellable = cache.set(value, forKey: key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  setError = error
                }
              }, receiveValue: { setSucceeded = true })
          }

          it("should not forward the call to the internal cache") {
            expect(internalCache.numberOfTimesCalledSet).toEventually(equal(0))
          }

          it("should fail") {
            expect(setError).toEventuallyNot(beNil())
          }

          it("should pass the transformation error") {
            expect(setError as? TestError).toEventually(equal(TestError.simpleError))
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

final class KeyTransformationTests: QuickSpec {
  override func spec() {
    var cache: BasicCache<Int, Int>!
    var internalCache: CacheLevelFake<String, Int>!
    var transformer: OneWayTransformationBox<Int, String>!
    let transformationClosure: (Int) -> AnyPublisher<String, Error> = {
      if $0 > 0 {
        return Just("\($0 + 1)").setFailureType(to: Error.self).eraseToAnyPublisher()
      }

      return Fail(error: TestError.simpleError).eraseToAnyPublisher()
    }

    describe("Key transformation using a transformer and a cache, with the instance function") {
      beforeEach {
        internalCache = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: transformationClosure)
        cache = internalCache.transformKeys(transformer)
      }

      itBehavesLike("a cache with transformed keys") {
        [
          KeyTransformationsSharedExamplesContext.CacheToTest: cache as Any,
          KeyTransformationsSharedExamplesContext.InternalCache: internalCache as Any,
          KeyTransformationsSharedExamplesContext.Transformer: transformer as Any
        ]
      }
    }
  }
}
