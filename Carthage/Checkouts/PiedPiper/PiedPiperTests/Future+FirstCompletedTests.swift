import Quick
import Nimble
import PiedPiper

class FutureSequenceFirstCompletedTests: QuickSpec {
  override func spec() {
    describe("calling firstCompleted on a list of Futures") {
      var promises: [Promise<Int>]!
      var resultFuture: Future<Int>!
      var successValue: Int?
      var failureValue: ErrorType?
      var wasCanceled: Bool!
      var originalPromisesCanceled: [Bool]!
      
      beforeEach {
        let numberOfPromises = 5
        originalPromisesCanceled = (0..<numberOfPromises).map { _ in
          false
        }
        promises = (0..<numberOfPromises).map { idx in
          Promise().onCancel {
            originalPromisesCanceled[idx] = true
          }
        }
        
        wasCanceled = false
        successValue = nil
        failureValue = nil
        
        resultFuture = promises
          .map { $0.future }
          .firstCompleted()
        
        resultFuture.onCompletion { result in
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
      
      context("when one of the original futures fails") {
        let expectedError = TestError.AnotherError
        
        beforeEach {
          promises[2].fail(expectedError)
        }
        
        it("should fail the resulting future") {
          expect(failureValue).notTo(beNil())
        }
        
        it("should fail with the right error") {
          expect(failureValue as? TestError).to(equal(expectedError))
        }
        
        it("should not cancel the resulting future") {
          expect(wasCanceled).to(beFalse())
        }
        
        it("should not succeed the resulting future") {
          expect(successValue).to(beNil())
        }
      }
      
      context("when one of the original futures is canceled") {
        beforeEach {
          promises[3].cancel()
        }
        
        it("should not fail the resulting future") {
          expect(failureValue).to(beNil())
        }
        
        it("should cancel the resulting future") {
          expect(wasCanceled).to(beTrue())
        }
        
        it("should not succeed the resulting future") {
          expect(successValue).to(beNil())
        }
      }
      
      context("when one of the original futures succeeds") {
        let value = 3
        
        beforeEach {
          promises[3].succeed(value)
        }
        
        it("should not fail the resulting future") {
          expect(failureValue).to(beNil())
        }
        
        it("should not cancel the resulting future") {
          expect(wasCanceled).to(beFalse())
        }
        
        it("should succeed the resulting future") {
          expect(successValue).notTo(beNil())
        }
        
        it("should succeed with the right value") {
          expect(successValue).to(equal(value))
        }
      }
      
      context("when canceling the resulting future") {
        beforeEach {
          resultFuture.cancel()
        }
        
        it("should cancel all the running promises") {
          expect(originalPromisesCanceled).to(allPass({ $0 == true }))
        }
      }
    }
  }
}