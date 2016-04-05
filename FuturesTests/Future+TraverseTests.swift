import Quick
import Nimble
import PiedPiper

class SequenceTraverseTests: QuickSpec {
  override func spec() {
    describe("Traversing a list of items") {
      var promises: [Promise<Int>]!
      var traversedFuture: Future<[Int]>!
      var successValue: [Int]?
      var failureValue: ErrorType?
      var wasCanceled: Bool!
      var valuesToTraverse: [Int]!
      
      beforeEach {
        valuesToTraverse = Array(0...5)
        promises = valuesToTraverse.map { _ in
          Promise()
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
            expectedResult = promises.enumerate().map { $0.index }
            promises.enumerate().forEach { (iteration, promise) in
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
        
        var arrayOfIndexes = Array(promises.enumerate())
        
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