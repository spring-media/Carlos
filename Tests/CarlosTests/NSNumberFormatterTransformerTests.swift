import Foundation

import Quick
import Nimble

import Carlos
import Combine

final class NSNumberFormatterTransformerTests: QuickSpec {
  override func spec() {
    describe("NumberFormatter") {
      var formatter: NumberFormatter!
      var cancellable: AnyCancellable?
      
      beforeEach {
        formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 3
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      context("when used as a transformer") {
        var error: Error!
        
        context("when transforming") {
          var result: String!
          
          afterEach {
            result = nil
            error = nil
          }
          
          context("when the number contains a valid number of fraction digits") {
            let originNumber = 10.1203
            
            beforeEach {
              cancellable = formatter.transform(NSNumber(value: originNumber))
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
            
            it("should return the expected string") {
              expect(result).toEventually(equal("10.1203"))
            }
          }
          
          context("when the number contains less fractions digits") {
            let originNumber = 10.12
            
            beforeEach {
              cancellable = formatter.transform(NSNumber(value: originNumber))
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
            
            it("should return the expected string") {
              expect(result).toEventually(equal("10.120"))
            }
          }
          
          context("when the number contains more fraction digits") {
            let originNumber = 10.120312
            
            beforeEach {
              cancellable = formatter.transform(NSNumber(value: originNumber))
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
            
            it("should return the expected string") {
              expect(result).toEventually(equal("10.12031"))
            }
          }
        }
        
        context("when inverse transforming") {
          var result: NSNumber!
          
          context("when the string is valid") {
            let originString = "10.1203"
            
            beforeEach {
              cancellable = formatter.inverseTransform(originString)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: {
                  result = $0
                })
            }
            
            afterEach {
              result = nil
              error = nil
            }
            
            it("should call the success closure") {
              expect(result).toEventuallyNot(beNil())
            }
            
            it("should not call the failure closure") {
              expect(error).toEventually(beNil())
            }
            
            it("should return the expected number") {
              expect(result.map { "\($0)" }).toEventually(equal(originString))
            }
          }
          
          context("when the string is invalid") {
            beforeEach {
              cancellable = formatter.inverseTransform("not a number!")
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                    result = nil
                  }
                }, receiveValue: { result = $0 })
            }
            
            afterEach {
              result = nil
              error = nil
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
