import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

final class OneWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("OneWayTransformationBox") {
      var box: OneWayTransformationBox<String, Int>!
      var cancellable: AnyCancellable?
      
      beforeEach {
        box = OneWayTransformationBox(transform: { value in
          guard let intValue = Int(value) else {
            return Fail(error: TestError.simpleError).eraseToAnyPublisher()
          }
          
          return Just(intValue).setFailureType(to: Error.self).eraseToAnyPublisher()
        })
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      context("when using the transformation") {
        var result: Int!
        var error: Error!
        
        beforeEach {
          result = nil
          error = nil
        }
        
        context("if the transformation is possible") {
          let originString = "102"
          
          beforeEach {
            cancellable = box.transform(originString)
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
            expect(result).to(equal(Int(originString)))
          }
        }
        
        context("if the transformation is not possible") {
          let originString = "10asd2"
          
          beforeEach {
            cancellable = box.transform(originString)
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }
          
          it("should not call the success closure") {
            expect(result).to(beNil())
          }
          
          it("should call the failure closure") {
            expect(error).notTo(beNil())
          }
          
          it("should pass the right error") {
            expect(error as? TestError).to(equal(TestError.simpleError))
          }
        }
      }
    }
  }
}
