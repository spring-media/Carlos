import Foundation
import Quick
import Nimble
import Carlos

class DeferredCacheRequestOperationTests: QuickSpec {
  override func spec() {
    describe("DeferredCacheRequestOperation") {
      var operation: DeferredCacheRequestOperation<CacheLevelFake<Int, String>>!
      var decoy: CacheRequest<String>!
      var key: Int!
      var internalCache: CacheLevelFake<Int, String>!
      var successSentinel: Bool?
      var failureSentinel: Bool?
      var successValue: String?
      
      beforeEach {
        successSentinel = nil
        failureSentinel = nil
        
        decoy = CacheRequest<String>()
        
        decoy.onSuccess({ value in
          successSentinel = true
          successValue = value
        }).onFailure({ _ in
          failureSentinel = true
        })
        
        key = 10
        internalCache = CacheLevelFake<Int, String>()
        
        operation = DeferredCacheRequestOperation(decoyRequest: decoy, key: key, cache: internalCache)
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
        var requestToReturn: CacheRequest<String>!
        
        beforeEach {
          requestToReturn = CacheRequest<String>()
          internalCache.cacheRequestToReturn = requestToReturn
          
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
          
          it("should finish the operation") {
            expect(operation.finished).toEventually(beTrue())
          }
        }
        
        context("when the internal request fails") {
          beforeEach {
            requestToReturn.fail(nil)
          }
          
          it("should call the failure closure") {
            expect(failureSentinel).toEventually(beTrue())
          }
          
          it("should not call the success closure") {
            expect(successSentinel).toEventually(beNil())
          }
          
          it("should finish the operation") {
            expect(operation.finished).toEventually(beTrue())
          }
        }
      }
    }
  }
}