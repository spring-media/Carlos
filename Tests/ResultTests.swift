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
      
      beforeEach {
        request = sharedExampleContext()[ResultSharedExamplesContext.Result] as? Result<String>
        
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
      
      beforeEach {
        request = sharedExampleContext()[ResultSharedExamplesContext.Result] as? Result<String>
        value = sharedExampleContext()[ResultSharedExamplesContext.Value] as? String
        
        successSentinels = [nil, nil, nil]
        failureSentinels = [nil, nil, nil]
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
      var successSentinels: [String?]!
      var failureSentinels: [ErrorType?]!
      
      context("when mimicing another result") {
        var mimiced: Result<String>!
        var successValue: String!
        var errorValue: ErrorType!
        
        beforeEach {
          successValue = nil
          errorValue = nil
          
          mimiced = Result<String>()
          request = Result<String>()
            .onSuccess({ successValue = $0 })
            .onFailure({ errorValue = $0 })
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
          
          it("should pass the right error") {
            expect(errorValue as? TestError).to(equal(error))
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
          
          it("should pass the right error") {
            expect(errorValue as? TestError).to(equal(error))
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
        }
      }
      
      context("when initialized with the empty initializer") {
        beforeEach {
          request = Result<String>()
          
          successSentinels = [nil, nil, nil]
          failureSentinels = [nil, nil, nil]
        }
        
        context("when calling onSuccess") {
          beforeEach {
            for idx in 0..<successSentinels.count {
              request.onSuccess({ result in
                successSentinels[idx] = result
              })
            }
          }
          
          it("should not immediately call the closures") {
            expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
          }
          
          context("when calling succeed") {
            let value = "success value"
            
            beforeEach {
              request.succeed(value)
            }
            
            it("should call the closures") {
              expect(successSentinels).to(allPass({ $0! == value }))
            }
            
            context("when calling onSuccess again") {
              var subsequentSuccessSentinel: String?
              
              beforeEach {
                request.onSuccess({ result in
                  subsequentSuccessSentinel = result
                })
              }
              
              it("should immediately call the closures") {
                expect(subsequentSuccessSentinel).to(equal(value))
              }
            }
          }
          
          context("when calling fail") {
            beforeEach {
              request.fail(TestError.SimpleError)
            }
            
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
            }
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
          
          it("should not immediately call the closures") {
            expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
          }
          
          context("when calling fail") {
            let errorCode = TestError.AnotherError
            
            beforeEach {
              request.fail(errorCode)
            }
            
            it("should call the closures") {
              for fSentinel in failureSentinels {
                expect(fSentinel as? TestError).to(equal(errorCode))
              }
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
          }
          
          context("when calling succeed") {
            beforeEach {
              request.succeed("test")
            }
            
            it("should not call any closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
            }
          }
        }
        
        context("when calling onCompletion") {
          beforeEach {
            for idx in 0..<successSentinels.count {
              request.onCompletion { value, error in
                if let error = error {
                  failureSentinels[idx] = error
                }
                successSentinels[idx] = value
              }
            }
          }
          
          it("should not immediately call the closures passing an error") {
            expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
          }
          
          it("should not immediately call the closures passing a value") {
            expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
          }
          
          context("when calling fail") {
            let errorCode = -1100
            
            beforeEach {
              request.fail(NSError(domain: "test", code: errorCode, userInfo: nil))
            }
            
            it("should call the closures passing an error") {
              for fSentinel in failureSentinels {
                expect((fSentinel as? NSError)?.code).to(equal(errorCode))
              }
            }
            
            it("should not call the closures passing a value") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
            }
            
            context("when calling onCompletion again") {
              var subsequentFailureSentinel: ErrorType?
              var subsequentSuccessSentinel: String?
              
              beforeEach {
                request.onCompletion { value, error in
                  subsequentSuccessSentinel = value
                  if let error = error {
                    subsequentFailureSentinel = error
                  }
                }
              }
              
              it("should immediately call the closure passing an error") {
                expect((subsequentFailureSentinel as? NSError)?.code).to(equal(errorCode))
              }
              
              it("should not immediately call the closure passing a value") {
                expect(subsequentSuccessSentinel).to(beNil())
              }
            }
          }
          
          context("when calling succeed") {
            let value = "success value"
            
            beforeEach {
              request.succeed(value)
            }
            
            it("should call the closures passing a value") {
              expect(successSentinels).to(allPass({ $0! == value }))
            }
            
            it("should not call the closures passing an error") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
            }
            
            context("when calling onCompletion again") {
              var subsequentSuccessSentinel: String?
              var subsequentFailureSentinel: ErrorType?
              
              beforeEach {
                request.onCompletion { result, error in
                  subsequentSuccessSentinel = result
                  if let error = error {
                    subsequentFailureSentinel = error
                  }
                }
              }
              
              it("should immediately call the closure passing a value") {
                expect(subsequentSuccessSentinel).to(equal(value))
              }
              
              it("should not immediately call the closure passing an error") {
                expect(subsequentFailureSentinel).to(beNil())
              }
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