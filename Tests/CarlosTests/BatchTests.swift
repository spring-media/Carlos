import Foundation

import Nimble
import Quick

import Carlos
import Combine

final class BatchAllCacheTests: QuickSpec {
  override func spec() {
    describe("allBatch") {
      let requestsCount = 5

      var internalCache: CacheLevelFake<Int, String>!
      var cache: BatchAllCache<[Int], CacheLevelFake<Int, String>>!
      var cancellable: AnyCancellable?

      beforeEach {
        internalCache = CacheLevelFake<Int, String>()
        cache = internalCache.allBatch()
      }

      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }

      context("when calling clear") {
        beforeEach {
          cache.clear()
        }

        it("should call clear on the internal cache") {
          expect(internalCache.numberOfTimesCalledClear).toEventually(equal(1))
        }
      }

      context("when calling onMemoryWarning") {
        beforeEach {
          cache.onMemoryWarning()
        }

        it("should call onMemoryWarning on the internal cache") {
          expect(internalCache.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }
      }

      context("when calling set") {
        var succeeded: Bool!
        var failed: Error?

        let keys = [1, 2, 3]
        let values = ["", "", ""]

        beforeEach {
          cancellable = cache.set(values, forKey: keys)
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failed = error
              }
            }, receiveValue: { _ in succeeded = true })
        }

        it("should call set on the internal cache") {
          expect(internalCache.numberOfTimesCalledSet).toEventually(equal(values.count))
        }

        context("when one of the set calls fails") {
          let error = TestError.anotherError

          beforeEach {
            internalCache.setPublishers[0]?.send()
            internalCache.setPublishers[1]?.send(completion: .failure(error))
          }

          it("should fail the whole future") {
            expect(failed as? TestError).toEventually(equal(error))
          }
        }

        context("when all the set calls succeed") {
          beforeEach {
            internalCache.setPublishers[1]?.send()
            internalCache.setPublishers[2]?.send()
            internalCache.setPublishers[3]?.send()
          }

          it("should succeed the whole future") {
            expect(succeeded).toEventually(beTrue())
          }
        }
      }

      context("when calling get") {
        var result: [String]?
        var errors: [Error]!

        beforeEach {
          errors = []
          result = nil

          cancellable = cache.get(Array(0..<requestsCount))
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                errors.append(error)
              }
            }, receiveValue: {
              result = $0
            })
        }

        it("should dispatch all of the requests to the underlying cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(requestsCount))
        }

        context("when one of the requests fails") {
          beforeEach {
            internalCache.getPublishers[0]?.send(completion: .failure(TestError.simpleError))
          }

          it("should fail the resulting future") {
            expect(errors).toEventuallyNot(beEmpty())
          }

          it("should pass the right error") {
            expect(errors.first as? TestError).toEventually(equal(TestError.simpleError))
          }

          it("should not call the success closure") {
            expect(result).toEventually(beNil())
          }
        }

        context("when one of the requests succeeds") {
          beforeEach {
            internalCache.getPublishers[0]?.send("Test")
          }

          it("should not call the failure closure") {
            expect(errors).toEventually(beEmpty())
          }

          it("should not call the success closure") {
            expect(result).toEventually(beNil())
          }
        }

        context("when all of the requests succeed") {
          beforeEach {
            internalCache.getPublishers.forEach { key, value in
              value.send("\(key)")
            }
          }

          it("should not call the failure closure") {
            expect(errors).toEventually(beEmpty())
          }

          it("should call the success closure") {
            expect(result).toEventuallyNot(beNil())
          }

          it("should pass all the values") {
            expect(result?.count).toEventually(equal(internalCache.getPublishers.count))
          }

          it("should pass the individual results in the right order") {
            expect(result?.sorted()).toEventually(equal(internalCache.getPublishers.enumerated().map { iteration, _ in
              "\(iteration)"
            }))
          }
        }
      }
    }
  }
}

final class BatchTests: QuickSpec {
  override func spec() {
    let requestsCount = 5

    var cache: CacheLevelFake<Int, String>!
    var cancellable: AnyCancellable?

    beforeEach {
      cache = CacheLevelFake<Int, String>()
    }

    afterEach {
      cancellable?.cancel()
    }

    describe("batchGetSome") {
      var result: [String]!
      var errors: [Error]!

      beforeEach {
        errors = []
        result = nil

        cancellable = cache.batchGetSome(Array(0..<requestsCount))
          .sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
              errors.append(error)
            }
          }, receiveValue: { result = $0 })
      }

      it("should dispatch all of the requests to the underlying cache") {
        expect(cache.numberOfTimesCalledGet).toEventually(equal(requestsCount))
      }

      context("when one of the requests fails") {
        let failedIndex = 2

        beforeEach {
          cache.getPublishers[failedIndex]?.send(completion: .failure(TestError.simpleError))
        }

        it("should not call the success closure") {
          expect(result).toEventually(beNil())
        }

        it("should not call the failure closure") {
          expect(errors).toEventually(beEmpty())
        }

        context("when all the other requests succeed") {
          beforeEach {
            cache.getPublishers.forEach { key, value in
              value.send("\(key)")
            }
          }

          it("should call the success closure") {
            expect(result).toEventuallyNot(beNil())
          }

          it("should pass the right number of results") {
            expect(result.count).toEventually(equal(cache.getPublishers.count - 1))
          }

          it("should only pass the succeeded requests") {
            var expectedResult = cache.getPublishers.enumerated().map { iteration, _ in
              "\(iteration)"
            }
            _ = expectedResult.remove(at: failedIndex)

            expect(result.sorted()).toEventually(equal(expectedResult))
          }

          it("should not call the failure closure") {
            expect(errors).toEventually(beEmpty())
          }
        }
      }

      context("when all the other requests complete") {
        beforeEach {
          cache.getPublishers.forEach { key, value in
            value.send("\(key)")
          }
        }

        it("should call the success closure") {
          expect(result).toEventuallyNot(beNil())
        }

        it("should pass the right number of results") {
          expect(result.count).toEventually(equal(cache.getPublishers.count))
        }

        it("should only pass the succeeded requests") {
          expect(result.sorted()).toEventually(equal(cache.getPublishers.enumerated().map { iteration, _ in
            "\(iteration)"
          }))
        }

        it("should not call the failure closure") {
          expect(errors).toEventually(beEmpty())
        }
      }

      context("when one of the requests fails") {
        let failedIndex = 3

        beforeEach {
          cache.getPublishers[failedIndex]?.send(completion: .failure(TestError.simpleError))
        }

        it("should not call the success closure") {
          expect(result).toEventually(beNil())
        }

        it("should not call the error closure") {
          expect(errors).toEventually(beEmpty())
        }

        context("when all the other requests complete") {
          beforeEach {
            cache.getPublishers.forEach { key, value in
              value.send("\(key)")
            }
          }

          it("should call the success closure") {
            expect(result).toEventuallyNot(beNil())
          }

          it("should pass the right number of results") {
            expect(result.count).toEventually(equal(cache.getPublishers.count - 1))
          }

          it("should only pass the succeeded requests") {
            var expectedResult = cache.getPublishers.enumerated().map { iteration, _ in
              "\(iteration)"
            }
            _ = expectedResult.remove(at: failedIndex)

            expect(result.sorted()).toEventually(equal(expectedResult))
          }

          it("should not call the failure closure") {
            expect(errors).toEventually(beEmpty())
          }
        }
      }
    }
  }
}
