import Quick
import Nimble
import PiedPiper

class FutureSequenceMergeTests: QuickSpec {
  override func spec() {
    describe("Merging a list of Futures") {
      var promises: [Promise<Int>]!
      var mergedFuture: Future<[Int]>!
      var successValue: [Int]?
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
        successValue = nil
        failureValue = nil
        
        mergedFuture = promises
          .map { $0.future }
          .mergeAll()
        
        mergedFuture.onCompletion { result in
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
      
      context("when one of the original futures fails") {
        let expectedError = TestError.anotherError
        
        beforeEach {
          promises.first?.succeed(10)
          promises[1].fail(expectedError)
        }
        
        it("should fail the merged future") {
          expect(failureValue).notTo(beNil())
        }
        
        it("should fail with the right error") {
          expect(failureValue as? TestError).to(equal(expectedError))
        }
        
        it("should not cancel the merged future") {
          expect(wasCanceled).to(beFalse())
        }
        
        it("should not succeed the merged future") {
          expect(successValue).to(beNil())
        }
      }
      
      context("when one of the original futures is canceled") {
        beforeEach {
          promises.first?.succeed(10)
          promises[1].cancel()
        }
        
        it("should not fail the merged future") {
          expect(failureValue).to(beNil())
        }
        
        it("should cancel the merged future") {
          expect(wasCanceled).to(beTrue())
        }
        
        it("should not succeed the merged future") {
          expect(successValue).to(beNil())
        }
      }
      
      context("when all the original futures succeed") {
        var expectedResult: [Int]!
        
        context("when they succeed in the same order") {
          beforeEach {
            expectedResult = promises.enumerated().map { $0.offset }
            promises.enumerated().forEach { (iteration, promise) in
              promise.succeed(iteration)
            }
          }
          
          it("should not fail the merged future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not cancel the merged future") {
            expect(wasCanceled).to(beFalse())
          }
          
          it("should succeed the merged future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed with the right value") {
            expect(successValue).to(equal(expectedResult))
          }
        }
      }
      
      context("when canceling the merged future") {
        context("when no promise was done") {
          beforeEach {
            mergedFuture.cancel()
          }
          
          it("should cancel all the running promises") {
            expect(originalPromisesCanceled).to(allPass({ $0 == true}))
          }
        }
        
        context("when some promise was done") {
          let nonRunningPromiseIndex = 1
          
          beforeEach {
            promises[nonRunningPromiseIndex].succeed(10)
            mergedFuture.cancel()
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
    
    describe("Merging a list of Futures, independently of the order they succeed") {
      var promises: [Promise<String>]!
      var mergedFuture: Future<[String]>!
      var successValue: [String]?
      var expectedResult: [String]!
      
      beforeEach {
        promises = [
          Promise(),
          Promise(),
          Promise(),
          Promise(),
          Promise()
        ]
        
        successValue = nil
        
        mergedFuture = promises
          .map { $0.future }
          .mergeAll()
        
        mergedFuture.onSuccess {
          successValue = $0
        }
        
        expectedResult = Array(0..<promises.count).map { "\($0)" }
        
        var arrayOfIndexes = Array(promises.enumerated())
        
        repeat {
          arrayOfIndexes = arrayOfIndexes.shuffle()
        } while arrayOfIndexes.map({ $0.0 }) == Array(0..<promises.count)
        
        arrayOfIndexes.forEach { (originalIndex, promise) in
          promise.succeed("\(originalIndex)")
        }
      }
      
      it("should succeed the merged future") {
        expect(successValue).notTo(beNil())
      }
      
      it("should succeed with the right value") {
        expect(successValue).to(equal(expectedResult))
      }
    }

    describe("MergeSome a list of futures") {
      var promises: [Promise<Int>]!
      var mergedFuture: Future<[Int]>!
      var successValue: [Int]?
      var failureValue: Error?
      var wasCanceled: Bool!
      var originalPromisesCanceled: [Bool]!

      let numberOfPromises = 5

      beforeEach {
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

        mergedFuture = promises
          .map { $0.future }
          .mergeSome()

        mergedFuture.onCompletion { result in
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

      context("when one of the original futures fails") {
        let expectedError = TestError.anotherError

        beforeEach {
          promises.first?.succeed(10)
          promises[1].fail(expectedError)
          promises[2..<numberOfPromises].forEach{ promise in
            promise.succeed(10)
          }
        }

        it("should not fail the merged future") {
          expect(failureValue).to(beNil())
        }

        it("should not cancel the merged future") {
          expect(wasCanceled).to(beFalse())
        }

        it("should succeed the merged future") {
          expect(successValue).notTo(beNil())
        }

        it("should succeed only the non-failing futures") {
          expect(successValue!.count).to(equal(numberOfPromises-1))
        }
      }

      context("when one of the original futures is canceled") {
        beforeEach {
          promises.first?.succeed(10)
          promises[1].cancel()
        }

        it("should not fail the merged future") {
          expect(failureValue).to(beNil())
        }

        it("should cancel the merged future") {
          expect(wasCanceled).to(beTrue())
        }

        it("should not succeed the merged future") {
          expect(successValue).to(beNil())
        }
      }

      context("when all the original futures succeed") {
        var expectedResult: [Int]!

        context("when they succeed in the same order") {
          beforeEach {
            expectedResult = promises.enumerated().map { $0.offset }
            promises.enumerated().forEach { (iteration, promise) in
              promise.succeed(iteration)
            }
          }

          it("should not fail the merged future") {
            expect(failureValue).to(beNil())
          }

          it("should not cancel the merged future") {
            expect(wasCanceled).to(beFalse())
          }

          it("should succeed the merged future") {
            expect(successValue).notTo(beNil())
          }

          it("should succeed with the right value") {
            expect(successValue).to(equal(expectedResult))
          }
        }
      }

      context("when canceling the merged future") {
        context("when no promise was done") {
          beforeEach {
            mergedFuture.cancel()
          }

          it("should cancel all the running promises") {
            expect(originalPromisesCanceled).to(allPass({ $0 == true}))
          }
        }

        context("when some promise was done") {
          let nonRunningPromiseIndex = 1

          beforeEach {
            promises[nonRunningPromiseIndex].succeed(10)
            mergedFuture.cancel()
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
  }
}
