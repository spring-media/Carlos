import Foundation

import Nimble
import Quick

import Carlos
import Combine

final class ConditionedOneWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("Conditioned one-way transformation box") {
      var box: ConditionedOneWayTransformationBox<[String: Bool], String, Int>!
      var cancellable: AnyCancellable?

      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }

      context("when created through a closure") {
        beforeEach {
          box = ConditionedOneWayTransformationBox(conditionalTransformClosure: { key, value in
            if let _ = key["value"] {
              guard let intValue = Int(value) else {
                return Fail(error: TestError.simpleError).eraseToAnyPublisher()
              }

              return Just(intValue).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
              return Fail(error: TestError.anotherError).eraseToAnyPublisher()
            }
          })
        }

        context("when calling conditionalTransform") {
          var result: Int!
          var error: Error!

          beforeEach {
            result = nil
            error = nil
          }

          context("if the transformation is possible") {
            let originString = "102"

            beforeEach {
              cancellable = box.conditionalTransform(key: ["value": true], value: originString)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: { result = $0 })
            }

            it("should call the success closure") {
              expect(result).toEventuallyNot(beNil())
            }

            it("should not call the failure closure") {
              expect(error).toEventually(beNil())
            }

            it("should return the expected result") {
              expect(result).toEventually(equal(Int(originString)))
            }
          }

          context("if the transformation is not possible") {
            let originString = "10asd2"

            beforeEach {
              cancellable = box.conditionalTransform(key: ["value": true], value: originString)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: { result = $0 })
            }

            it("should not call the success closure") {
              expect(result).toEventually(beNil())
            }

            it("should call the failure closure") {
              expect(error).toEventuallyNot(beNil())
            }

            it("should pass the right error") {
              expect(error as? TestError).toEventually(equal(TestError.simpleError))
            }
          }

          context("if the key doesn't satisfy the condition") {
            beforeEach {
              cancellable = box.conditionalTransform(key: [:], value: "whatever")
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: { result = $0 })
            }

            it("should not call the success closure") {
              expect(result).toEventually(beNil())
            }

            it("should call the failure closure") {
              expect(error).toEventuallyNot(beNil())
            }

            it("should pass the right error") {
              expect(error as? TestError).toEventually(equal(TestError.anotherError))
            }
          }
        }
      }

      context("when created through a one way transformer") {
        beforeEach {
          let transformer = OneWayTransformationBox<String, Int>(transform: { value in
            guard let intValue = Int(value) else {
              return Fail(error: TestError.simpleError).eraseToAnyPublisher()
            }

            return Just(intValue).setFailureType(to: Error.self).eraseToAnyPublisher()
          })

          box = ConditionedOneWayTransformationBox(transformer: transformer)
        }

        context("when calling conditionalTransform") {
          var result: Int!
          var error: Error!

          beforeEach {
            result = nil
            error = nil
          }

          context("if the transformation is possible") {
            let originString = "102"

            beforeEach {
              cancellable = box.conditionalTransform(key: ["value": true], value: originString)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: { result = $0 })
            }

            it("should call the success closure") {
              expect(result).toEventuallyNot(beNil())
            }

            it("should not call the failure closure") {
              expect(error).toEventually(beNil())
            }

            it("should return the expected result") {
              expect(result).toEventually(equal(Int(originString)))
            }
          }

          context("if the transformation is not possible") {
            let originString = "10asd2"

            beforeEach {
              cancellable = box.conditionalTransform(key: [:], value: originString)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: { result = $0 })
            }

            it("should not call the success closure") {
              expect(result).toEventually(beNil())
            }

            it("should call the failure closure") {
              expect(error).toEventuallyNot(beNil())
            }

            it("should pass the right error") {
              expect(error as? TestError).toEventually(equal(TestError.simpleError))
            }
          }
        }
      }
    }
  }
}
