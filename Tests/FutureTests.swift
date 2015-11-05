import Foundation
import Quick
import Nimble
import Carlos

struct FutureSharedExamplesContext {
  static let Future = "future"
  static let Promise = "promise"
}

class FutureSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a Future") { (sharedExampleContext: SharedExampleContext) in
      var future: Future<String>!
      var promise: Promise<String>!
      var successSentinel: String?
      var errorSentinel: ErrorType?
      var cancelSentinel = false
      var completionValueSentinel: String?
      var completionErrorSentinel: ErrorType?
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
          .onCompletion { value, error in
            completionWasCalled = true
            completionValueSentinel = value
            completionErrorSentinel = error
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
        let error = TestError.AnotherError
        
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
  }
}