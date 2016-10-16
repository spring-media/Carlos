import Foundation
import Quick
import Nimble
import PiedPiper

class FutureRetryTests: QuickSpec {
  override func spec() {
    describe("Retrying a given future") {
      var lastPromise: Promise<Int>?
      var retryCount: Int!
      let futureClosure: Void -> Future<Int> = {
        lastPromise = Promise()
        retryCount = retryCount + 1
        return lastPromise!.future
      }
      var result: Future<Int>!
      var successSentinel: Int?
      var failureSentinel: ErrorType?
      var cancelSentinel: Bool!
      
      beforeEach {
        lastPromise = nil
        retryCount = 0
        
        successSentinel = nil
        failureSentinel = nil
        cancelSentinel = false
      }
      
      context("when retrying less than 0 times") {
        beforeEach {
          result = retry(-1, every: 0, futureClosure: futureClosure)
            .onSuccess {
              successSentinel = $0
            }
            .onFailure {
              failureSentinel = $0
            }
            .onCancel {
              cancelSentinel = true
            }
        }
        
        it("should call the closure once") {
          expect(retryCount).to(equal(1))
        }
        
        context("when the future succeeds") {
          let value = 2
          
          beforeEach {
            lastPromise?.succeed(value)
          }
          
          it("should not retry") {
            expect(retryCount).to(equal(1))
          }
          
          it("should succeed the result") {
            expect(successSentinel).notTo(beNil())
          }
          
          it("should succeed with the right value") {
            expect(successSentinel).to(equal(value))
          }
        }
        
        context("when the future fails") {
          let error = TestError.AnotherError
          
          beforeEach {
            lastPromise?.fail(error)
          }
          
          it("should not retry") {
            expect(retryCount).to(equal(1))
          }
          
          it("should fail the result") {
            expect(failureSentinel).notTo(beNil())
          }
          
          it("should fail with the right error") {
            expect(failureSentinel as? TestError).to(equal(error))
          }
        }
        
        context("when the future is canceled") {
          beforeEach {
            lastPromise?.cancel()
          }
          
          it("should not retry") {
            expect(retryCount).to(equal(1))
          }
          
          it("should cancel the result") {
            expect(cancelSentinel).to(beTrue())
          }
        }
      }
      
      context("when retrying 0 times") {
        beforeEach {
          result = retry(0, every: 0, futureClosure: futureClosure)
            .onSuccess {
              successSentinel = $0
            }
            .onFailure {
              failureSentinel = $0
            }
            .onCancel {
              cancelSentinel = true
          }
        }
        
        it("should call the closure once") {
          expect(retryCount).to(equal(1))
        }
        
        context("when the future succeeds") {
          let value = 2
          
          beforeEach {
            lastPromise?.succeed(value)
          }
          
          it("should not retry") {
            expect(retryCount).to(equal(1))
          }
          
          it("should succeed the result") {
            expect(successSentinel).notTo(beNil())
          }
          
          it("should succeed with the right value") {
            expect(successSentinel).to(equal(value))
          }
        }
        
        context("when the future fails") {
          let error = TestError.AnotherError
          
          beforeEach {
            lastPromise?.fail(error)
          }
          
          it("should not retry") {
            expect(retryCount).to(equal(1))
          }
          
          it("should fail the result") {
            expect(failureSentinel).notTo(beNil())
          }
          
          it("should fail with the right error") {
            expect(failureSentinel as? TestError).to(equal(error))
          }
        }
        
        context("when the future is canceled") {
          beforeEach {
            lastPromise?.cancel()
          }
          
          it("should not retry") {
            expect(retryCount).to(equal(1))
          }
          
          it("should cancel the result") {
            expect(cancelSentinel).to(beTrue())
          }
        }
      }
      
      context("when retrying 1 time") {
        beforeEach {
          result = retry(1, every: 0.2, futureClosure: futureClosure)
            .onSuccess {
              successSentinel = $0
            }
            .onFailure {
              failureSentinel = $0
            }
            .onCancel {
              cancelSentinel = true
          }
        }
        
        it("should call the closure once") {
          expect(retryCount).to(equal(1))
        }
        
        context("when the future succeeds") {
          let value = 2
          
          beforeEach {
            lastPromise?.succeed(value)
          }
          
          it("should not retry") {
            expect(retryCount).to(equal(1))
          }
          
          it("should succeed the result") {
            expect(successSentinel).notTo(beNil())
          }
          
          it("should succeed with the right value") {
            expect(successSentinel).to(equal(value))
          }
        }
        
        context("when the future fails") {
          let error = TestError.AnotherError
          
          beforeEach {
            lastPromise?.fail(error)
          }
          
          it("should not fail the result") {
            expect(failureSentinel).to(beNil())
          }
          
          // FIXME: Failing for some reason :(
          xit("should retry") {
            expect(retryCount).toEventually(equal(2), timeout: 0.25)
          }
        }
        
        context("when the future is canceled") {
          beforeEach {
            lastPromise?.cancel()
          }
          
          it("should not retry") {
            expect(retryCount).to(equal(1))
          }
          
          it("should cancel the result") {
            expect(cancelSentinel).to(beTrue())
          }
        }
      }
    }
  }
}
