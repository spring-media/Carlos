//import Foundation
//import Carlos
//import Quick
//import Nimble
//import PiedPiper
//
//class BatchAllCacheTests: QuickSpec {
//  override func spec() {
//    describe("allBatch") {
//      let requestsCount = 5
//
//      var internalCache: CacheLevelFake<Int, String>!
//      var cache: BatchAllCache<[Int], CacheLevelFake<Int, String>>!
//      var resultingFuture: Future<[String]>!
//
//      beforeEach {
//        internalCache = CacheLevelFake<Int, String>()
//        cache = internalCache.allBatch()
//      }
//      
//      context("when calling clear") {
//        beforeEach {
//          cache.clear()
//        }
//        
//        it("should call clear on the internal cache") {
//          expect(internalCache.numberOfTimesCalledClear).to(equal(1))
//        }
//      }
//      
//      context("when calling onMemoryWarning") {
//        beforeEach {
//          cache.onMemoryWarning()
//        }
//        
//        it("should call onMemoryWarning on the internal cache") {
//          expect(internalCache.numberOfTimesCalledOnMemoryWarning).to(equal(1))
//        }
//      }
//      
//      context("when calling set") {
//        var succeeded: Bool!
//        var failed: Error?
//        var canceled: Bool!
//        
//        let keys = [1, 2, 3]
//        let values = ["", "", ""]
//        
//        beforeEach {
//          cache.set(values, forKey: keys)
//            .onSuccess { _ in succeeded = true }
//            .onFailure { failed = $0 }
//            .onCancel { canceled = true }
//        }
//        
//        it("should call set on the internal cache") {
//          expect(internalCache.numberOfTimesCalledSet).to(equal(values.count))
//        }
//        
//        context("when one of the set calls fails") {
//          let error = TestError.anotherError
//          
//          beforeEach {
//            internalCache.setPromisesReturned[0].succeed(())
//            internalCache.setPromisesReturned[1].fail(error)
//          }
//          
//          it("should fail the whole future") {
//            expect(failed as? TestError).to(equal(error))
//          }
//        }
//        
//        context("when one of the set calls is canceled") {
//          beforeEach {
//            internalCache.setPromisesReturned[0].succeed(())
//            internalCache.setPromisesReturned[1].cancel()
//          }
//          
//          it("should cancel the whole future") {
//            expect(canceled).to(beTrue())
//          }
//        }
//        
//        context("when all the set calls succeed") {
//          beforeEach {
//            internalCache.setPromisesReturned[0].succeed(())
//            internalCache.setPromisesReturned[1].succeed(())
//            internalCache.setPromisesReturned[2].succeed(())
//          }
//          
//          it("should succeed the whole future") {
//            expect(succeeded).to(beTrue())
//          }
//        }
//      }
//      
//      context("when calling get") {
//        var result: [String]!
//        var errors: [Error]!
//        var canceled: Bool!
//        
//        beforeEach {
//          errors = []
//          result = nil
//          canceled = false
//          
//          resultingFuture = cache.get(Array(0..<requestsCount))
//            .onSuccess {
//              result = $0
//            }
//            .onFailure {
//              errors.append($0)
//            }
//            .onCancel {
//              canceled = true
//          }
//        }
//        
//        it("should dispatch all of the requests to the underlying cache") {
//          expect(internalCache.numberOfTimesCalledGet).to(equal(requestsCount))
//        }
//        
//        context("when one of the requests fails") {
//          beforeEach {
//            internalCache.promisesReturned[0].fail(TestError.simpleError)
//          }
//          
//          it("should fail the resulting future") {
//            expect(errors).notTo(beEmpty())
//          }
//          
//          it("should pass the right error") {
//            expect(errors.first as? TestError).to(equal(TestError.simpleError))
//          }
//          
//          it("should not call the success closure") {
//            expect(result).to(beNil())
//          }
//        }
//        
//        context("when one of the requests succeeds") {
//          beforeEach {
//            internalCache.promisesReturned[0].succeed("Test")
//          }
//          
//          it("should not call the failure closure") {
//            expect(errors).to(beEmpty())
//          }
//          
//          it("should not call the success closure") {
//            expect(result).to(beNil())
//          }
//        }
//        
//        context("when all of the requests succeed") {
//          beforeEach {
//            internalCache.promisesReturned.enumerated().forEach { (iteration, promise) in
//              promise.succeed("\(iteration)")
//            }
//          }
//          
//          it("should not call the failure closure") {
//            expect(errors).to(beEmpty())
//          }
//          
//          it("should call the success closure") {
//            expect(result).notTo(beNil())
//          }
//          
//          it("should pass all the values") {
//            expect(result.count).to(equal(internalCache.promisesReturned.count))
//          }
//          
//          it("should pass the individual results in the right order") {
//            expect(result).to(equal(internalCache.promisesReturned.enumerated().map { (iteration, _) in
//              "\(iteration)"
//              }))
//          }
//        }
//        
//        context("when one of the requests is canceled") {
//          beforeEach {
//            internalCache.promisesReturned[0].cancel()
//          }
//          
//          it("should not call the success closure") {
//            expect(result).to(beNil())
//          }
//          
//          it("should call the onCancel closure") {
//            expect(canceled).to(beTrue())
//          }
//        }
//        
//        context("when the resulting request is canceled") {
//          beforeEach {
//            resultingFuture.cancel()
//          }
//          
//          it("should cancel all the underlying requests") {
//            var canceledCount = 0
//            internalCache.promisesReturned.forEach { promise in
//              promise.onCancel {
//                canceledCount += 1
//              }
//            }
//            
//            expect(canceledCount).to(equal(internalCache.promisesReturned.count))
//          }
//        }
//      }
//    }
//  }
//}
//
//class BatchTests: QuickSpec {
//  override func spec() {
//    let requestsCount = 5
//    
//    var cache: CacheLevelFake<Int, String>!
//    var resultingFuture: Future<[String]>!
//    
//    beforeEach {
//      cache = CacheLevelFake<Int, String>()
//    }
//    
//    /*describe("batchGetAll") {
//      var result: [String]!
//      var errors: [Error]!
//      var canceled: Bool!
//      
//      beforeEach {
//        errors = []
//        result = nil
//        canceled = false
//        
//        resultingFuture = cache.batchGetAll(Array(0..<requestsCount))
//          .onSuccess {
//            result = $0
//          }
//          .onFailure {
//            errors.append($0)
//          }
//          .onCancel {
//            canceled = true
//          }
//      }
//      
//      it("should dispatch all of the requests to the underlying cache") {
//        expect(cache.numberOfTimesCalledGet).to(equal(requestsCount))
//      }
//      
//      context("when one of the requests fails") {
//        beforeEach {
//          cache.promisesReturned[0].fail(TestError.simpleError)
//        }
//        
//        it("should fail the resulting future") {
//          expect(errors).notTo(beEmpty())
//        }
//        
//        it("should pass the right error") {
//          expect(errors.first as? TestError).to(equal(TestError.simpleError))
//        }
//        
//        it("should not call the success closure") {
//          expect(result).to(beNil())
//        }
//      }
//      
//      context("when one of the requests succeeds") {
//        beforeEach {
//          cache.promisesReturned[0].succeed("Test")
//        }
//        
//        it("should not call the failure closure") {
//          expect(errors).to(beEmpty())
//        }
//        
//        it("should not call the success closure") {
//          expect(result).to(beNil())
//        }
//      }
//      
//      context("when all of the requests succeed") {
//        beforeEach {
//          cache.promisesReturned.enumerated().forEach { (iteration, promise) in
//            promise.succeed("\(iteration)")
//          }
//        }
//        
//        it("should not call the failure closure") {
//          expect(errors).to(beEmpty())
//        }
//        
//        it("should call the success closure") {
//          expect(result).notTo(beNil())
//        }
//        
//        it("should pass all the values") {
//          expect(result.count).to(equal(cache.promisesReturned.count))
//        }
//        
//        it("should pass the individual results in the right order") {
//          expect(result).to(equal(cache.promisesReturned.enumerated().map { (iteration, _) in
//            "\(iteration)"
//          }))
//        }
//      }
//      
//      context("when one of the requests is canceled") {
//        beforeEach {
//          cache.promisesReturned[0].cancel()
//        }
//        
//        it("should not call the success closure") {
//          expect(result).to(beNil())
//        }
//        
//        it("should call the onCancel closure") {
//          expect(canceled).to(beTrue())
//        }
//      }
//      
//      context("when the resulting request is canceled") {
//        beforeEach {
//          resultingFuture.cancel()
//        }
//        
//        it("should cancel all the underlying requests") {
//          var canceledCount = 0
//          cache.promisesReturned.forEach { promise in
//            promise.onCancel {
//              canceledCount += 1
//            }
//          }
//          
//          expect(canceledCount).to(equal(cache.promisesReturned.count))
//        }
//      }
//    }*/
//    
//    describe("batchGetSome") {
//      var result: [String]!
//      var errors: [Error]!
//      var canceled: Bool!
//      
//      beforeEach {
//        errors = []
//        result = nil
//        canceled = false
//        
//        resultingFuture = cache.batchGetSome(Array(0..<requestsCount))
//          .onSuccess {
//            result = $0
//          }
//          .onFailure {
//            errors.append($0)
//          }
//          .onCancel {
//            canceled = true
//          }
//      }
//      
//      it("should dispatch all of the requests to the underlying cache") {
//        expect(cache.numberOfTimesCalledGet).to(equal(requestsCount))
//      }
//      
//      context("when one of the requests fails") {
//        let failedIndex = 2
//        
//        beforeEach {
//          cache.promisesReturned[failedIndex].fail(TestError.simpleError)
//        }
//        
//        it("should not call the success closure") {
//          expect(result).to(beNil())
//        }
//        
//        it("should not call the failure closure") {
//          expect(errors).to(beEmpty())
//        }
//        
//        it("should not call the cancel closure") {
//          expect(canceled).to(beFalse())
//        }
//        
//        context("when all the other requests succeed") {
//          beforeEach {
//            cache.promisesReturned.enumerated().forEach { (iteration, promise) in
//              promise.succeed("\(iteration)")
//            }
//          }
//          
//          it("should call the success closure") {
//            expect(result).notTo(beNil())
//          }
//          
//          it("should pass the right number of results") {
//            expect(result.count).to(equal(cache.promisesReturned.count - 1))
//          }
//          
//          it("should only pass the succeeded requests") {
//            var expectedResult = cache.promisesReturned.enumerated().map { (iteration, _) in
//              "\(iteration)"
//            }
//            _ = expectedResult.remove(at: failedIndex)
//            
//            expect(result).to(equal(expectedResult))
//          }
//          
//          it("should not call the failure closure") {
//            expect(errors).to(beEmpty())
//          }
//          
//          it("should not call the cancel closure") {
//            expect(canceled).to(beFalse())
//          }
//        }
//      }
//      
//      context("when one of the requests succeeds") {
//        beforeEach {
//          cache.promisesReturned[1].succeed("1")
//        }
//        
//        it("should not call the failure closure") {
//          expect(errors).to(beEmpty())
//        }
//        
//        it("should not call the success closure") {
//          expect(result).to(beNil())
//        }
//        
//        context("when all the other requests complete") {
//          beforeEach {
//            cache.promisesReturned.enumerated().forEach { (iteration, promise) in
//              promise.succeed("\(iteration)")
//            }
//          }
//          
//          it("should call the success closure") {
//            expect(result).notTo(beNil())
//          }
//          
//          it("should pass the right number of results") {
//            expect(result.count).to(equal(cache.promisesReturned.count))
//          }
//          
//          it("should only pass the succeeded requests") {
//            expect(result).to(equal(cache.promisesReturned.enumerated().map { (iteration, _) in
//              "\(iteration)"
//            }))
//          }
//          
//          it("should not call the failure closure") {
//            expect(errors).to(beEmpty())
//          }
//          
//          it("should not call the cancel closure") {
//            expect(canceled).to(beFalse())
//          }
//        }
//      }
//      
//      context("when one of the requests is canceled") {
//        let canceledIndex = 3
//        
//        beforeEach {
//          cache.promisesReturned[canceledIndex].cancel()
//        }
//        
//        it("should not call the success closure") {
//          expect(result).to(beNil())
//        }
//        
//        it("should not call the onCancel closure") {
//          expect(canceled).to(beFalse())
//        }
//        
//        context("when all the other requests complete") {
//          beforeEach {
//            cache.promisesReturned.enumerated().forEach { (iteration, promise) in
//              promise.succeed("\(iteration)")
//            }
//          }
//          
//          it("should call the success closure") {
//            expect(result).notTo(beNil())
//          }
//          
//          it("should pass the right number of results") {
//            expect(result.count).to(equal(cache.promisesReturned.count - 1))
//          }
//          
//          it("should only pass the succeeded requests") {
//            var expectedResult = cache.promisesReturned.enumerated().map { (iteration, _) in
//              "\(iteration)"
//            }
//            _ = expectedResult.remove(at: canceledIndex)
//            
//            expect(result).to(equal(expectedResult))
//          }
//          
//          it("should not call the failure closure") {
//            expect(errors).to(beEmpty())
//          }
//          
//          it("should not call the cancel closure") {
//            expect(canceled).to(beFalse())
//          }
//        }
//      }
//      
//      context("when the resulting request is canceled") {
//        beforeEach {
//          resultingFuture.cancel()
//        }
//        
//        it("should cancel all the underlying requests") {
//          var canceledCount = 0
//          cache.promisesReturned.forEach { promise in
//            promise.onCancel {
//              canceledCount += 1
//            }
//          }
//          
//          expect(canceledCount).to(equal(cache.promisesReturned.count))
//        }
//      }
//    }
//  }
//}
