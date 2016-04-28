import Quick
import Nimble
import PiedPiper

class FutureFilterTests: QuickSpec {
  override func spec() {
    describe("Filtering a Future") {
      var promise: Promise<Int>!
      var filteredFuture: Future<Int>!
      var successValue: Int?
      var failureValue: ErrorType?
      var wasCanceled: Bool!
      
      beforeEach {
        promise = Promise<Int>()
        
        wasCanceled = false
        successValue = nil
        failureValue = nil
      }
      
      context("when done through a simple closure") {
        let filteringClosure: Int -> Bool = { num in
          num > 0
        }
        
        beforeEach {
          filteredFuture = promise.future
            .filter(filteringClosure)
          
          filteredFuture.onCompletion { result in
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
          
          it("should also fail the filtered future") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail the filtered future with the same error") {
            expect(failureValue as? TestError).to(equal(error))
          }
          
          it("should not succeed the filtered future") {
            expect(successValue).to(beNil())
          }
          
          it("should not cancel the filtered future") {
            expect(wasCanceled).to(beFalse())
          }
        }
        
        context("when the original future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should also cancel the filtered future") {
            expect(wasCanceled).to(beTrue())
          }
          
          it("should not succeed the filtered future") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the filtered future") {
            expect(failureValue).to(beNil())
          }
        }
        
        context("when the original future succeeds") {
          context("when the success value satisfies the condition") {
            let result = 20
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should also succeed the filtered future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the filtered future with the original value") {
              expect(successValue).to(equal(result))
            }
            
            it("should not fail the filtered future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not cancel the filtered future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the success value doesn't satisfy the condition") {
            let result = -20
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should not succeed the filtered future") {
              expect(successValue).to(beNil())
            }
            
            it("should fail the filtered future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the filtered future with the right error") {
              expect(failureValue as? FutureFilteringError).to(equal(FutureFilteringError.ConditionUnsatisfied))
            }
            
            it("should not cancel the filtered future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        }
      }
      
      context("when done through a closure that returns a Future") {
        let filteringClosure: Int -> Future<Bool> = { num in
          if num < 0 {
            return Future(TestError.SimpleError)
          } else if num == 0 {
            let result = Promise<Bool>()
            result.cancel()
            return result.future
          } else if num < 100 {
            return Future(true)
          } else {
            return Future(false)
          }
        }
        
        beforeEach {
          filteredFuture = promise.future
            .filter(filteringClosure)
          
          filteredFuture.onCompletion { result in
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
          
          it("should also fail the filtered future") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail the filtered future with the same error") {
            expect(failureValue as? TestError).to(equal(error))
          }
          
          it("should not succeed the filtered future") {
            expect(successValue).to(beNil())
          }
          
          it("should not cancel the filtered future") {
            expect(wasCanceled).to(beFalse())
          }
        }
        
        context("when the original future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should also cancel the filtered future") {
            expect(wasCanceled).to(beTrue())
          }
          
          it("should not succeed the filtered future") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the filtered future") {
            expect(failureValue).to(beNil())
          }
        }
        
        context("when the original future succeeds") {
          context("when the success value returns a Future that satisfies the condition") {
            let result = 20
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should also succeed the filtered future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the filtered future with the original value") {
              expect(successValue).to(equal(result))
            }
            
            it("should not fail the filtered future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not cancel the filtered future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the success value returns a Future that doesn't satisfy the condition") {
            let result = 1208
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should not succeed the filtered future") {
              expect(successValue).to(beNil())
            }
            
            it("should fail the filtered future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the filtered future with the right error") {
              expect(failureValue as? FutureFilteringError).to(equal(FutureFilteringError.ConditionUnsatisfied))
            }
            
            it("should not cancel the filtered future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the success value returns a Future that fails") {
            let result = -20
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should not succeed the filtered future") {
              expect(successValue).to(beNil())
            }
            
            it("should fail the filtered future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the filtered future with the right error") {
              expect(failureValue as? TestError).to(equal(TestError.SimpleError))
            }
            
            it("should not cancel the filtered future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the success value returns a Future that is canceled") {
            let result = 0
            
            beforeEach {
              promise.succeed(result)
            }
            
            it("should not succeed the filtered future") {
              expect(successValue).to(beNil())
            }
            
            it("should not fail the filtered future") {
              expect(failureValue).to(beNil())
            }
            
            it("should cancel the filtered future") {
              expect(wasCanceled).to(beTrue())
            }
          }
        }
      }
    }
  }
}