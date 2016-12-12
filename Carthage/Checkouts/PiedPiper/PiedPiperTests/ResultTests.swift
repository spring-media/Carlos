import Foundation
import Quick
import Nimble
import PiedPiper

class ResultTests: QuickSpec {
  override func spec() {
    describe("Result") {
      var result: Result<String>!
      
      context("the error property") {
        var error: Error?
        
        context("when the result is a success") {
          beforeEach {
            result = .success("Hi!")
            error = result.error
          }
          
          it("should be nil") {
            expect(error).to(beNil())
          }
        }
        
        context("when the result is cancelled") {
          beforeEach {
            result = .cancelled
            error = result.error
          }
          
          it("should be nil") {
            expect(error).to(beNil())
          }
        }
        
        context("when the result is a failure") {
          beforeEach {
            result = .error(TestError.simpleError)
            error = result.error
          }
          
          it("should not be nil") {
            expect(error).notTo(beNil())
          }
          
          it("should be the right error") {
            expect(error as? TestError).to(equal(TestError.simpleError))
          }
        }
      }
      
      context("the value property") {
        var value: String?
        
        context("when the result is a success") {
          let expected = "Hi!"
          
          beforeEach {
            result = .success(expected)
            value = result.value
          }
          
          it("should not be nil") {
            expect(value).notTo(beNil())
          }
          
          it("should be the right value") {
            expect(value).to(equal(expected))
          }
        }
        
        context("when the result is cancelled") {
          beforeEach {
            result = .cancelled
            value = result.value
          }
          
          it("should be nil") {
            expect(value).to(beNil())
          }
        }
        
        context("when the result is a failure") {
          beforeEach {
            result = .error(TestError.anotherError)
            value = result.value
          }
          
          it("should be nil") {
            expect(value).to(beNil())
          }
        }
      }
    }
  }
}
