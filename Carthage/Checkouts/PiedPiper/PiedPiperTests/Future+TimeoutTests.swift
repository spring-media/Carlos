import Quick
import Nimble
import PiedPiper

class FutureTimeoutTests: QuickSpec {
  override func spec() {
    describe("Timing out a Future") {
      var sut: Promise<Int>!
      var result: Future<Int>!
      var failSentinel: ErrorType?
      var successSentinel: Int?
      var cancelSentinel: Bool?
      
      beforeEach {
        sut = Promise()
        
        cancelSentinel = false
        failSentinel = nil
        successSentinel = nil
        
        result = sut.future.timeout(after: 0.5)
        
        result
          .onSuccess { successSentinel = $0 }
          .onCancel { cancelSentinel = true }
          .onFailure { failSentinel = $0 }
      }
      
      context("when the original promise fails") {
        let error = TestError.AnotherError
        
        beforeEach {
          sut.fail(error)
        }
        
        it("should immediately fail the result future") {
          expect(failSentinel).notTo(beNil())
        }
        
        it("should fail with the same error") {
          expect(failSentinel as? TestError).to(equal(error))
        }
      }
      
      context("when the original promise succeeds") {
        let value = 3
        
        beforeEach {
          sut.succeed(value)
        }
        
        it("should immediately succeed the result future") {
          expect(successSentinel).notTo(beNil())
        }
        
        it("should succeed with the same error") {
          expect(successSentinel).to(equal(value))
        }
      }
      
      context("when the original promise is canceled") {
        beforeEach {
          sut.cancel()
        }
        
        it("should immediately cancel the result future") {
          expect(cancelSentinel).to(beTrue())
        }
      }
      
      context("when the promise doesn't succeed nor fail") {
        it("should eventually fail the future") {
          expect(failSentinel).toEventuallyNot(beNil(), timeout: 0.6)
        }
        
        it("should fail with the right error") {
          expect(failSentinel as? FutureError).toEventually(equal(FutureError.Timeout), timeout: 0.6)
        }
      }
    }
  }
}