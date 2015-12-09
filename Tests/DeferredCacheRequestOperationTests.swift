import Foundation
import Quick
import Nimble
import Carlos

internal enum TestError: ErrorType {
  case SimpleError
  case AnotherError
}

class DeferredResultOperationTests: QuickSpec {
  override func spec() {
    describe("DeferredResultOperation") {
      var operation: DeferredResultOperation<CacheLevelFake<Int, String>>!
      var decoy: Promise<String>!
      var key: Int!
      var internalCache: CacheLevelFake<Int, String>!
      var successSentinel: Bool?
      var failureSentinel: Bool?
      var successValue: String?
      var cancelSentinel: Bool?
      
      beforeEach {
        successSentinel = nil
        failureSentinel = nil
        cancelSentinel = nil
        
        decoy = Promise<String>()
        
        decoy.onSuccess { value in
          successSentinel = true
          successValue = value
        }.onFailure { _ in
          failureSentinel = true
        }.onCancel {
          cancelSentinel = true
        }
        
        key = 10
        internalCache = CacheLevelFake<Int, String>()
        
        operation = DeferredResultOperation(decoyRequest: decoy, key: key, cache: internalCache)
      }
      
      it("should be ready") {
        expect(operation.ready).to(beTrue())
      }
      
      context("when the operation is not added to any queue") {
        it("should not call the success closure") {
          expect(successSentinel).to(beNil())
        }
        
        it("should not call the failure closure") {
          expect(failureSentinel).to(beNil())
        }
        
        it("should not perform any request on the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).to(equal(0))
        }
      }
      
      context("when the operation is added to a queue") {
        var queue: NSOperationQueue!
        var requestToReturn: Promise<String>!
        
        beforeEach {
          requestToReturn = Promise<String>()
          internalCache.cacheRequestToReturn = requestToReturn.future
          
          queue = NSOperationQueue()
          
          queue.addOperation(operation)
        }
        
        it("should perform the get request on the internal cache") {
          expect(internalCache.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should not call the success closure yet") {
          expect(successSentinel).toEventually(beNil())
        }
        
        it("should not call the failure closure yet") {
          expect(failureSentinel).toEventually(beNil())
        }
        
        it("should not call the cancel closure yet") {
          expect(cancelSentinel).toEventually(beNil())
        }
        
        context("when the internal request succeeds") {
          let value = "10"
          
          beforeEach {
            requestToReturn.succeed(value)
          }
          
          it("should call the success closure on the decoy") {
            expect(successSentinel).toEventually(beTrue())
          }
          
          it("should pass the right value to the closure") {
            expect(successValue).toEventually(equal(value))
          }
          
          it("should not call the failure closure") {
            expect(failureSentinel).toEventually(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(cancelSentinel).toEventually(beNil())
          }
          
          it("should finish the operation") {
            expect(operation.finished).toEventually(beTrue())
          }
        }
        
        context("when the internal request is canceled") {
          beforeEach {
            requestToReturn.cancel()
          }
          
          it("should not call the failure closure") {
            expect(failureSentinel).toEventually(beNil())
          }
          
          it("should not call the success closure") {
            expect(successSentinel).toEventually(beNil())
          }
          
          it("should call the cancel closure") {
            expect(cancelSentinel).toEventually(beTrue())
          }
          
          it("should finish the operation") {
            expect(operation.finished).toEventually(beTrue())
          }
        }
        
        context("when the internal request fails") {
          beforeEach {
            requestToReturn.fail(TestError.SimpleError)
          }
          
          it("should call the failure closure") {
            expect(failureSentinel).toEventually(beTrue())
          }
          
          it("should not call the success closure") {
            expect(successSentinel).toEventually(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(cancelSentinel).toEventually(beNil())
          }
          
          it("should finish the operation") {
            expect(operation.finished).toEventually(beTrue())
          }
        }
      }
    }
  }
}