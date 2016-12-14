import Quick
import Nimble
import PiedPiper

class FutureSequenceAllTests: QuickSpec {
  override func spec() {
    describe("calling all on a list of Futures") {
      var promises: [Promise<Int>]!
      var resultFuture: Future<()>!
      var didSucceed: Bool?
      var failureValue: Error?
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
        didSucceed = nil
        failureValue = nil
        
        resultFuture = promises
          .map { $0.future }
          .all()
        
        resultFuture.onCompletion { result in
          switch result {
          case .success(_):
            didSucceed = true
          case .error(let error):
            failureValue = error
          case .cancelled:
            wasCanceled = true
          }
        }
      }
      
      context("when one of the original futures fails") {
        let expectedError = TestError.anotherError
        
        beforeEach {
          promises.first?.succeed(10)
          promises[1].fail(expectedError)
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
          expect(didSucceed).to(beNil())
        }
      }
      
      context("when one of the original futures is canceled") {
        beforeEach {
          promises.first?.succeed(10)
          promises[1].cancel()
        }
        
        it("should not fail the resulting future") {
          expect(failureValue).to(beNil())
        }
        
        it("should cancel the resulting future") {
          expect(wasCanceled).to(beTrue())
        }
        
        it("should not succeed the resulting future") {
          expect(didSucceed).to(beNil())
        }
      }
      
      context("when all the original futures succeed") {
        context("when they succeed in the same order") {
          beforeEach {
            promises.enumerated().forEach { (iteration, promise) in
              promise.succeed(iteration)
            }
          }
          
          it("should not fail the resulting future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not cancel the resulting future") {
            expect(wasCanceled).to(beFalse())
          }
          
          it("should succeed the resulting future") {
            expect(didSucceed).notTo(beNil())
          }
        }
      }
      
      context("when canceling the resulting future") {
        context("when no promise was done") {
          beforeEach {
            resultFuture.cancel()
          }
          
          it("should cancel all the running promises") {
            expect(originalPromisesCanceled).to(allPass({ $0 == true }))
          }
        }
        
        context("when some promise was done") {
          let nonRunningPromiseIndex = 1
          
          beforeEach {
            promises[nonRunningPromiseIndex].succeed(10)
            resultFuture.cancel()
          }
          
          it("should cancel only the non running promises") {
            expect(originalPromisesCanceled.filter({ $0 == true }).count).to(equal(promises.count - 1))
          }
          
          it("should not cancel the non running promises") {
            expect(originalPromisesCanceled[nonRunningPromiseIndex]).to(beFalse())
          }
        }
      }
    }
    
    describe("calling all on a list of Futures, independently of the order they succeed") {
      var promises: [Promise<String>]!
      var resultingFuture: Future<()>!
      var didSucceed: Bool?
      
      beforeEach {
        promises = [
          Promise(),
          Promise(),
          Promise(),
          Promise(),
          Promise()
        ]
        
        didSucceed = nil
        
        resultingFuture = promises
          .map { $0.future }
          .all()
        
        resultingFuture.onSuccess {
          didSucceed = true
        }
               
        var arrayOfIndexes = Array(promises.enumerated())
        
        repeat {
          arrayOfIndexes = arrayOfIndexes.shuffle()
        } while arrayOfIndexes.map({ $0.0 }) == Array(0..<promises.count)
        
        arrayOfIndexes.forEach { (originalIndex, promise) in
          promise.succeed("\(originalIndex)")
        }
      }
      
      it("should succeed the resulting future") {
        expect(didSucceed).notTo(beNil())
      }
    }
  }
}
