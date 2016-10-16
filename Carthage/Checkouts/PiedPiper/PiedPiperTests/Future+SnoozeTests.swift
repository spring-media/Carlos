import Quick
import Nimble
import PiedPiper

class FutureSnoozeTests: QuickSpec {
  override func spec() {
    describe("Snoozing a Future") {
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
        
        result = sut.future.snooze(0.5)
          
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
        
        it("should not immediately fail the snoozed future") {
          expect(failSentinel).to(beNil())
        }
        
        it("should eventually fail the snoozed future") {
          expect(failSentinel).toEventuallyNot(beNil(), timeout: 0.8)
        }
        
        it("should fail with the same error") {
          expect(failSentinel as? TestError).toEventually(equal(error), timeout: 0.8)
        }
      }
      
      context("when the original promise is canceled") {
        beforeEach {
          sut.cancel()
        }
        
        it("should not immediately cancel the snoozed future") {
          expect(cancelSentinel).notTo(beTrue())
        }
        
        it("should cancel the snoozed future later") {
          expect(cancelSentinel).toEventually(beTrue(), timeout: 0.8)
        }
      }
      
      context("when the original promise succeeds") {
        let value = 3
        
        beforeEach {
          sut.succeed(value)
        }
        
        it("should not immediately succeed the snoozed future") {
          expect(successSentinel).to(beNil())
        }
        
        it("should eventually succeed the snoozed future") {
          expect(successSentinel).toEventuallyNot(beNil(), timeout: 0.8)
        }
        
        it("should succeed with the same error") {
          expect(successSentinel).toEventually(equal(value), timeout: 0.8)
        }
      }
    }
  }
}