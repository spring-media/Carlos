import Foundation
import Quick
import Nimble
import PiedPiper

internal enum TestError: Error {
  case simpleError
  case anotherError
}

struct FutureSharedExamplesContext {
  static let Future = "future"
  static let Promise = "promise"
  static let Value = "value"
}

class FutureSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("failure case") { (sharedExampleContext: @escaping SharedExampleContext) in
      var request: Future<String>!
      var successSentinels: [String?]!
      var failureSentinels: [Error?]!
      var cancelSentinels: [Bool?]!
      
      beforeEach {
        request = sharedExampleContext()[FutureSharedExamplesContext.Future] as? Future<String>
        
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
          expect(successSentinels.filter({ $0 == nil }).count).toEventually(equal(successSentinels.count))
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
          expect(failureSentinels.filter({ $0 != nil }).count).toEventually(equal(failureSentinels.count))
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
          expect(cancelSentinels.filter({ $0 == nil}).count).toEventually(equal(cancelSentinels.count))
        }
      }
      
      context("when calling onCompletion") {
        beforeEach {
          for idx in 0..<successSentinels.count {
            request.onCompletion { result in
              switch result {
              case .success(let value):
                successSentinels[idx] = value
              case .error(let error):
                failureSentinels[idx] = error
              default:
                break
              }
            }
          }
        }
        
        it("should immediately call the closures") {
          expect(failureSentinels.filter({ $0 != nil }).count).toEventually(equal(failureSentinels.count))
        }
        
        it("should not pass a value") {
          expect(successSentinels.filter({ $0 == nil }).count).toEventually(equal(successSentinels.count))
        }
      }
    }
    
    sharedExamples("success case") { (sharedExampleContext: @escaping SharedExampleContext) in
      var request: Future<String>!
      var value: String!
      var successSentinels: [String?]!
      var failureSentinels: [Error?]!
      var cancelSentinels: [Bool?]!
      
      beforeEach {
        request = sharedExampleContext()[FutureSharedExamplesContext.Future] as? Future<String>
        value = sharedExampleContext()[FutureSharedExamplesContext.Value] as? String
        
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
          expect(successSentinels.filter({ $0 != nil }).count).toEventually(equal(successSentinels.count))
        }
        
        it("should pass the right value") {
          expect(successSentinels).toEventually(allPass({ $0! == value }))
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
          expect(cancelSentinels.filter({ $0 == nil}).count).toEventually(equal(cancelSentinels.count))
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
          expect(failureSentinels.filter({ $0 == nil }).count).toEventually(equal(failureSentinels.count))
        }
      }
      
      context("when calling onCompletion") {
        beforeEach {
          for idx in 0..<successSentinels.count {
            request.onCompletion { result in
              switch result {
              case .success(let value):
                successSentinels[idx] = value
              case .error(let error):
                failureSentinels[idx] = error
              default:
                break
              }
            }
          }
        }
        
        it("should not call the closures passing an error") {
          expect(failureSentinels.filter({ $0 == nil }).count).toEventually(equal(failureSentinels.count))
        }
        
        it("should call the closures passing a value") {
          expect(successSentinels).toEventually(allPass({ $0! == value }))
        }
      }
    }
    
    sharedExamples("a Future") { (sharedExampleContext: @escaping SharedExampleContext) in
      var future: Future<String>!
      var promise: Promise<String>!
      var successSentinel: String?
      var errorSentinel: Error?
      var cancelSentinel = false
      var completionValueSentinel: String?
      var completionErrorSentinel: Error?
      var completionWasCalled = false
      
      beforeEach {
        successSentinel = nil
        errorSentinel = nil
        cancelSentinel = false
        completionWasCalled = false
        completionErrorSentinel = nil
        completionValueSentinel = nil
        
        future = sharedExampleContext()[FutureSharedExamplesContext.Future] as? Future<String>
        promise = sharedExampleContext()[FutureSharedExamplesContext.Promise] as? Promise<String>
        
        future
          .onSuccess { value in
            successSentinel = value
          }
          .onFailure { error in
            errorSentinel = error
          }
          .onCancel {
            cancelSentinel = true
          }
          .onCompletion { result in
            completionWasCalled = true
            
            switch result {
            case .success(let value):
              completionValueSentinel = value
            case .error(let error):
              completionErrorSentinel = error
            default:
              break
            }
          }
      }
      
      context("when the promise succeeds") {
        let value = "this is a success value"
        
        beforeEach {
          promise.succeed(value)
        }
        
        it("should call the completion closure") {
          expect(completionWasCalled).to(beTrue())
        }
        
        it("should pass the right value") {
          expect(completionValueSentinel).to(equal(value))
        }
        
        it("should not pass any error") {
          expect(completionErrorSentinel).to(beNil())
        }
        
        it("should not call the error closure") {
          expect(errorSentinel).to(beNil())
        }
        
        it("should call the success closure") {
          expect(successSentinel).notTo(beNil())
        }
        
        it("should pass the right value") {
          expect(successSentinel).to(equal(value))
        }
        
        it("should not call the cancel closure") {
          expect(cancelSentinel).to(beFalse())
        }
      }
      
      context("when the promise fails") {
        let error = TestError.anotherError
        
        beforeEach {
          promise.fail(error)
        }
        
        it("should call the completion closure") {
          expect(completionWasCalled).to(beTrue())
        }
        
        it("should not pass any value") {
          expect(completionValueSentinel).to(beNil())
        }
        
        it("should pass the right error") {
          expect(completionErrorSentinel as? TestError).to(equal(error))
        }
        
        it("should call the error closure") {
          expect(errorSentinel).notTo(beNil())
        }
        
        it("should pass the right error") {
          expect(errorSentinel as? TestError).to(equal(error))
        }
        
        it("should not call the success closure") {
          expect(successSentinel).to(beNil())
        }
        
        it("should not call the cancel closure") {
          expect(cancelSentinel).to(beFalse())
        }
      }
      
      context("when the promise is canceled") {
        beforeEach {
          promise.cancel()
        }
        
        it("should call the completion closure") {
          expect(completionWasCalled).to(beTrue())
        }
        
        it("should not pass any value") {
          expect(completionValueSentinel).to(beNil())
        }
        
        it("should not pass any error") {
          expect(completionErrorSentinel).to(beNil())
        }
        
        it("should not call the error closure") {
          expect(errorSentinel).to(beNil())
        }
        
        it("should not call the success closure") {
          expect(successSentinel).to(beNil())
        }
        
        it("should call the cancel closure") {
          expect(cancelSentinel).to(beTrue())
        }
      }
      
      context("when the future is canceled") {
        beforeEach {
          future.cancel()
        }
        
        it("should call the completion closure") {
          expect(completionWasCalled).to(beTrue())
        }
        
        it("should not pass any value") {
          expect(completionValueSentinel).to(beNil())
        }
        
        it("should not pass any error") {
          expect(completionErrorSentinel).to(beNil())
        }
        
        it("should not call the error closure") {
          expect(errorSentinel).to(beNil())
        }
        
        it("should not call the success closure") {
          expect(successSentinel).to(beNil())
        }
        
        it("should call the cancel closure") {
          expect(cancelSentinel).to(beTrue())
        }
      }
    }
  }
}

class FutureTests: QuickSpec {
  override func spec() {
    describe("Future") {
      var future: Future<String>!
      var associatedPromise: Promise<String>!
      
      context("when obtained through a promise") {
        beforeEach {
          associatedPromise = Promise<String>()
          future = associatedPromise.future
        }
        
        itBehavesLike("a Future") {
          [
            FutureSharedExamplesContext.Future: future,
            FutureSharedExamplesContext.Promise: associatedPromise
          ]
        }
      }
      
      context("when initialized with a closure") {
        context("when the closure returns a value") {
          let value = "Hi!"
          
          beforeEach {
            future = Future {
              value
            }
          }
          
          itBehavesLike("success case") {
            [
              FutureSharedExamplesContext.Future: future,
              FutureSharedExamplesContext.Value: value
            ]
          }
        }
        
        context("when the closure returns nil") {
          beforeEach {
            future = Future {
              nil
            }
          }
          
          itBehavesLike("failure case") {
            [
              FutureSharedExamplesContext.Future: future
            ]
          }
        }
      }
      
      context("when initialized with a value") {
        let value = "this is a sync success value"

        beforeEach {
          future = Future(value)
        }

        itBehavesLike("success case") {
          [
            FutureSharedExamplesContext.Future: future,
            FutureSharedExamplesContext.Value: value
          ]
        }
      }
      
      context("when initialized with an optional value and an error") {
        context("when the optional value is nil") {
          beforeEach {
            future = Future(value: nil, error: TestError.simpleError)
          }

          itBehavesLike("failure case") {
            [
              FutureSharedExamplesContext.Future: future
            ]
          }
        }

        context("when the optional value is not nil") {
          let value = "this is a sync success value"

          beforeEach {
            future = Future(value: value, error: TestError.simpleError)
          }

          itBehavesLike("success case") {
            [
              FutureSharedExamplesContext.Future: future,
              FutureSharedExamplesContext.Value: value
            ]
          }
        }
      }

      context("when initialized with an error") {
        let error = TestError.simpleError
        
        beforeEach {
          future = Future<String>(error)
        }
      
        itBehavesLike("failure case") {
          [
            FutureSharedExamplesContext.Future: future
          ]
        }
      }
    }
  }
}
