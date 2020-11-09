import Foundation

import Nimble
import Quick

import Carlos
import Combine

final class NSDateFormatterTransformerTests: QuickSpec {
  override func spec() {
    describe("DateFormatter") {
      var formatter: DateFormatter!
      var cancellable: AnyCancellable?

      beforeEach {
        formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
      }

      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }

      context("when used as a transformer") {
        var error: Error?

        afterEach {
          error = nil
        }

        context("when transforming") {
          let originDate = Date(timeIntervalSince1970: 1_436_644_623)
          var result: String!

          beforeEach {
            cancellable = formatter.transform(originDate)
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }

          afterEach {
            result = nil
          }

          it("should call the success closure") {
            expect(result).toEventuallyNot(beNil())
          }

          it("should not call the failure closure") {
            expect(error).toEventually(beNil())
          }

          it("should return the expected string") {
            expect(result).toEventually(equal("2015-07-11"))
          }
        }

        context("when inverse transforming") {
          var result: Date!
          var formattedResult: String?

          afterEach {
            result = nil
            formattedResult = nil
          }

          context("when the string is valid") {
            let originString = "2015-07-11"

            beforeEach {
              cancellable = formatter.inverseTransform(originString)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: {
                  result = $0
                  formattedResult = formatter.string(from: $0)
                })
            }

            it("should call the success closure") {
              expect(result).toEventuallyNot(beNil())
            }

            it("should not call the failure closure") {
              expect(error).toEventually(beNil())
            }

            it("should return the expected date") {
              expect(formattedResult).toEventually(equal(originString))
            }
          }

          context("when the string is invalid") {
            beforeEach {
              cancellable = formatter.inverseTransform("this is not a valid date")
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
          }
        }
      }
    }
  }
}
