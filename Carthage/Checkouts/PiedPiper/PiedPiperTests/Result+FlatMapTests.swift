import Quick
import Nimble
import PiedPiper

class ResultFlatMapTests: QuickSpec {
  override func spec() {
    describe("FlatMapping a Result") {
      var result: Result<String>!
      var mappedResult: Result<Int>!
      
      context("when done through a closure that can return nil") {
        let mappingClosure: (String) -> Int? = { str in
          if str == "nil" {
            return nil
          } else {
            return 1
          }
        }
        
        context("when the original Result fails") {
          let error = TestError.simpleError
          
          beforeEach {
            result = .error(error)
            mappedResult = result.flatMap(mappingClosure)
          }
          
          it("should also fail the mapped Result") {
            var failureValue: Error?
            
            if case .some(.error(let error)) = mappedResult {
              failureValue = error
            }
            
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail the mapped Result with the same error") {
            var failureValue: Error?
            
            if case .some(.error(let error)) = mappedResult {
              failureValue = error
            }
            
            expect(failureValue as? TestError).to(equal(error))
          }
        }
        
        context("when the original Result is canceled") {
          beforeEach {
            result = .cancelled
            mappedResult = result.flatMap(mappingClosure)
          }
          
          it("should also cancel the mapped Result") {
            var wasCanceled = false
            
            if case .some(.cancelled) = mappedResult {
              wasCanceled = true
            }
            
            expect(wasCanceled).to(beTrue())
          }
        }
        
        context("when the original Result is .Success") {
          context("when the closure doesn't return nil") {
            let value = "Eureka!"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.flatMap(mappingClosure)
            }
            
            it("should also succeed the mapped Result") {
              var successValue: Int?
              
              if case .some(.success(let value)) = mappedResult {
                successValue = value
              }
              
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the mapped Result with the mapped value") {
              var successValue: Int?
              
              if case .some(.success(let value)) = mappedResult {
                successValue = value
              }
            
              expect(successValue).to(equal(mappingClosure(value)))
            }
          }
          
          context("when the closure returns nil") {
            let value = "nil"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.flatMap(mappingClosure)
            }
            
            it("should fail the mapped Result") {
              var failureValue: Error?
              
              if case .some(.error(let error)) = mappedResult {
                failureValue = error
              }
              
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the mapped Result with the right error") {
              var failureValue: Error?
              
              if case .some(.error(let error)) = mappedResult {
                failureValue = error
              }
              
              expect(failureValue as? ResultMappingError).to(equal(ResultMappingError.cantMapValue))
            }
          }
        }
      }
      
      context("when done through a closure that returns a Result") {
        let mappingClosure: (String) -> Result<Int> = { str in
          if str == "cancel" {
            return Result.cancelled
          } else if str == "failure" {
            return Result.error(TestError.simpleError)
          } else {
            return Result.success(1)
          }
        }
        
        context("when the original Result fails") {
          let error = TestError.simpleError
          
          beforeEach {
            result = .error(error)
            mappedResult = result.flatMap(mappingClosure)
          }
          
          it("should also fail the mapped Result") {
            var failureValue: Error?
            
            if case .some(.error(let error)) = mappedResult {
              failureValue = error
            }
            
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail the mapped Result with the same error") {
            var failureValue: Error?
            
            if case .some(.error(let error)) = mappedResult {
              failureValue = error
            }
            
            expect(failureValue as? TestError).to(equal(error))
          }
        }
        
        context("when the original Result is canceled") {
          beforeEach {
            result = .cancelled
            mappedResult = result.flatMap(mappingClosure)
          }
          
          it("should also cancel the mapped Result") {
            var wasCanceled = false
            
            if case .some(.cancelled) = mappedResult {
              wasCanceled = true
            }
            
            expect(wasCanceled).to(beTrue())
          }
        }
        
        context("when the original Result succeeds") {
          context("when the closure returns a success") {
            let value = "Eureka!"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.flatMap(mappingClosure)
            }
            
            it("should also succeed the mapped Result") {
              var successValue: Int?
              
              if case .some(.success(let value)) = mappedResult {
                successValue = value
              }
              
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the mapped Result with the right value") {
              var successValue: Int?
              
              if case .some(.success(let value)) = mappedResult {
                successValue = value
              }
              
              expect(successValue).to(equal(1))
            }
          }
          
          context("when the closure returns a failure") {
            let value = "failure"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.flatMap(mappingClosure)
            }
            
            it("should fail the mapped Result") {
              var failureValue: Error?
              
              if case .some(.error(let error)) = mappedResult {
                failureValue = error
              }
              
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the mapped Result with the right error") {
              var failureValue: Error?
              
              if case .some(.error(let error)) = mappedResult {
                failureValue = error
              }
              
              expect(failureValue as? TestError).to(equal(TestError.simpleError))
            }
          }
          
          context("when the closure returns a cancelled result") {
            let value = "cancel"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.flatMap(mappingClosure)
            }
            
            it("should cancel the mapped Result") {
              var wasCanceled = false
              
              if case .some(.cancelled) = mappedResult {
                wasCanceled = true
              }
              
              expect(wasCanceled).to(beTrue())
            }
          }
        }
      }
      
      context("when done through a closure that returns a Future") {
        var mappedResult: Future<Int>!
        var wasCanceled: Bool!
        var failureValue: Error?
        var successValue: Int?
        
        beforeEach {
          wasCanceled = nil
          failureValue = nil
          successValue = nil
        }
        
        let mappingClosure: (String) -> Future<Int> = { str in
          let result: Future<Int>
          
          if str == "cancel" {
            let intermediate = Promise<Int>()
            intermediate.cancel()
            result = intermediate.future
          } else if str == "failure" {
            result = Future(TestError.simpleError)
          } else {
            result = Future(1)
          }
          
          return result
        }
        
        context("when the original Result fails") {
          let error = TestError.simpleError
          
          beforeEach {
            result = .error(error)
            mappedResult = result.flatMap(mappingClosure)
            
            mappedResult
              .onSuccess {
                successValue = $0
              }.onFailure {
                failureValue = $0
              }.onCancel {
                wasCanceled = true
            }
          }
          
          it("should not succeed the mapped Result") {
            expect(successValue).to(beNil())
          }
          
          it("should fail the mapped Result") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail the mapped Result with the same error") {
            expect(failureValue as? TestError).to(equal(error))
          }
          
          it("should not cancel the mapped Result") {
            expect(wasCanceled).to(beNil())
          }
        }
        
        context("when the original Result is canceled") {
          beforeEach {
            result = .cancelled
            mappedResult = result.flatMap(mappingClosure)
            
            mappedResult
              .onSuccess {
                successValue = $0
              }.onFailure {
                failureValue = $0
              }.onCancel {
                wasCanceled = true
            }
          }
          
          it("should not succeed the mapped Result") {
            expect(successValue).to(beNil())
          }
          
          it("should not fail the mapped Result") {
            expect(failureValue).to(beNil())
          }
          
          it("should cancel the mapped Result") {
            expect(wasCanceled).to(beTrue())
          }
        }
        
        context("when the original Result is .Success") {
          context("when the closure returns a success") {
            let value = "Eureka!"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.flatMap(mappingClosure)
              
              mappedResult
                .onSuccess {
                  successValue = $0
                }.onFailure {
                  failureValue = $0
                }.onCancel {
                  wasCanceled = true
                }
            }
            
            it("should also succeed the mapped Result") {
              expect(successValue).notTo(beNil())
            }
            
            it("should succeed the mapped Result with the right value") {
              expect(successValue).to(equal(1))
            }
            
            it("should not fail the mapped Result") {
              expect(failureValue).to(beNil())
            }
            
            it("should not cancel the mapped Result") {
              expect(wasCanceled).to(beNil())
            }
          }
          
          context("when the closure returns a failure") {
            let value = "failure"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.flatMap(mappingClosure)
              
              mappedResult
                .onSuccess {
                  successValue = $0
                }.onFailure {
                  failureValue = $0
                }.onCancel {
                  wasCanceled = true
              }
            }
            
            it("should not succeed the mapped Result") {
              expect(successValue).to(beNil())
            }
            
            it("should fail the mapped Result") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the mapped Result with the right error") {
              expect(failureValue as? TestError).to(equal(TestError.simpleError))
            }
            
            it("should not cancel the mapped Result") {
              expect(wasCanceled).to(beNil())
            }
          }
          
          context("when the closure returns a cancelled future") {
            let value = "cancel"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.flatMap(mappingClosure)
              
              mappedResult
                .onSuccess {
                  successValue = $0
                }.onFailure {
                  failureValue = $0
                }.onCancel {
                  wasCanceled = true
              }
            }
            
            it("should not succeed the mapped Result") {
              expect(successValue).to(beNil())
            }
            
            it("should not fail the mapped Result") {
              expect(failureValue).to(beNil())
            }
            
            it("should cancel the mapped Result") {
              expect(wasCanceled).to(beTrue())
            }
          }
        }
      }
    }
  }
}
