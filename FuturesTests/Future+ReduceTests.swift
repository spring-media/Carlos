import Quick
import Nimble
import PiedPiper

class FutureSequenceReduceTests: QuickSpec {
  override func spec() {
    describe("Reducing a list of Futures") {
      var promises: [Promise<Int>]!
      var reducedFuture: Future<Int>!
      var successValue: Int?
      var failureValue: ErrorType?
      var wasCanceled: Bool!
      
      beforeEach {
        promises = [
          Promise(),
          Promise(),
          Promise(),
          Promise(),
          Promise()
        ]
        
        wasCanceled = false
        successValue = nil
        failureValue = nil
        
        reducedFuture = promises
          .map { $0.future }
          .reduce(5, combine: +)
        
        reducedFuture.onCompletion { result in
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
          promises.first?.succeed(10)
          promises[1].fail(expectedError)
        }
        
        it("should fail the reduced future") {
          expect(failureValue).notTo(beNil())
        }
        
        it("should fail with the right error") {
          expect(failureValue as? TestError).to(equal(expectedError))
        }
        
        it("should not cancel the reduced future") {
          expect(wasCanceled).to(beFalse())
        }
        
        it("should not succeed the reduced future") {
          expect(successValue).to(beNil())
        }
      }
      
      context("when one of the original futures is canceled") {
        beforeEach {
          promises.first?.succeed(10)
          promises[1].cancel()
        }
        
        it("should not fail the reduced future") {
          expect(failureValue).to(beNil())
        }
        
        it("should cancel the reduced future") {
          expect(wasCanceled).to(beTrue())
        }
        
        it("should not succeed the reduced future") {
          expect(successValue).to(beNil())
        }
      }
      
      context("when all the original futures succeed") {
        var expectedResult: Int!
        
        beforeEach {
          expectedResult = 5
          var iteration = 1
          promises.forEach { promise in
            promise.succeed(iteration)
            expectedResult = expectedResult + iteration
            iteration += 1
          }
        }
        
        it("should not fail the reduced future") {
          expect(failureValue).to(beNil())
        }
        
        it("should not cancel the reduced future") {
          expect(wasCanceled).to(beFalse())
        }
        
        it("should succeed the reduced future") {
          expect(successValue).notTo(beNil())
        }
        
        it("should succeed with the right value") {
          expect(successValue).to(equal(expectedResult))
        }
      }
    }
  }
}