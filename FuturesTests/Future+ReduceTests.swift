import Quick
import Nimble
import PiedPiper

extension MutableCollectionType where Self.Index == Int {
  mutating func shuffle() -> Self {
    let numberOfElements = self.count
    for iteration in 0..<(numberOfElements - 1) {
      let swapIndex = Int(arc4random_uniform(UInt32(numberOfElements)))
      if iteration != swapIndex {
        swap(&self[iteration], &self[swapIndex])
      }
    }
    
    return self
  }
}

class FutureSequenceReduceTests: QuickSpec {
  override func spec() {
    describe("Reducing a list of Futures") {
      var promises: [Promise<Int>]!
      var reducedFuture: Future<Int>!
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
        
        context("when they succeed in the same order") {
          beforeEach {
            expectedResult = 5
            promises.enumerate().forEach { (iteration, promise) in
              promise.succeed(iteration)
              expectedResult = expectedResult + iteration
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
      
      context("when canceling the reduced future") {
        context("when no promise was done") {
          beforeEach {
            reducedFuture.cancel()
          }
          
          it("should cancel all the running promises") {
            expect(originalPromisesCanceled).to(allPass({ $0 == true}))
          }
        }
        
        context("when some promise was done") {
          let nonRunningPromiseIndex = 1
          
          beforeEach {
            promises[nonRunningPromiseIndex].succeed(10)
            reducedFuture.cancel()
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
    
    describe("Reducing a list of Futures, independently of the order they succeed") {
      var promises: [Promise<String>]!
      var reducedFuture: Future<String>!
      var successValue: String?
      var expectedResult: String!
      
      beforeEach {
        promises = [
          Promise(),
          Promise(),
          Promise(),
          Promise(),
          Promise()
        ]
        
        successValue = nil
        
        reducedFuture = promises
          .map { $0.future }
          .reduce("BEGIN-", combine: +)
        
        reducedFuture.onSuccess {
          successValue = $0
        }
        
        let sequenceOfIndexes = Array(0..<promises.count).map({ "\($0)" }).joinWithSeparator("")
        expectedResult = "BEGIN-\(sequenceOfIndexes)"
        
        var arrayOfIndexes = Array(promises.enumerate())
        
        repeat {
          arrayOfIndexes = arrayOfIndexes.shuffle()
        } while arrayOfIndexes.map({ $0.0 }) == Array(0..<promises.count)
          
        arrayOfIndexes.forEach { (originalIndex, promise) in
          promise.succeed("\(originalIndex)")
        }
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