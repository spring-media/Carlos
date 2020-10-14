import Foundation

import Quick
import Nimble

import Carlos
import Combine

final class StringTransformerTests: QuickSpec {
  override func spec() {
    describe("String transformer") {
      var transformer: StringTransformer!
      var error: Error!
      
      var cancellable: AnyCancellable?
      
      beforeEach {
        transformer = StringTransformer(encoding: .utf8)
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      context("when transforming NSData to String") {
        var result: String!
        
        context("when the NSData is a valid string") {
          let stringSample = "this is a sample string"
          
          beforeEach {
            cancellable = transformer.transform((stringSample.data(using: .utf8) as NSData?)!)
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }
          
          it("should not return nil") {
            expect(result).toEventuallyNot(beNil())
          }
          
          it("should not call the failure closure") {
            expect(error).toEventually(beNil())
          }
          
          it("should return the expected String") {
            expect(result).toEventually(equal(stringSample))
          }
        }
      }
      
      context("when transforming String to NSData") {
        var result: NSData?
        let expectedString = "this is the expected string value"
        
        beforeEach {
          cancellable = transformer.inverseTransform(expectedString)
            .sink(receiveCompletion: { completion in
              if case let .failure(e) = completion {
                error = e
              }
            }, receiveValue: { result = $0 })
        }
        
        it("should call the success closure") {
          expect(result).toEventuallyNot(beNil())
        }
        
        it("should return the expected data") {
          expect(result).toEventually(equal(expectedString.data(using: .utf8) as NSData?))
        }
      }
    }
  }
}
