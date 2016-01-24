import Foundation
import Carlos
import Quick
import Nimble

class BatchTests: QuickSpec {
  override func spec() {
    let requestsCount = 5
    
    var cache: CacheLevelFake<Int, String>!
    var resultingFuture: Future<[String]>!
    
    beforeEach {
      cache = CacheLevelFake<Int, String>()
    }
    
    describe("batchGetAll") {
      var result: [String]!
      var errors: [ErrorType]!
      var canceled: Bool!
      
      beforeEach {
        errors = []
        result = nil
        canceled = false
        
        resultingFuture = cache.batchGetAll(Array(0..<requestsCount))
          .onSuccess {
            result = $0
          }
          .onFailure {
            errors.append($0)
          }
          .onCancel {
            canceled = true
          }
      }
      
      it("should dispatch all of the requests to the underlying cache") {
        expect(cache.numberOfTimesCalledGet).to(equal(requestsCount))
      }
      
      context("when one of the requests fails") {
        beforeEach {
          cache.promisesReturned[2].fail(TestError.SimpleError)
        }
        
        it("should fail the resulting future") {
          expect(errors).notTo(beEmpty())
        }
        
        it("should pass the right error") {
          expect(errors.first as? TestError).to(equal(TestError.SimpleError))
        }
        
        it("should not call the success closure") {
          expect(result).to(beNil())
        }
      }
      
      context("when one of the requests succeeds") {
        beforeEach {
          cache.promisesReturned[1].succeed("Test")
        }
        
        it("should not call the failure closure") {
          expect(errors).to(beEmpty())
        }
        
        it("should not call the success closure") {
          expect(result).to(beNil())
        }
      }
      
      context("when all of the requests succeed") {
        beforeEach {
          cache.promisesReturned.enumerate().forEach { (iteration, promise) in
            promise.succeed("\(iteration)")
          }
        }
        
        it("should not call the failure closure") {
          expect(errors).to(beEmpty())
        }
        
        it("should call the success closure") {
          expect(result).notTo(beNil())
        }
        
        it("should pass all the values") {
          expect(result.count).to(equal(cache.promisesReturned.count))
        }
        
        it("should pass the individual results in the right order") {
          expect(result).to(equal(cache.promisesReturned.enumerate().map { (iteration, _) in
            "\(iteration)"
          }))
        }
      }
      
      context("when one of the requests is canceled") {
        beforeEach {
          cache.promisesReturned[3].cancel()
        }
        
        it("should not call the success closure") {
          expect(result).to(beNil())
        }
        
        it("should call the onCancel closure") {
          expect(canceled).to(beTrue())
        }
      }
      
      context("when the resulting request is canceled") {
        beforeEach {
          resultingFuture.cancel()
        }
        
        it("should cancel all the underlying requests") {
          var canceledCount = 0
          cache.promisesReturned.forEach { promise in
            promise.onCancel {
              canceledCount += 1
            }
          }
          
          expect(canceledCount).to(equal(cache.promisesReturned.count))
        }
      }
    }
    
    describe("batchGetSome") {
      var result: [String]!
      var errors: [ErrorType]!
      var canceled: Bool!
      
      beforeEach {
        errors = []
        result = nil
        canceled = false
        
        resultingFuture = cache.batchGetSome(Array(0..<requestsCount))
          .onSuccess {
            result = $0
          }
          .onFailure {
            errors.append($0)
          }
          .onCancel {
            canceled = true
          }
      }
      
      it("should dispatch all of the requests to the underlying cache") {
        expect(cache.numberOfTimesCalledGet).to(equal(requestsCount))
      }
      
      context("when one of the requests fails") {
        let failedIndex = 2
        
        beforeEach {
          cache.promisesReturned[failedIndex].fail(TestError.SimpleError)
        }
        
        it("should not call the success closure") {
          expect(result).to(beNil())
        }
        
        it("should not call the failure closure") {
          expect(errors).to(beEmpty())
        }
        
        it("should not call the cancel closure") {
          expect(canceled).to(beFalse())
        }
        
        context("when all the other requests succeed") {
          beforeEach {
            cache.promisesReturned.enumerate().forEach { (iteration, promise) in
              promise.succeed("\(iteration)")
            }
          }
          
          it("should call the success closure") {
            expect(result).notTo(beNil())
          }
          
          it("should pass the right number of results") {
            expect(result.count).to(equal(cache.promisesReturned.count - 1))
          }
          
          it("should only pass the succeeded requests") {
            var expectedResult = cache.promisesReturned.enumerate().map { (iteration, _) in
              "\(iteration)"
            }
            expectedResult.removeAtIndex(failedIndex)
            
            expect(result).to(equal(expectedResult))
          }
          
          it("should not call the failure closure") {
            expect(errors).to(beEmpty())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
        }
      }
      
      context("when one of the requests succeeds") {
        beforeEach {
          cache.promisesReturned[1].succeed("1")
        }
        
        it("should not call the failure closure") {
          expect(errors).to(beEmpty())
        }
        
        it("should not call the success closure") {
          expect(result).to(beNil())
        }
        
        context("when all the other requests complete") {
          beforeEach {
            cache.promisesReturned.enumerate().forEach { (iteration, promise) in
              promise.succeed("\(iteration)")
            }
          }
          
          it("should call the success closure") {
            expect(result).notTo(beNil())
          }
          
          it("should pass the right number of results") {
            expect(result.count).to(equal(cache.promisesReturned.count))
          }
          
          it("should only pass the succeeded requests") {
            expect(result).to(equal(cache.promisesReturned.enumerate().map { (iteration, _) in
              "\(iteration)"
            }))
          }
          
          it("should not call the failure closure") {
            expect(errors).to(beEmpty())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
        }
      }
      
      context("when one of the requests is canceled") {
        let canceledIndex = 3
        
        beforeEach {
          cache.promisesReturned[canceledIndex].cancel()
        }
        
        it("should not call the success closure") {
          expect(result).to(beNil())
        }
        
        it("should not call the onCancel closure") {
          expect(canceled).to(beFalse())
        }
        
        context("when all the other requests complete") {
          beforeEach {
            cache.promisesReturned.enumerate().forEach { (iteration, promise) in
              promise.succeed("\(iteration)")
            }
          }
          
          it("should call the success closure") {
            expect(result).notTo(beNil())
          }
          
          it("should pass the right number of results") {
            expect(result.count).to(equal(cache.promisesReturned.count - 1))
          }
          
          it("should only pass the succeeded requests") {
            var expectedResult = cache.promisesReturned.enumerate().map { (iteration, _) in
              "\(iteration)"
            }
            expectedResult.removeAtIndex(canceledIndex)
            
            expect(result).to(equal(expectedResult))
          }
          
          it("should not call the failure closure") {
            expect(errors).to(beEmpty())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
        }
      }
      
      context("when the resulting request is canceled") {
        beforeEach {
          resultingFuture.cancel()
        }
        
        it("should cancel all the underlying requests") {
          var canceledCount = 0
          cache.promisesReturned.forEach { promise in
            promise.onCancel {
              canceledCount += 1
            }
          }
          
          expect(canceledCount).to(equal(cache.promisesReturned.count))
        }
      }
    }
  }
}