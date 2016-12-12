import Quick
import Nimble
import PiedPiper

class FutureZipTests: QuickSpec {
  override func spec() {
    describe("Zipping a Future") {
      var promise: Promise<String>!
      var zippedFuture: Future<(String, Int)>!
      var successValue: (String, Int)?
      var failureValue: Error?
      var wasCanceled: Bool!
      
      beforeEach {
        promise = Promise<String>()
        
        wasCanceled = false
        successValue = nil
        failureValue = nil
      }
      
      context("when done with another Future") {
        var other: Promise<Int>!
        
        beforeEach {
          other = Promise<Int>()
          
          zippedFuture = promise.future.zip(other.future)
          
          zippedFuture.onCompletion { result in
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
        
        context("when the first future fails") {
          let error = TestError.anotherError
          
          beforeEach {
            promise.fail(error)
          }
          
          it("should fail the zipped future") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail with the right error") {
            expect(failureValue as? TestError).to(equal(error))
          }
          
          it("should not succeed the zipped future") {
            expect(successValue).to(beNil())
          }
          
          it("should not cancel the zipped future") {
            expect(wasCanceled).to(beFalse())
          }
        }
        
        context("when the first future is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should not fail the zipped future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not succeed the zipped future") {
            expect(successValue).to(beNil())
          }
          
          it("should cancel the zipped future") {
            expect(wasCanceled).to(beTrue())
          }
        }
        
        context("when the first future succeeds") {
          let firstResult = "yes"
          
          beforeEach {
            promise.succeed(firstResult)
          }
          
          context("when the second future fails") {
            let error = TestError.simpleError
            
            beforeEach {
              other.fail(error)
            }
            
            it("should fail the zipped future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail with the right error") {
              expect(failureValue as? TestError).to(equal(error))
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should not cancel the zipped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the second future is canceled") {
            beforeEach {
              other.cancel()
            }
            
            it("should not fail the zipped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should cancel the zipped future") {
              expect(wasCanceled).to(beTrue())
            }
          }
          
          context("when the second future succeeds") {
            let secondResult = 10
            
            beforeEach {
              other.succeed(secondResult)
            }
            
            it("should not fail the zipped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should succeed the zipped future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed with the right value") {
              expect(successValue?.0).to(equal(firstResult))
              expect(successValue?.1).to(equal(secondResult))
            }
            
            it("should not cancel the zipped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        }
      }
      
      context("when done with a Result") {
        var other: Result<Int>!
        
        context("when the result is success") {
          let otherResult = 10
          
          beforeEach {
            other = Result.success(otherResult)
            
            zippedFuture = promise.future.zip(other)
            
            zippedFuture.onCompletion { result in
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
          
          context("when the future fails") {
            let error = TestError.anotherError
            
            beforeEach {
              promise.fail(error)
            }
            
            it("should fail the zipped future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail with the right error") {
              expect(failureValue as? TestError).to(equal(error))
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should not cancel the zipped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the future is canceled") {
            beforeEach {
              promise.cancel()
            }
            
            it("should not fail the zipped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should cancel the zipped future") {
              expect(wasCanceled).to(beTrue())
            }
          }
          
          context("when the future succeeds") {
            let firstResult = "yay"
            
            beforeEach {
              promise.succeed(firstResult)
            }
            
            it("should not fail the zipped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should succeed the zipped future") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed with the right value") {
              expect(successValue?.0).to(equal(firstResult))
              expect(successValue?.1).to(equal(otherResult))
            }
            
            it("should not cancel the zipped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        }
        
        context("when the result is error") {
          let error = TestError.simpleError
          
          beforeEach {
            other = Result.error(error)
            
            zippedFuture = promise.future.zip(other)
            
            zippedFuture.onCompletion { result in
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
          
          it("should immediately fail the zipped future") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should immediately fail with the right error") {
            expect(failureValue as? TestError).to(equal(error))
          }
          
          it("should not succeed the zipped future") {
            expect(successValue).to(beNil())
          }
          
          it("should not cancel the zipped future") {
            expect(wasCanceled).to(beFalse())
          }
          
          context("when the future fails") {
            let anotherError = TestError.anotherError
            
            beforeEach {
              promise.fail(anotherError)
            }
            
            it("should fail the zipped future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail with the right error") {
              expect(failureValue as? TestError).to(equal(error))
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should not cancel the zipped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the future is canceled") {
            beforeEach {
              promise.cancel()
            }
            
            it("should fail the zipped future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail with the right error") {
              expect(failureValue as? TestError).to(equal(error))
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should not cancel the zipped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
          
          context("when the future succeeds") {
            beforeEach {
              promise.succeed("ops")
            }
            
            it("should fail the zipped future") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail with the right error") {
              expect(failureValue as? TestError).to(equal(error))
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should not cancel the zipped future") {
              expect(wasCanceled).to(beFalse())
            }
          }
        }
        
        context("when the result is cancelled") {
          beforeEach {
            other = Result.cancelled
            
            zippedFuture = promise.future.zip(other)
            
            zippedFuture.onCompletion { result in
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
          
          it("should not fail the zipped future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not succeed the zipped future") {
            expect(successValue).to(beNil())
          }
          
          it("should immediately cancel the zipped future") {
            expect(wasCanceled).to(beTrue())
          }
          
          context("when the future fails") {
            let error = TestError.anotherError
            
            beforeEach {
              promise.fail(error)
            }
            
            it("should not fail the zipped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should cancel the zipped future") {
              expect(wasCanceled).to(beTrue())
            }
          }
          
          context("when the future is canceled") {
            beforeEach {
              promise.cancel()
            }
            
            it("should not fail the zipped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should cancel the zipped future") {
              expect(wasCanceled).to(beTrue())
            }
          }
          
          context("when the future succeeds") {
            beforeEach {
              promise.succeed(":(")
            }
            
            it("should not fail the zipped future") {
              expect(failureValue).to(beNil())
            }
            
            it("should not succeed the zipped future") {
              expect(successValue).to(beNil())
            }
            
            it("should cancel the zipped future") {
              expect(wasCanceled).to(beTrue())
            }
          }
        }
      }
    }
  }
}
