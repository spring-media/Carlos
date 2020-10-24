import Foundation

import Nimble
import Quick

import Carlos
import Combine

final class ConditionedTwoWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("Conditioned two-way transformation box") {
      var box: ConditionedTwoWayTransformationBox<Int, NSURL, String>!
      var error: Error!
      var cancellable: AnyCancellable?

      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }

      context("when created through closures") {
        beforeEach {
          error = nil

          box = ConditionedTwoWayTransformationBox<Int, NSURL, String>(conditionalTransformClosure: { key, value in
            if key > 0 {
              guard value.scheme == "http", let value = value.absoluteString else {
                return Fail(error: TestError.simpleError).eraseToAnyPublisher()
              }

              return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
              return Fail(error: TestError.anotherError).eraseToAnyPublisher()
            }
          }, conditionalInverseTransformClosure: { key, value in
            if key > 0 {
              guard let value = NSURL(string: value) else {
                return Fail(error: TestError.simpleError).eraseToAnyPublisher()
              }

              return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
              return Fail(error: TestError.anotherError).eraseToAnyPublisher()
            }
          })
        }

        context("when calling the conditional transformation") {
          var result: String!

          beforeEach {
            result = nil
          }

          context("if the transformation is possible") {
            let expectedResult = "http://www.google.de?test=1"

            beforeEach {
              cancellable = box.conditionalTransform(key: 1, value: NSURL(string: expectedResult)!)
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
              expect(result).toEventually(equal(expectedResult))
            }
          }

          context("if the transformation is not possible") {
            beforeEach {
              cancellable = box.conditionalTransform(key: 1, value: NSURL(string: "ftp://google.de/robots.txt")!)
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
              cancellable = box.conditionalTransform(key: -1, value: NSURL(string: "ftp://google.de/robots.txt")!)
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

        context("when calling the conditional inverse transformation") {
          var result: NSURL!

          beforeEach {
            result = nil
          }

          context("if the transformation is possible") {
            let usedString = "http://www.google.de?test=1"

            beforeEach {
              cancellable = box.conditionalInverseTransform(key: 1, value: usedString)
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
              expect(result).toEventually(equal(NSURL(string: usedString)!))
            }
          }

          context("if the transformation is not possible") {
            beforeEach {
              cancellable = box.conditionalInverseTransform(key: 1, value: "this is not a valid URL :'(")
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
              cancellable = box.conditionalInverseTransform(key: -1, value: "http://validurl.de")
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

        context("when inverting the transformer") {
          var invertedBox: ConditionedTwoWayTransformationBox<Int, String, NSURL>!

          beforeEach {
            invertedBox = box.invert()
          }

          context("when calling the inverse transformation") {
            var result: String!

            beforeEach {
              result = nil
            }

            context("if the transformation is possible") {
              let expectedResult = "http://www.google.de?test=1"

              beforeEach {
                cancellable = invertedBox.conditionalInverseTransform(key: 1, value: NSURL(string: expectedResult)!)
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
                expect(result).toEventually(equal(expectedResult))
              }
            }

            context("if the transformation is not possible") {
              beforeEach {
                cancellable = invertedBox.conditionalInverseTransform(key: 1, value: NSURL(string: "ftp://google.de/robots.txt")!)
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
                cancellable = invertedBox.conditionalInverseTransform(key: -1, value: NSURL(string: "ftp://google.de/robots.txt")!)
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

          context("when calling the conditional transformation") {
            var result: NSURL!

            beforeEach {
              result = nil
            }

            context("if the transformation is possible") {
              let usedString = "http://www.google.de?test=1"

              beforeEach {
                cancellable = invertedBox.conditionalTransform(key: 1, value: usedString)
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
                expect(result).toEventually(equal(NSURL(string: usedString)!))
              }
            }

            context("if the transformation is not possible") {
              beforeEach {
                cancellable = invertedBox.conditionalTransform(key: 1, value: "this is not a valid URL :'(")
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
                cancellable = invertedBox.conditionalTransform(key: -1, value: "http://validurl.de")
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
      }

      context("when created through a 2-way transformer") {
        var originalTransformer: TwoWayTransformationBox<NSURL, String>!

        beforeEach {
          error = nil
          originalTransformer = TwoWayTransformationBox(transform: { value in
            guard value.scheme == "http", let value = value.absoluteString else {
              return Fail(error: TestError.simpleError).eraseToAnyPublisher()
            }

            return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
          }, inverseTransform: { value in
            guard let value = NSURL(string: value) else {
              return Fail(error: TestError.simpleError).eraseToAnyPublisher()
            }

            return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
          })

          box = ConditionedTwoWayTransformationBox<Int, NSURL, String>(transformer: originalTransformer)
        }

        context("when calling the conditional transformation") {
          var result: String!

          beforeEach {
            result = nil
          }

          context("if the transformation is possible") {
            let expectedResult = "http://www.google.de?test=1"

            beforeEach {
              cancellable = box.conditionalTransform(key: -1, value: NSURL(string: expectedResult)!)
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
              expect(result).toEventually(equal(expectedResult))
            }
          }

          context("if the transformation is not possible") {
            beforeEach {
              cancellable = box.conditionalTransform(key: 1, value: NSURL(string: "ftp://google.de/robots.txt")!)
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

        context("when calling the conditional inverse transformation") {
          var result: NSURL!

          beforeEach {
            result = nil
          }

          context("if the transformation is possible") {
            let usedString = "http://www.google.de?test=1"

            beforeEach {
              cancellable = box.conditionalInverseTransform(key: -1, value: usedString)
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
              expect(result).toEventually(equal(NSURL(string: usedString)!))
            }
          }

          context("if the transformation is not possible") {
            beforeEach {
              cancellable = box.conditionalInverseTransform(key: 1, value: "this is not a valid URL :'(")
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

        context("when inverting the transformer") {
          var invertedBox: ConditionedTwoWayTransformationBox<Int, String, NSURL>!

          beforeEach {
            invertedBox = box.invert()
          }

          context("when calling the inverse transformation") {
            var result: String!

            beforeEach {
              result = nil
            }

            context("if the transformation is possible") {
              let expectedResult = "http://www.google.de?test=1"

              beforeEach {
                cancellable = invertedBox.conditionalInverseTransform(key: 1, value: NSURL(string: expectedResult)!)
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
                expect(result).toEventually(equal(expectedResult))
              }
            }

            context("if the transformation is not possible") {
              beforeEach {
                cancellable = invertedBox.conditionalInverseTransform(key: 1, value: NSURL(string: "ftp://google.de/robots.txt")!)
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

          context("when calling the conditional transformation") {
            var result: NSURL!

            beforeEach {
              result = nil
            }

            context("if the transformation is possible") {
              let usedString = "http://www.google.de?test=1"

              beforeEach {
                cancellable = invertedBox.conditionalTransform(key: 1, value: usedString)
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
                expect(result).toEventually(equal(NSURL(string: usedString)!))
              }
            }

            context("if the transformation is not possible") {
              beforeEach {
                cancellable = invertedBox.conditionalTransform(key: 1, value: "this is not a valid URL :'(")
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
}
