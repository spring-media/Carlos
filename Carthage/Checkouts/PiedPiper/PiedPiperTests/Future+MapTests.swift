import Quick
import Nimble
import PiedPiper

class FutureMapTests: QuickSpec {
  override func spec() {
    describe("Mapping a Future") {
      var promise: Promise<String>!
      var mappedFuture: Future<Int>!
      var successValue: Int?
      var failureValue: ErrorType?
      var wasCanceled: Bool!
      
      beforeEach {
        promise = Promise<String>()
        
        wasCanceled = false
        successValue = nil
        failureValue = nil
      }
      
      context("when done through a simple closure") {
        let mappingClosure: String -> Int = { str in
          return 1
        }
        
        beforeEach {
          mappedFuture = promise.future
            .map(mappingClosure)
            
          mappedFuture.onCompletion { result in
              switch result {
              case .Success(let value):
                successValue = value
              case .Error(let error):
                failureValue = error
              case .Cancelled:
                wasCanceled = true
              }
          }
        }
        
        context("when the original future fails") {
          let error = TestError.SimpleError
          
          beforeEach {
            promise.fail(error)
          }
          
          it("should also fail the mapped future") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail the mapped future with the same error") {
            expect(failureValue as? TestError).to(equal(error))
          }
          
          it("should not succeed the mapped future") {
            expect(successValue).to(beNil())
          }
          
          it("should not cancel the mapped future") {
            expect(wasCanceled).to(beFalse())
          }
        }
        
        context("when the original future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should also cancel the mapped future") {
            expect(wasCanceled).to(beTrue())
          }
          
          it("should not succeed the mapped future") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the mapped future") {
            expect(failureValue).to(beNil())
          }
        }
        
        context("when the original future succeeds") {
          let result = "Eureka!"
          
          beforeEach {
            promise.succeed(result)
          }
          
          it("should also succeed the mapped future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed the mapped future with the mapped value") {
            expect(successValue).to(equal(mappingClosure(result)))
          }
          
          it("should not fail the mapped future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not cancel the mapped future") {
            expect(wasCanceled).to(beFalse())
          }
        }
      }
      
      context("when done through a closure that can throw") {
        let mappingClosure: String throws -> Int = { str in
          if str == "throw" {
            throw TestError.AnotherError
          } else {
            return 1
          }
        }
        
        beforeEach {
          mappedFuture = promise.future
            .map(mappingClosure)
          
          mappedFuture.onCompletion { result in
            switch result {
            case .Success(let value):
              successValue = value
            case .Error(let error):
              failureValue = error
            case .Cancelled:
              wasCanceled = true
            }
          }
        }
        
        context("when the original future fails") {
          let error = TestError.SimpleError
          
          beforeEach {
            promise.fail(error)
          }
          
          it("should also fail the mapped future") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail the mapped future with the same error") {
            expect(failureValue as? TestError).to(equal(error))
          }
          
          it("should not succeed the mapped future") {
            expect(successValue).to(beNil())
          }
          
          it("should not cancel the mapped future") {
            expect(wasCanceled).to(beFalse())
          }
        }
        
        context("when the original future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should also cancel the mapped future") {
            expect(wasCanceled).to(beTrue())
          }
          
          it("should not succeed the mapped future") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the mapped future") {
            expect(failureValue).to(beNil())
          }
        }
        
        context("when the original future succeeds") {
          context("when the closure doesn't throw") {
            let result = "Eureka!"
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should also succeed the mapped future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the mapped future with the mapped value") {
              expect(successValue).to(equal(try! mappingClosure(result)))
            }
            
            it("should not fail the mapped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not cancel the mapped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the closure throws") {
            let result = "throw"
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should not succeed the mapped future") {
              expect(successValue).to(beNil())
            }
            
            it("should fail the mapped future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the mapped future with the right error") {
              expect(failureValue as? TestError).to(equal(TestError.AnotherError))
            }
            
            it("should not cancel the mapped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        }
      }
    }
  }
}