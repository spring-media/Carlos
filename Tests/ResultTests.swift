import Foundation
import Quick
import Nimble
import Carlos

private struct ResultSharedExamplesContext {
  static let Result = "result"
  static let Value = "value"
}

class ResultSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("failure case") { (sharedExampleContext: SharedExampleContext) in
      var request: Result<String>!
      var successSentinels: [String?]!
      var failureSentinels: [ErrorType?]!
      var cancelSentinels: [Bool?]!
      
      beforeEach {
        request = sharedExampleContext()[ResultSharedExamplesContext.Result] as? Result<String>
        
        cancelSentinels = [nil, nil, nil]
        successSentinels = [nil, nil, nil]
        failureSentinels = [nil, nil, nil]
      }
      
      context("when calling onSuccess") {
        beforeEach {
          for idx in 0..<successSentinels.count {
            request.onSuccess { result in
              successSentinels[idx] = result
            }
          }
        }
        
        it("should not call the closures") {
          expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
        }
      }
      
      context("when calling onFailure") {
        beforeEach {
          for idx in 0..<successSentinels.count {
            request.onFailure { error in
              failureSentinels[idx] = error
            }
          }
        }
        
        it("should immediately call the closures") {
          expect(failureSentinels.filter({ $0 != nil }).count).to(equal(failureSentinels.count))
        }
        
        it("should pass the right error") {
          for fSentinel in failureSentinels {
            expect(fSentinel as? TestError).to(equal(TestError.SimpleError))
          }
        }
      }
      
      context("when calling onCancel") {
        beforeEach {
          for idx in 0..<cancelSentinels.count {
            request.onCancel {
              cancelSentinels[idx] = true
            }
          }
        }
        
        it("should not call the closures") {
          expect(cancelSentinels.filter({ $0 == nil}).count).to(equal(cancelSentinels.count))
        }
      }
      
      context("when calling onCompletion") {
        beforeEach {
          for idx in 0..<successSentinels.count {
            request.onCompletion { value, error in
              successSentinels[idx] = value
              if let error = error {
                failureSentinels[idx] = error
              }
            }
          }
        }
        
        it("should immediately call the closures") {
          expect(failureSentinels.filter({ $0 != nil }).count).to(equal(failureSentinels.count))
        }
        
        it("should pass the right error") {
          for fSentinel in failureSentinels {
            expect(fSentinel as? TestError).to(equal(TestError.SimpleError))
          }
        }
        
        it("should not pass a value") {
          expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
        }
      }
    }
    
    sharedExamples("success case") { (sharedExampleContext: SharedExampleContext) in
      var request: Result<String>!
      var value: String!
      var successSentinels: [String?]!
      var failureSentinels: [ErrorType?]!
      var cancelSentinels: [Bool?]!
      
      beforeEach {
        request = sharedExampleContext()[ResultSharedExamplesContext.Result] as? Result<String>
        value = sharedExampleContext()[ResultSharedExamplesContext.Value] as? String
        
        successSentinels = [nil, nil, nil]
        failureSentinels = [nil, nil, nil]
        cancelSentinels = [nil, nil, nil]
      }
      
      context("when calling onSuccess") {
        beforeEach {
          for idx in 0..<successSentinels.count {
            request.onSuccess({ result in
              successSentinels[idx] = result
            })
          }
        }
        
        it("should immediately call the closures") {
          expect(successSentinels.filter({ $0 != nil }).count).to(equal(successSentinels.count))
        }
        
        it("should pass the right value") {
          expect(successSentinels).to(allPass({ $0! == value }))
        }
      }
      
      context("when calling onCancel") {
        beforeEach {
          for idx in 0..<cancelSentinels.count {
            request.onCancel {
              cancelSentinels[idx] = true
            }
          }
        }
        
        it("should not call the closures") {
          expect(cancelSentinels.filter({ $0 == nil}).count).to(equal(cancelSentinels.count))
        }
      }
      
      context("when calling onFailure") {
        beforeEach {
          for idx in 0..<successSentinels.count {
            request.onFailure { error in
              failureSentinels[idx] = error
            }
          }
        }
        
        it("should not call the closures") {
          expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
        }
      }
      
      context("when calling onCompletion") {
        beforeEach {
          for idx in 0..<successSentinels.count {
            request.onCompletion { value, error in
              successSentinels[idx] = value
              if let error = error {
                failureSentinels[idx] = error
              }
            }
          }
        }
        
        it("should not call the closures passing an error") {
          expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
        }
        
        it("should call the closures passing a value") {
          expect(successSentinels).to(allPass({ $0! == value }))
        }
      }
    }
  }
}

class ResultTests: QuickSpec {
  override func spec() {
    describe("Result") {
      var request: Result<String>!
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
      
      context("when mimicing another result") {
        var mimiced: Result<String>!
        var successValue: String!
        var errorValue: ErrorType!
        var canceled: Bool!
        
        beforeEach {
          successValue = nil
          errorValue = nil
          canceled = false
          
          mimiced = Result<String>()
          request = Result<String>()
            .onSuccess({ successValue = $0 })
            .onFailure({ errorValue = $0 })
            .onCancel({ canceled = true })
            .mimic(mimiced)
        }
        
        context("when the other result succeeds") {
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
        
        context("when the other result fails") {
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
        
        context("when the other result is canceled") {
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
        
        context("when the result itself succeeds") {
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
        
        context("when the result itself fails") {
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
        
        context("when the result itself is canceled") {
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
          
          beforeEach {
            mimiced2 = Result<String>()
            request.mimic(mimiced2)
          }
          
          context("when the other result succeeds") {
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
          
          context("when the other result fails") {
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
          
          context("when the other result is canceled") {
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
      
      context("when initialized with the designated initializer") {
        beforeEach {
          request = Result<String>()
          
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
              .onCompletion { value, error in
                if let error = error {
                  failureCompletedSentinels[idx] = error
                } else if let value = value {
                  successCompletedSentinels[idx] = value
                } else {
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
              request.onCompletion { (value, error) in
                subsequentSuccessSentinel = value
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
              request.onCompletion { (value, error) in
                subsequentFailureSentinel = error
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
              request.onCompletion { (value, error) in
                subsequentCancelSentinel = error == nil && value == nil
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
      
      context("when initialized with a value") {
        let value = "this is a sync success value"
        
        beforeEach {
          request = Result(value: value)
        }
        
        itBehavesLike("success case") {
          [
            ResultSharedExamplesContext.Result: request,
            ResultSharedExamplesContext.Value: value
          ]
        }
      }
      
      context("when initialized with an optional value and an error") {
        context("when the optional value is nil") {
          beforeEach {
            request = Result(value: nil, error: TestError.SimpleError)
          }
        
          itBehavesLike("failure case") {
            [
              ResultSharedExamplesContext.Result: request
            ]
          }
        }
        
        context("when the optional value is not nil") {
          let value = "this is a sync success value"
      
          beforeEach {
            request = Result(value: value, error: TestError.SimpleError)
          }
          
          itBehavesLike("success case") {
            [
              ResultSharedExamplesContext.Result: request,
              ResultSharedExamplesContext.Value: value
            ]
          }
        }
      }
      
      context("when initialized with an error") {
        let error = TestError.SimpleError
        
        beforeEach {
          request = Result<String>(error: error)
        }
      
        itBehavesLike("failure case") {
          [
            ResultSharedExamplesContext.Result: request
          ]
        }
      }
    }
  }
}