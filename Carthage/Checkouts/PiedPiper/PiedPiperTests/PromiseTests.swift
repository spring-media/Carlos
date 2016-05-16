import Foundation
import Quick
import Nimble
import PiedPiper

class PromiseTests: QuickSpec {
  private class MemoryHelper {
    weak var weakVarSuccess: MemorySentinel?
    weak var weakVarFailure: MemorySentinel?
    weak var weakVarCancel: MemorySentinel?
    weak var referencedPromise: Promise<String>?
    
    func setupWithPromise(promise: Promise<String>) {
      referencedPromise = promise
      
      promise.onSuccess { _ in
        self.weakVarSuccess?.doFoo()
      }
      
      promise.onFailure { _ in
        self.weakVarFailure?.doFoo()
      }
      
      promise.onCancel {
        self.weakVarCancel?.doFoo()
      }
    }
  }
  
  private class MemorySentinel {
    var didFoo = false
    
    func doFoo() {
      didFoo = true
    }
  }
  
  override func spec() {
    describe("Promise") {
      var request: Promise<String>!
      let sentinelsCount = 3
      var successSentinels: [String?]!
      var failureSentinels: [ErrorType?]!
      var cancelSentinels: [Bool?]!
      var successCompletedSentinels: [String?]!
      var failureCompletedSentinels: [ErrorType?]!
      var cancelCompletedSentinels: [Bool?]!
      
      let resetSentinels: Void -> Void = {
        successSentinels = [String?](count: sentinelsCount, repeatedValue: nil)
        failureSentinels = [ErrorType?](count: sentinelsCount, repeatedValue: nil)
        cancelSentinels = [Bool?](count: sentinelsCount, repeatedValue: nil)
        successCompletedSentinels = [String?](count: sentinelsCount, repeatedValue: nil)
        failureCompletedSentinels = [ErrorType?](count: sentinelsCount, repeatedValue: nil)
        cancelCompletedSentinels = [Bool?](count: sentinelsCount, repeatedValue: nil)
      }
      
      context("when managing its listeners") {
        weak var weakSut: MemoryHelper?
        var promise: Promise<String>!
        var successSentinel: MemorySentinel!
        var failureSentinel: MemorySentinel!
        var cancelSentinel: MemorySentinel!
        
        beforeEach {
          let sut = MemoryHelper()
          
          successSentinel = MemorySentinel()
          failureSentinel = MemorySentinel()
          cancelSentinel = MemorySentinel()
          
          sut.weakVarSuccess = successSentinel
          sut.weakVarFailure = failureSentinel
          sut.weakVarCancel = cancelSentinel
          
          promise = Promise<String>()
          sut.setupWithPromise(promise)
          
          weakSut = sut
        }
        
        it("should not release the subject under test because of the listeners retaining it") {
          expect(weakSut).notTo(beNil())
        }
        
        context("when the promise succeeds") {
          beforeEach {
            promise.succeed("test")
          }
          
          it("should call doFoo on the weak sentinel") {
            expect(successSentinel.didFoo).to(beTrue())
          }
          
          it("should not call doFoo on the other sentinels") {
            expect(failureSentinel.didFoo).to(beFalse())
            expect(cancelSentinel.didFoo).to(beFalse())
          }
          
          it("should release the subject under test because the listeners are not retaining it anymore") {
            expect(weakSut).to(beNil())
          }
        }
        
        context("when the promise is canceled") {
          beforeEach {
            promise.cancel()
          }
          
          it("should call doFoo on the weak sentinel") {
            expect(cancelSentinel.didFoo).to(beTrue())
          }
          
          it("should not call doFoo on the other sentinels") {
            expect(failureSentinel.didFoo).to(beFalse())
            expect(successSentinel.didFoo).to(beFalse())
          }
          
          it("should release the subject under test because the listeners are not retaining it anymore") {
            expect(weakSut).to(beNil())
          }
        }
        
        context("when the promise fails") {
          beforeEach {
            promise.fail(TestError.SimpleError)
          }
          
          it("should call doFoo on the weak sentinel") {
            expect(failureSentinel.didFoo).to(beTrue())
          }
          
          it("should not call doFoo on the other sentinels") {
            expect(successSentinel.didFoo).to(beFalse())
            expect(cancelSentinel.didFoo).to(beFalse())
          }
          
          it("should release the subject under test because the listeners are not retaining it anymore") {
            expect(weakSut).to(beNil())
          }
        }
      }
      
      context("when mimicing another future") {
        var mimiced: Promise<String>!
        var successValue: String!
        var errorValue: ErrorType!
        var canceled: Bool!
        
        beforeEach {
          successValue = nil
          errorValue = nil
          canceled = false
          
          mimiced = Promise<String>()
          request = Promise<String>()
            .onSuccess({ successValue = $0 })
            .onFailure({ errorValue = $0 })
            .onCancel({ canceled = true })
            .mimic(mimiced.future)
        }
        
        context("when the other future succeeds") {
          let value = "success value"
          
          beforeEach {
            mimiced.succeed(value)
          }
          
          it("should call the success closure") {
            expect(successValue).notTo(beNil())
          }
          
          it("should not call the error closure") {
            expect(errorValue).to(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
          
          it("should pass the right value") {
            expect(successValue).to(equal(value))
          }
        }
        
        context("when the other future fails") {
          let error = TestError.AnotherError
          
          beforeEach {
            mimiced.fail(error)
          }
          
          it("should call the error closure") {
            expect(errorValue).notTo(beNil())
          }
          
          it("should not call the success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
          
          it("should pass the right error") {
            expect(errorValue as? TestError).to(equal(error))
          }
        }
        
        context("when the other future is canceled") {
          beforeEach {
            mimiced.cancel()
          }
          
          it("should not call the success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should call the cancel closure") {
            expect(canceled).to(beTrue())
          }
          
          it("should not call the failure closure") {
            expect(errorValue).to(beNil())
          }
        }
        
        context("when the promise itself succeeds") {
          let value = "also a success value"
          
          beforeEach {
            request.succeed(value)
          }
          
          it("should call the success closure") {
            expect(successValue).notTo(beNil())
          }
          
          it("should not call the failure closure") {
            expect(errorValue).to(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
          
          it("should pass the right value") {
            expect(successValue).to(equal(value))
          }
        }
        
        context("when the promise itself fails") {
          let error = TestError.SimpleError
          
          beforeEach {
            request.fail(error)
          }
          
          it("should call the failure closure") {
            expect(errorValue).notTo(beNil())
          }
          
          it("should not call the success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
          
          it("should pass the right error") {
            expect(errorValue as? TestError).to(equal(error))
          }
        }
        
        context("when the promise itself is canceled") {
          beforeEach {
            request.cancel()
          }
          
          it("should not call the success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should call the cancel closure") {
            expect(canceled).to(beTrue())
          }
          
          it("should not call the failure closure") {
            expect(errorValue).to(beNil())
          }
        }
        
        context("when mimicing two futures at the same time") {
          var mimiced2: Promise<String>!
          
          beforeEach {
            mimiced2 = Promise<String>()
            request.mimic(mimiced2.future)
          }
          
          context("when the other future succeeds") {
            let value = "still a success value"
            
            beforeEach {
              mimiced2.succeed(value)
            }
            
            it("should call the success closure") {
              expect(successValue).notTo(beNil())
            }
            
            it("should not call the failure closure") {
              expect(errorValue).to(beNil())
            }
            
            it("should pass the right value") {
              expect(successValue).to(equal(value))
            }
          }
          
          context("when the other future fails") {
            let error = TestError.AnotherError
            
            beforeEach {
              mimiced2.fail(error)
            }
            
            it("should call the failure closure") {
              expect(errorValue).notTo(beNil())
            }
            
            it("should not call the success closure") {
              expect(successValue).to(beNil())
            }
            
            it("should pass the right error") {
              expect(errorValue as? TestError).to(equal(error))
            }
          }
          
          context("when the other future is canceled") {
            beforeEach {
              mimiced2.cancel()
            }
            
            it("should call the cancel closure") {
              expect(canceled).to(beTrue())
            }
            
            it("should not call the success closure") {
              expect(successValue).to(beNil())
            }
            
            it("should not call the failure closure") {
              expect(errorValue).to(beNil())
            }
          }
        }
      }
      
      context("when mimicing a result") {
        var mimiced: Result<String>!
        var successValue: String!
        var errorValue: ErrorType!
        var canceled: Bool!
        
        beforeEach {
          successValue = nil
          errorValue = nil
          canceled = false
          
          request = Promise<String>()
            .onSuccess({ successValue = $0 })
            .onFailure({ errorValue = $0 })
            .onCancel({ canceled = true })
        }
        
        context("when the result succeeds") {
          let value = "success value"
          
          beforeEach {
            mimiced = Result.Success(value)
            request.mimic(mimiced)
          }
          
          it("should call the success closure") {
            expect(successValue).notTo(beNil())
          }
          
          it("should not call the error closure") {
            expect(errorValue).to(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
          
          it("should pass the right value") {
            expect(successValue).to(equal(value))
          }
        }
        
        context("when the other future fails") {
          let error = TestError.AnotherError
          
          beforeEach {
            mimiced = Result.Error(error)
            request.mimic(mimiced)
          }
          
          it("should call the error closure") {
            expect(errorValue).notTo(beNil())
          }
          
          it("should not call the success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
          
          it("should pass the right error") {
            expect(errorValue as? TestError).to(equal(error))
          }
        }
        
        context("when the other future is canceled") {
          beforeEach {
            mimiced = Result.Cancelled
            request.mimic(mimiced)
          }
          
          it("should not call the success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should call the cancel closure") {
            expect(canceled).to(beTrue())
          }
          
          it("should not call the failure closure") {
            expect(errorValue).to(beNil())
          }
        }
        
        context("when the promise itself succeeds") {
          let value = "also a success value"
          
          beforeEach {
            request.succeed(value)
          }
          
          it("should call the success closure") {
            expect(successValue).notTo(beNil())
          }
          
          it("should not call the failure closure") {
            expect(errorValue).to(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
          
          it("should pass the right value") {
            expect(successValue).to(equal(value))
          }
        }
        
        context("when the promise itself fails") {
          let error = TestError.SimpleError
          
          beforeEach {
            request.fail(error)
          }
          
          it("should call the failure closure") {
            expect(errorValue).notTo(beNil())
          }
          
          it("should not call the success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should not call the cancel closure") {
            expect(canceled).to(beFalse())
          }
          
          it("should pass the right error") {
            expect(errorValue as? TestError).to(equal(error))
          }
        }
        
        context("when the promise itself is canceled") {
          beforeEach {
            request.cancel()
          }
          
          it("should not call the success closure") {
            expect(successValue).to(beNil())
          }
          
          it("should call the cancel closure") {
            expect(canceled).to(beTrue())
          }
          
          it("should not call the failure closure") {
            expect(errorValue).to(beNil())
          }
        }
        
        context("when mimicing two results at the same time") {
          var mimiced2: Result<String>!
          
          context("when the other future succeeds") {
            let value = "still a success value"
            
            beforeEach {
              mimiced2 = Result.Success(value)
              request.mimic(mimiced2)
            }
            
            it("should call the success closure") {
              expect(successValue).notTo(beNil())
            }
            
            it("should not call the failure closure") {
              expect(errorValue).to(beNil())
            }
            
            it("should pass the right value") {
              expect(successValue).to(equal(value))
            }
          }
          
          context("when the other future fails") {
            let error = TestError.AnotherError
            
            beforeEach {
              mimiced2 = Result.Error(error)
              request.mimic(mimiced2)
            }
            
            it("should call the failure closure") {
              expect(errorValue).notTo(beNil())
            }
            
            it("should not call the success closure") {
              expect(successValue).to(beNil())
            }
            
            it("should pass the right error") {
              expect(errorValue as? TestError).to(equal(error))
            }
          }
          
          context("when the other future is canceled") {
            beforeEach {
              mimiced2 = Result.Cancelled
              request.mimic(mimiced2)
            }
            
            it("should call the cancel closure") {
              expect(canceled).to(beTrue())
            }
            
            it("should not call the success closure") {
              expect(successValue).to(beNil())
            }
            
            it("should not call the failure closure") {
              expect(errorValue).to(beNil())
            }
          }
        }
      }
      
      context("when returning its associated Future") {
        var future: Future<String>!
        
        beforeEach {
          request = Promise<String>()
          future = request.future
        }
        
        it("should return always the same instance") {
          expect(future).to(beIdenticalTo(request.future))
        }
        
        itBehavesLike("a Future") {
          [
            FutureSharedExamplesContext.Future: future,
            FutureSharedExamplesContext.Promise: request
          ]
        }
      }
      
      context("when initialized with the designated initializer") {
        beforeEach {
          request = Promise<String>()
          
          resetSentinels()
        
          for idx in 0..<sentinelsCount {
            request
              .onSuccess { result in
                successSentinels[idx] = result
              }
              .onFailure { error in
                failureSentinels[idx] = error
              }
              .onCancel {
                cancelSentinels[idx] = true
              }
              .onCompletion { result in
                switch result {
                case .Success(let value):
                  successCompletedSentinels[idx] = value
                case .Error(let error):
                  failureCompletedSentinels[idx] = error
                case .Cancelled:
                  cancelCompletedSentinels[idx] = true
                }
              }
          }
        }
        
        it("should not call any success closure") {
          expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
        }
        
        it("should not call any failure closure") {
          expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
        }
        
        it("should not call any cancel closure") {
          expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
        }
          
        it("should not call any completion closure with values") {
          expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
        }
          
        it("should not call any completion closure with errors") {
          expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
        }
          
        it("should not call any completion closure with nil error and nil value") {
          expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
        }
        
        context("when calling succeed") {
          let value = "success value"
          
          beforeEach {
            request.succeed(value)
          }
          
          it("should call the success closures") {
            expect(successSentinels).to(allPass({ $0! == value }))
          }
        
          it("should not call any failure closure") {
            expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
          }
        
          it("should not call any cancel closure") {
            expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(cancelSentinels.count))
          }
            
          it("should call the completion closures passing a value") {
            for sSentinel in successCompletedSentinels {
              expect(sSentinel).to(equal(value))
            }
          }
            
          it("should not call the completion closures passing an error") {
            expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
          }
        
          context("when calling onSuccess again") {
            var subsequentSuccessSentinel: String?
            
            beforeEach {
              request.onSuccess { result in
                subsequentSuccessSentinel = result
              }
            }
            
            it("should immediately call the closure") {
              expect(subsequentSuccessSentinel).to(equal(value))
            }
          }
            
          context("when calling onCompletion again") {
            var subsequentSuccessSentinel: String?
            
            beforeEach {
              request.onCompletion { result in
                if let value = result.value {
                  subsequentSuccessSentinel = value
                }
              }
            }
            
            it("should immediately call the closure") {
              expect(subsequentSuccessSentinel).to(equal(value))
            }
          }
            
          context("when calling succeed again") {
            let anotherValue = "another success value"
          
            beforeEach {
              resetSentinels()
            
              request.succeed(anotherValue)
            }
          
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
            
          context("when calling fail") {
            beforeEach {
              resetSentinels()
          
              request.fail(TestError.SimpleError)
            }
            
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
            
          context("when calling cancel") {
            beforeEach {
              resetSentinels()
            
              request.cancel()
            }
              
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
        }
        
        context("when calling fail") {
          let errorCode = TestError.AnotherError
          
          beforeEach {
            request.fail(errorCode)
          }
          
          it("should call the failure closures") {
            for fSentinel in failureSentinels {
              expect(fSentinel as? TestError).to(equal(errorCode))
            }
          }
          
          it("should not call any success closure") {
            expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
          }
          
          it("should not call any cancel closure") {
            expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(cancelSentinels.count))
          }
              
          it("should call the completion closures passing an error") {
            for fSentinel in failureCompletedSentinels {
              expect(fSentinel as? TestError).to(equal(errorCode))
            }
          }
              
          it("should not call the completion closures passing a value") {
            expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
          }
          
          context("when calling onFailure again") {
            var subsequentFailureSentinel: ErrorType?
            
            beforeEach {
              request.onFailure { error in
                subsequentFailureSentinel = error
              }
            }
            
            it("should immediately call the closures") {
              expect(subsequentFailureSentinel as? TestError).to(equal(errorCode))
            }
          }
              
          context("when calling onCompletion again") {
            var subsequentFailureSentinel: ErrorType?
              
            beforeEach {
              request.onCompletion { result in
                if case .Error(let error) = result {
                  subsequentFailureSentinel = error
                }
              }
            }
              
            it("should immediately call the closure") {
              expect(subsequentFailureSentinel as? TestError).to(equal(errorCode))
            }
          }
              
          context("when calling succeed") {
            let anotherValue = "a success value"
                
            beforeEach {
              resetSentinels()
              
              request.succeed(anotherValue)
            }
                
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
              
          context("when calling fail again") {
            beforeEach {
              resetSentinels()
              
              request.fail(TestError.SimpleError)
            }
                
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
              
          context("when calling cancel") {
            beforeEach {
              resetSentinels()
              
              request.cancel()
            }
                
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
        }
          
        context("when calling cancel") {
          beforeEach {
            request.cancel()
          }
            
          it("should call the cancel closures") {
            for cSentinel in cancelSentinels {
              expect(cSentinel).to(beTrue())
            }
          }
            
          it("should not call any success closure") {
            expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
          }
            
          it("should not call any failure closure") {
            expect(failureSentinels.filter({ $0 == nil }).count).to(equal(cancelSentinels.count))
          }
            
          it("should call the completion closures passing no error and no value") {
            for cSentinel in cancelCompletedSentinels {
              expect(cSentinel).to(beTrue())
            }
          }
            
          context("when calling onCancel again") {
            var subsequentCancelSentinel: Bool?
              
            beforeEach {
              request.onCancel {
                subsequentCancelSentinel = true
              }
            }
              
            it("should immediately call the closures") {
              expect(subsequentCancelSentinel).to(beTrue())
            }
          }
            
          context("when calling onCompletion again") {
            var subsequentCancelSentinel: Bool?
                
            beforeEach {
              request.onCompletion { result in
                if case .Cancelled = result {
                  subsequentCancelSentinel = true
                } else {
                  subsequentCancelSentinel = false
                }
              }
            }
                
            it("should immediately call the closure") {
              expect(subsequentCancelSentinel).to(beTrue())
            }
          }
            
          context("when calling succeed") {
            let anotherValue = "a success value"
                
            beforeEach {
              resetSentinels()
              
              request.succeed(anotherValue)
            }
                
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
                
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
            
          context("when calling fail") {
            beforeEach {
              resetSentinels()
              
              request.fail(TestError.SimpleError)
            }
            
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
              
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
            
          context("when calling cancel again") {
            beforeEach {
              resetSentinels()
              
              request.cancel()
            }
            
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any failure closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any cancel closure") {
              expect(cancelSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any completion closure with values") {
              expect(successCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any completion closure with errors") {
              expect(failureCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
            
            it("should not call any completion closure with nil error and nil value") {
              expect(cancelCompletedSentinels.filter({ $0 == nil }).count).to(equal(sentinelsCount))
            }
          }
        }
      }
    }
  }
}