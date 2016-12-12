import Quick
import Nimble
import PiedPiper

class ResultMapTests: QuickSpec {
  override func spec() {
    describe("Mapping a Result") {
      var result: Result<String>!
      var mappedResult: Result<Int>!
      
      context("when done through a simple closure") {
        let mappingClosure: (String) -> Int = { str in
          return 1
        }
        
        context("when the original Result is an error") {
          let error = TestError.simpleError
          
          beforeEach {
            result = .error(error)
            mappedResult = result.map(mappingClosure)
          }
          
          it("should also fail the mapped result") {
            var sentinel = false
            
            if case .some(.error) = mappedResult {
              sentinel = true
            }
            
            expect(sentinel).to(beTrue())
          }
          
          it("should fail the mapped result with the same error") {
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
            mappedResult = result.map(mappingClosure)
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
          let value = "Eureka!"
          
          beforeEach {
            result = .success(value)
            mappedResult = result.map(mappingClosure)
          }
          
          it("should also succeed the mapped Result") {
            var successValue: Int?
            
            if case .some(.success(let value)) = mappedResult {
              successValue = value
            }
            
            expect(successValue).notTo(beNil())
          }
          
          it("should succeed the mapped future with the mapped value") {
            var successValue: Int?
            
            if case .some(.success(let value)) = mappedResult {
              successValue = value
            }
            
            expect(successValue).to(equal(mappingClosure(value)))
          }
        }
      }
      
      context("when done through a closure that can throw") {
        let mappingClosure: (String) throws -> Int = { str in
          if str == "throw" {
            throw TestError.anotherError
          } else {
            return 1
          }
        }
        
        context("when the original Result is an error") {
          let error = TestError.simpleError
          
          beforeEach {
            result = .error(error)
            mappedResult = result.map(mappingClosure)
          }
          
          it("should also fail the mapped result") {
            var sentinel = false
            
            if case .some(.error) = mappedResult {
              sentinel = true
            }
            
            expect(sentinel).to(beTrue())
          }
          
          it("should fail the mapped result with the same error") {
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
            mappedResult = result.map(mappingClosure)
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
          context("when the closure doesn't throw") {
            let value = "Eureka!"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.map(mappingClosure)
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
              
              expect(successValue).to(equal(try! mappingClosure(value)))
            }
          }
          
          context("when the closure throws") {
            let value = "throw"
            
            beforeEach {
              result = .success(value)
              mappedResult = result.map(mappingClosure)
            }
            
            it("should fail the mapped Result") {
              var failureValue: Error?
              
              if case .some(.error(let error)) = mappedResult {
                failureValue = error
              }
              
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail the mapped future with the right error") {
              var failureValue: Error?
              
              if case .some(.error(let error)) = mappedResult {
                failureValue = error
              }
              
              expect(failureValue as? TestError).to(equal(TestError.anotherError))
            }
          }
        }
      }
    }
  }
}
