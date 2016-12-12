import Quick
import Nimble
import PiedPiper

class FutureRecoverTests: QuickSpec {
  override func spec() {
    describe("Recovering a Future") {
      var promise: Promise<String>!
      var recoveredFuture: Future<String>!
      var successValue: String?
      var failureValue: Error?
      var wasCanceled: Bool!
      
      beforeEach {
        promise = Promise<String>()
        
        wasCanceled = false
        successValue = nil
        failureValue = nil
      }
      
      context("when done through a closure") {
        let rescueClosure: (Void) -> String = {
          "rescued!"
        }
        
        beforeEach {
          recoveredFuture = promise.future.recover(rescueClosure)
          
          recoveredFuture
            .onSuccess { value in
              successValue = value
            }
            .onFailure { error in
              failureValue = error
            }
            .onCancel {
              wasCanceled = true
            }
        }
        
        context("when the original future fails") {
          let error = TestError.simpleError
          
          beforeEach {
            promise.fail(error)
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
          
          it("should succeed the final future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed the final future with the rescue value") {
            expect(successValue).to(equal(rescueClosure()))
          }
          
          it("should not cancel the final future") {
            expect(wasCanceled).to(beFalse())
          }
        }
        
        context("when the original future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should also cancel the final future") {
            expect(wasCanceled).to(beTrue())
          }
          
          it("should not succeed the final future") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
        }
        
        context("when the original future succeeds") {
          let result = "Eureka!"
          
          beforeEach {
            promise.succeed(result)
          }
          
          it("should also succeed the final future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed the final future with the original value") {
            expect(successValue).to(equal(result))
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not cancel the final future") {
            expect(wasCanceled).to(beFalse())
          }
        }
      }
      
      context("when done through a value") {
        let rescueValue = "rescued!"
        
        beforeEach {
          recoveredFuture = promise.future.recover(rescueValue)
          
          recoveredFuture
            .onSuccess { value in
              successValue = value
            }
            .onFailure { error in
              failureValue = error
            }
            .onCancel {
              wasCanceled = true
          }
        }
        
        context("when the original future fails") {
          let error = TestError.simpleError
          
          beforeEach {
            promise.fail(error)
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
          
          it("should succeed the final future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed the final future with the rescue value") {
            expect(successValue).to(equal(rescueValue))
          }
          
          it("should not cancel the final future") {
            expect(wasCanceled).to(beFalse())
          }
        }
        
        context("when the original future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should also cancel the final future") {
            expect(wasCanceled).to(beTrue())
          }
          
          it("should not succeed the final future") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
        }
        
        context("when the original future succeeds") {
          let result = "Eureka!"
          
          beforeEach {
            promise.succeed(result)
          }
          
          it("should also succeed the final future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed the final future with the original value") {
            expect(successValue).to(equal(result))
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not cancel the final future") {
            expect(wasCanceled).to(beFalse())
          }
        }
      }
      
      context("when done through a Future") {
        var rescueFuture: Promise<String>!
        
        beforeEach {
          rescueFuture = Promise()
          
          recoveredFuture = promise.future.recover { rescueFuture.future }
          
          recoveredFuture
            .onSuccess { value in
              successValue = value
            }
            .onFailure { error in
              failureValue = error
            }
            .onCancel {
              wasCanceled = true
          }
        }
        
        context("when the original future fails") {
          let error = TestError.simpleError
          
          beforeEach {
            promise.fail(error)
          }
          
          context("when the rescue future fails") {
            let rescueError = TestError.anotherError
            
            beforeEach {
              rescueFuture.fail(rescueError)
            }
            
            it("should fail the final future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the final future with the latest error") {
              expect(failureValue as? TestError).to(equal(rescueError))
            }
            
            it("should not succeed the final future") {
              expect(successValue).to(beNil())
            }
            
            it("should not cancel the final future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the rescue future is canceled") {
            beforeEach {
              rescueFuture.cancel()
            }
            
            it("should also cancel the final future") {
              expect(wasCanceled).to(beTrue())
            }
            
            it("should not succeed the final future") {
              expect(successValue).to(beNil())
            }
            
            it("should not fail the final future") {
              expect(failureValue).to(beNil())
            }
          }
          
          context("when the rescue future succeeds") {
            let result = "Eureka!"
            
            beforeEach {
              rescueFuture.succeed(result)
            }
            
            it("should also succeed the final future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the final future with the rescue value") {
              expect(successValue).to(equal(result))
            }
            
            it("should not fail the final future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not cancel the final future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        }
        
        context("when the original future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should also cancel the final future") {
            expect(wasCanceled).to(beTrue())
          }
          
          it("should not succeed the final future") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
        }
        
        context("when the original future succeeds") {
          let result = "Eureka!"
          
          beforeEach {
            promise.succeed(result)
          }
          
          it("should also succeed the final future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed the final future with the original value") {
            expect(successValue).to(equal(result))
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not cancel the final future") {
            expect(wasCanceled).to(beFalse())
          }
        }
      }
      
      context("when done through a Result") {
        var rescueResult: Result<String>!
        
        beforeEach {
          recoveredFuture = promise.future.recover { rescueResult }
          
          recoveredFuture
            .onSuccess { value in
              successValue = value
            }
            .onFailure { error in
              failureValue = error
            }
            .onCancel {
              wasCanceled = true
          }
        }
        
        context("when the original future fails") {
          let error = TestError.simpleError
          
          context("and the rescue result is an error") {
            let rescueError = TestError.anotherError
            
            beforeEach {
              rescueResult = Result.error(rescueError)
              promise.fail(error)
            }
            
            it("should fail the final future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the final future with the latest error") {
              expect(failureValue as? TestError).to(equal(rescueError))
            }
            
            it("should not succeed the final future") {
              expect(successValue).to(beNil())
            }
            
            it("should not cancel the final future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        
          context("and the rescue result is cancelled") {
            beforeEach {
              rescueResult = Result.cancelled
              promise.fail(error)
            }
            
            it("should also cancel the final future") {
              expect(wasCanceled).to(beTrue())
            }
            
            it("should not succeed the final future") {
              expect(successValue).to(beNil())
            }
            
            it("should not fail the final future") {
              expect(failureValue).to(beNil())
            }
          }
        
          context("and the rescue result is a success") {
            let result = "Eureka!"
            
            beforeEach {
              rescueResult = Result.success(result)
              promise.fail(error)
            }
            
            it("should also succeed the final future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the final future with the rescue value") {
              expect(successValue).to(equal(result))
            }
            
            it("should not fail the final future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not cancel the final future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        }
        
        context("when the original future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should also cancel the final future") {
            expect(wasCanceled).to(beTrue())
          }
          
          it("should not succeed the final future") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
        }
        
        context("when the original future succeeds") {
          let result = "Eureka!"
          
          beforeEach {
            promise.succeed(result)
          }
          
          it("should also succeed the final future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed the final future with the original value") {
            expect(successValue).to(equal(result))
          }
          
          it("should not fail the final future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not cancel the final future") {
            expect(wasCanceled).to(beFalse())
          }
        }
      }
    }
  }
}
