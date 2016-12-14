import Foundation
import Quick
import Nimble
import PiedPiper

class FunctionCompositionTests: QuickSpec {
  override func spec() {
    describe("Composing functions") {
      context("when the first function takes no parameter, and the second does") {
        let first: (Void) -> Int = {
          5
        }
        
        let second: (Int) -> String = {
          "\($0)"
        }
        
        var composed: ((Void) -> String)!
        
        beforeEach {
          composed = first >>> second
        }
        
        it("should return the right value") {
          expect(composed()).to(equal("5"))
        }
      }
      
      context("when the first function takes no parameter, and the second does but returns void") {
        let first: (Void) -> Int = {
          5
        }
        
        let second: (Int) -> Void = {
          print("\($0)")
        }
        
        var composed: ((Void) -> Void)!
        
        beforeEach {
          composed = first >>> second
          composed()
        }
        
        it("should swallow the parameter") {
          expect(true).to(beTrue())
        }
      }
      
      context("when the first function takes a parameter, and the second doesn't") {
        let first: (Int) -> Void = { input in
          print(input)
        }
        
        let second: (Void) -> String = {
          "hello!"
        }
        
        var composed: ((Int) -> String)!
        
        beforeEach {
          composed = first >>> second
        }
        
        it("should return the right value") {
          expect(composed(1)).to(equal("hello!"))
        }
      }
      
      context("when the first function takes a parameter, and the second doesn't and returns void") {
        let first: (Int) -> Void = { input in
          print(input)
        }
        
        let second: (Void) -> Void = {
          print("hello!")
        }
        
        var composed: ((Int) -> Void)!
        
        beforeEach {
          composed = first >>> second
          composed(1)
        }
        
        it("should swallow the parameter") {
          expect(true).to(beTrue())
        }
      }
      
      context("when both functions take no parameter") {
        let first: (Void) -> Void = {
          print("hello...")
        }
        
        let second: (Void) -> String = {
          "...world!"
        }
        
        var composed: ((Void) -> String)!
        
        beforeEach {
          composed = first >>> second
        }
        
        it("should return the right value") {
          expect(composed()).to(equal("...world!"))
        }
      }
      
      context("when both functions take no parameter and the second returns void") {
        let first: (Void) -> Void = {
          print("hello...")
        }
        
        let second: (Void) -> Void = {
          print("...world!")
        }
        
        var composed: ((Void) -> Void)!
        
        beforeEach {
          composed = first >>> second
          composed()
        }
        
        it("should swallow the parameter") {
          expect(true).to(beTrue())
        }
      }
      
      context("when both functions take parameters") {
        let first: (String) -> String = { input in
          "hello, \(input)!"
        }
        
        let second: (String) -> String = { input in
          input.uppercased()
        }
        
        var composed: ((String) -> String)!
        
        beforeEach {
          composed = first >>> second
        }
        
        it("should return the right value") {
          expect(composed("world")).to(equal("HELLO, WORLD!"))
        }
      }
      
      context("when both functions take parameters and the second returns void") {
        let first: (Int) -> String = { input in
          "\(input)"
        }
        
        let second: (String) -> Void = { input in
          print(input)
        }
        
        var composed: ((Int) -> Void)!
        
        beforeEach {
          composed = first >>> second
          composed(1)
        }
        
        it("should swallow the parameter") {
          expect(true).to(beTrue())
        }
      }
      
      context("when the first function returns nil") {
        let first: (String) -> Int? = {
          Int($0)
        }
        
        let second: (Int) -> String = {
          "\($0)"
        }
        
        var composed: ((String) -> String?)!
        
        beforeEach {
          composed = first >>> second
        }
        
        it("should return the result if it's not nil") {
          expect(composed("10")).to(equal("10"))
        }
        
        it("should return nil if the first computation is nil") {
          expect(composed("hello")).to(beNil())
        }
      }
      
      context("when the second function returns nil") {
        let first: (Float) -> Int? = {
          Int($0)
        }
        
        let second: (Int) -> String? = {
          $0 > 0 ? "\($0)" : nil
        }
        
        var composed: ((Float) -> String?)!
        
        beforeEach {
          composed = first >>> second
        }
        
        it("should return the result if it's not nil") {
          expect(composed(1.5)).to(equal("1"))
        }
        
        it("should return nil if the second computation is nil") {
          expect(composed(-1.0)).to(beNil())
        }
      }
    }
    
    describe("Composing futures") {
      var promise1: Promise<String>!
      var promise2: Promise<Int>!
      var input1: Int!
      var input2: String!
      var composed: ((Int) -> Future<Int>)!
      var result: Int!
      var error: Error!
      var canceled: Bool!
      let input = 1
      
      beforeEach {
        result = nil
        error = nil
        canceled = false
        
        promise1 = Promise()
        promise2 = Promise()
        
        let first: (Int) -> Future<String> = { input in
          input1 = input
          return promise1.future
        }
        
        let second: (String) -> Future<Int> = { input in
          input2 = input
          return promise2.future
        }
        
        composed = first >>> second
        
        composed(input).onSuccess {
          result = $0
        }.onFailure {
          error = $0
        }.onCancel {
          canceled = true
        }
      }
      
      it("should pass the input to the first promise") {
        expect(input1).to(equal(input))
      }
      
      context("when the first promise succeeds") {
        let firstValue = "test"
        
        beforeEach {
          promise1.succeed(firstValue)
        }
        
        it("should pass the result to the second promise") {
          expect(input2).to(equal(firstValue))
        }
        
        context("when the second promise fails") {
          beforeEach {
            promise2.fail(TestError.anotherError)
          }
          
          it("should fail the composition") {
            expect(error).notTo(beNil())
          }
          
          it("should pass the right error") {
            expect(error as? TestError).to(equal(TestError.anotherError))
          }
        }
        
        context("when the second promise succeeds") {
          let expectedResult = 10
          
          beforeEach {
            promise2.succeed(expectedResult)
          }
          
          it("should succeed the composition") {
            expect(result).to(equal(expectedResult))
          }
        }
        
        context("when the second promise is canceled") {
          beforeEach {
            promise2.cancel()
          }
          
          it("should cancel the composition") {
            expect(canceled).to(beTrue())
          }
        }
      }
      
      context("when the first promise fails") {
        beforeEach {
          promise1.fail(TestError.simpleError)
        }
        
        it("should fail the composition") {
          expect(error).notTo(beNil())
        }
        
        it("should pass the right error") {
          expect(error as? TestError).to(equal(TestError.simpleError))
        }
      }
      
      context("when the first promise is canceled") {
        beforeEach {
          promise1.cancel()
        }
        
        it("should cancel the composition") {
          expect(canceled).to(beTrue())
        }
      }
    }
  }
}
