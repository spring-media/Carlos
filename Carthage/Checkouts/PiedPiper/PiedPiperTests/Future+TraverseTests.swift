import Quick
import Nimble
import PiedPiper

class SequenceTraverseTests: QuickSpec {
  override func spec() {
    describe("Traversing a list of items") {
      var promises: [Promise<Int>]!
      var traversedFuture: Future<[Int]>!
      var successValue: [Int]?
      var failureValue: Error?
      var wasCanceled: Bool!
      var valuesToTraverse: [Int]!
      var originalPromisesCanceled: [Bool]!
      
      beforeEach {
        valuesToTraverse = Array(0...5)
        originalPromisesCanceled = (0..<valuesToTraverse.count).map { _ in
          false
        }
        promises = (0..<valuesToTraverse.count).map { idx in
          Promise().onCancel {
            originalPromisesCanceled[idx] = true
          }
        }
        
        wasCanceled = false
        successValue = nil
        failureValue = nil
        
        traversedFuture = valuesToTraverse
          .traverse({ idx in
            promises[idx].future
          })
        
        traversedFuture.onCompletion { result in
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
        
        it("should fail the traversed future") {
          expect(failureValue).notTo(beNil())
        }
        
        it("should fail with the right error") {
          expect(failureValue as? TestError).to(equal(expectedError))
        }
        
        it("should not cancel the traversed future") {
          expect(wasCanceled).to(beFalse())
        }
        
        it("should not succeed the traversed future") {
          expect(successValue).to(beNil())
        }
      }
      
      context("when one of the original futures is canceled") {
        beforeEach {
          promises.first?.succeed(10)
          promises[1].cancel()
        }
        
        it("should not fail the traversed future") {
          expect(failureValue).to(beNil())
        }
        
        it("should cancel the traversed future") {
          expect(wasCanceled).to(beTrue())
        }
        
        it("should not succeed the traversed future") {
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
          
          it("should not fail the traversed future") {
            expect(failureValue).to(beNil())
          }
          
          it("should not cancel the traversed future") {
            expect(wasCanceled).to(beFalse())
          }
          
          it("should succeed the traversed future") {
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed with the right value") {
            expect(successValue).to(equal(expectedResult))
          }
        }
      }
      
      context("when canceling the traversed future") {
        context("when no promise was done") {
          beforeEach {
            traversedFuture.cancel()
          }
          
          it("should cancel all the running promises") {
            expect(originalPromisesCanceled).to(allPass({ $0 == true}))
          }
        }
        
        context("when some promise was done") {
          let nonRunningPromiseIndex = 1
          
          beforeEach {
            promises[nonRunningPromiseIndex].succeed(10)
            traversedFuture.cancel()
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
    
    describe("Traversing a list of items, independently of the order they succeed") {
      var promises: [Promise<String>]!
      var traversedFuture: Future<[String]>!
      var successValue: [String]?
      var expectedResult: [String]!
      var valuesToTraverse: [String]!
      
      beforeEach {
        valuesToTraverse = (0...5).map {
          "\($0)"
        }
        
        promises = valuesToTraverse.map { _ in
          Promise()
        }
        
        successValue = nil
        traversedFuture = valuesToTraverse
          .traverse { idx in
            promises[Int(idx)!].future
          }
        
        traversedFuture.onSuccess {
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
      
      it("should succeed the traversed future") {
        expect(successValue).notTo(beNil())
      }
      
      it("should succeed with the right value") {
        expect(successValue).to(equal(expectedResult))
      }
    }
  }
}
