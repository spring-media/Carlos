import Quick
import Nimble
import PiedPiper

class FutureFlatMapTests: QuickSpec {
  override func spec() {
    describe("FlatMapping a Future") {
      var promise: Promise<String>!
      var mappedFuture: Future<Int>!
      var successValue: Int?
      var failureValue: Error?
      var wasCanceled: Bool!
      
      beforeEach {
        promise = Promise<String>()
        
        wasCanceled = false
        successValue = nil
        failureValue = nil
      }
      
      context("when done through a closure that can return nil") {
        let mappingClosure: (String) -> Int? = { str in
          if str == "nil" {
            return nil
          } else {
            return 1
          }
        }
        
        beforeEach {
          mappedFuture = promise.future
            .flatMap(mappingClosure)
          
          mappedFuture.onCompletion { result in
            switch result {
            case .success(let value):
              successValue = value
            case .error(let error):
              failureValue = error
            case .cancelled:
              wasCanceled = true
            }
          }
        }
        
        context("when the original future fails") {
          let error = TestError.simpleError
          
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
          context("when the closure doesn't return nil") {
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
          
          context("when the closure returns nil") {
            let result = "nil"
            
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
              expect(failureValue as? FutureMappingError).to(equal(FutureMappingError.cantMapValue))
            }
            
            it("should not cancel the mapped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        }
      }
      
      context("when done through a closure that returns a Result") {
        let mappingClosure: (String) -> Result<Int> = { str in
          if str == "cancel" {
            return Result.cancelled
          } else if str == "failure" {
            return Result.error(TestError.simpleError)
          } else {
            return Result.success(1)
          }
        }
        
        beforeEach {
          mappedFuture = promise.future
            .flatMap(mappingClosure)
          
          mappedFuture.onCompletion { result in
            switch result {
            case .success(let value):
              successValue = value
            case .error(let error):
              failureValue = error
            case .cancelled:
              wasCanceled = true
            }
          }
        }
        
        context("when the original future fails") {
          let error = TestError.simpleError
          
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
          context("when the closure returns a success") {
            let result = "Eureka!"
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should also succeed the mapped future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the mapped future with the right value") {
              expect(successValue).to(equal(1))
            }
            
            it("should not fail the mapped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not cancel the mapped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the closure returns a failure") {
            let result = "failure"
            
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
              expect(failureValue as? TestError).to(equal(TestError.simpleError))
            }
            
            it("should not cancel the mapped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the closure returns a cancelled result") {
            let result = "cancel"
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should not succeed the mapped future") {
              expect(successValue).to(beNil())
            }
            
            it("should not fail the mapped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should cancel the mapped future") {
              expect(wasCanceled).to(beTrue())
            }
          }
        }
      }
      
      context("when done through a closure that returns a Future") {
        let mappingClosure: (String) -> Future<Int> = { str in
          let result: Future<Int>
          
          if str == "cancel" {
            let intermediate = Promise<Int>()
            intermediate.cancel()
            result = intermediate.future
          } else if str == "failure" {
            result = Future(TestError.simpleError)
          } else {
            result = Future(1)
          }
          
          return result
        }
        
        beforeEach {
          mappedFuture = promise.future
            .flatMap(mappingClosure)
          
          mappedFuture.onCompletion { result in
            switch result {
            case .success(let value):
              successValue = value
            case .error(let error):
              failureValue = error
            case .cancelled:
              wasCanceled = true
            }
          }
        }
        
        context("when the original future fails") {
          let error = TestError.simpleError
          
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
          context("when the closure returns a success") {
            let result = "Eureka!"
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should also succeed the mapped future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the mapped future with the right value") {
              expect(successValue).to(equal(1))
            }
            
            it("should not fail the mapped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not cancel the mapped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the closure returns a failure") {
            let result = "failure"
            
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
              expect(failureValue as? TestError).to(equal(TestError.simpleError))
            }
            
            it("should not cancel the mapped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the closure returns a cancelled future") {
            let result = "cancel"
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should not succeed the mapped future") {
              expect(successValue).to(beNil())
            }
            
            it("should not fail the mapped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should cancel the mapped future") {
              expect(wasCanceled).to(beTrue())
            }
          }
        }
      }
    }
  }
}
