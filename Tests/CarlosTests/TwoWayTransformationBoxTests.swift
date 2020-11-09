import Foundation

import Nimble
import Quick

import Carlos
import Combine

struct TwoWayTransformationBoxSharedExamplesContext {
  static let TransformerToTest = "transformer"
}

final class TwoWayTransformationBoxSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_: Configuration) {
    sharedExamples("an inverted two-way transformation box") { (sharedExampleContext: @escaping SharedExampleContext) in
      var invertedBox: TwoWayTransformationBox<String, NSURL>!
      var error: Error!
      var cancellable: AnyCancellable?

      beforeEach {
        error = nil

        invertedBox = sharedExampleContext()[TwoWayTransformationBoxSharedExamplesContext.TransformerToTest] as? TwoWayTransformationBox<String, NSURL>
      }

      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }

      context("when using the transformation") {
        var result: NSURL!

        beforeEach {
          result = nil
        }

        context("if the transformation is possible") {
          let originString = "http://github.com/WeltN24/Carlos"

          beforeEach {
            cancellable = invertedBox.transform(originString)
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }

          it("should call the success closure") {
            expect(result).notTo(beNil())
          }

          it("should not call the failure closure") {
            expect(error).to(beNil())
          }

          it("should return the expected result") {
            expect(result?.absoluteString) == originString
          }
        }

        context("if the transformation is not possible") {
          beforeEach {
            cancellable = invertedBox.transform("not an URL")
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }

          it("should call the error closure") {
            expect(error).notTo(beNil())
          }

          it("should not call the success closure") {
            expect(result).to(beNil())
          }

          it("should pass the right error") {
            expect(error as? TestError) == TestError.anotherError
          }
        }
      }

      context("when using the inverse transformation") {
        var result: String!

        beforeEach {
          result = nil
        }

        context("when the transformation is possible") {
          let originURL = NSURL(string: "http://github.com/WeltN24/Carlos")!

          beforeEach {
            cancellable = invertedBox.inverseTransform(originURL)
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }

          it("should call the success closure") {
            expect(result).notTo(beNil())
          }

          it("should not call the failure closure") {
            expect(error).to(beNil())
          }

          it("should return the expected result") {
            expect(result) == originURL.absoluteString
          }
        }

        context("when the transformation is not possible") {
          beforeEach {
            cancellable = invertedBox.inverseTransform(NSURL(string: "ftp://test")!)
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }

          it("should call the error closure") {
            expect(error).notTo(beNil())
          }

          it("should not call the success closure") {
            expect(result).to(beNil())
          }

          it("should pass the right error") {
            expect(error as? TestError) == TestError.anotherError
          }
        }
      }
    }
  }
}

final class TwoWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("TwoWayTransformationBox") {
      var box: TwoWayTransformationBox<NSURL, String>!
      var error: Error!
      var cancellable: AnyCancellable?

      beforeEach {
        error = nil

        box = TwoWayTransformationBox<NSURL, String>(transform: {
          guard $0.scheme == "http", let stringValue = $0.absoluteString else {
            return Fail(error: TestError.anotherError).eraseToAnyPublisher()
          }

          return Just(stringValue).setFailureType(to: Error.self).eraseToAnyPublisher()
        }, inverseTransform: {
          guard let value = NSURL(string: $0) else {
            return Fail(error: TestError.anotherError).eraseToAnyPublisher()
          }

          return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
        })
      }

      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }

      context("when using the transformation") {
        var result: String!

        beforeEach {
          result = nil
        }

        context("when the transformation is possible") {
          let originURL = NSURL(string: "http://github.com/WeltN24/Carlos")!

          beforeEach {
            cancellable = box.transform(originURL)
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
            expect(result).toEventually(equal(originURL.absoluteString))
          }
        }

        context("when the transformation is not possible") {
          beforeEach {
            cancellable = box.transform(NSURL(string: "ftp://whatever")!)
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }

          it("should not call the success closure") {
            expect(result).toEventually(beNil())
          }

          it("should call the error closure") {
            expect(error).toEventuallyNot(beNil())
          }

          it("should pass the right error") {
            expect(error as? TestError).toEventually(equal(TestError.anotherError))
          }
        }
      }

      context("when using the inverse transformation") {
        var result: NSURL!

        beforeEach {
          result = nil
        }

        context("when the transformation is possible") {
          let originString = "http://github.com/WeltN24/Carlos"

          beforeEach {
            cancellable = box.inverseTransform(originString)
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
            expect(result).toEventually(equal(NSURL(string: originString)!))
          }
        }

        context("when the transformation is not possible") {
          beforeEach {
            cancellable = box.inverseTransform("not an URL")
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }

          it("should not call the success closure") {
            expect(result).toEventually(beNil())
          }

          it("should call the error closure") {
            expect(error).toEventuallyNot(beNil())
          }

          it("should pass the right error") {
            expect(error as? TestError) == TestError.anotherError
          }
        }
      }

      context("when inverting the transformer") {
        var invertedBox: TwoWayTransformationBox<String, NSURL>!

        beforeEach {
          invertedBox = box.invert()
        }

        itBehavesLike("an inverted two-way transformation box") {
          [
            TwoWayTransformationBoxSharedExamplesContext.TransformerToTest: invertedBox as Any
          ]
        }
      }
    }
  }
}
