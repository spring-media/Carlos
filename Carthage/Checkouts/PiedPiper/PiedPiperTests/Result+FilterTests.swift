import Quick
import Nimble
import PiedPiper

class ResultFilterTests: QuickSpec {
  override func spec() {
    describe("Filtering a Result") {
      var original: Result<Int>!
      var filteredResult: Result<Int>!
     
      context("when done through a simple closure") {
        let filteringClosure: (Int) -> Bool = { num in
          num > 0
        }
        
        context("when the original result is error") {
          let error = TestError.simpleError
          
          beforeEach {
            original = .error(error)
            
            filteredResult = original.filter(filteringClosure)
          }
          
          it("should also fail the filtered result") {
            var didFail = false
            
            if case .some(.error) = filteredResult {
              didFail = true
            }
            
            expect(didFail).to(beTrue())
          }
          
          it("should fail the filtered result with the same error") {
            var actualError: Error?
            
            if case .some(.error(let error)) = filteredResult {
              actualError = error
            }
            
            expect(actualError as? TestError).to(equal(error))
          }
        }
        
        context("when the original result is canceled") {
          beforeEach {
            original = .cancelled
            
            filteredResult = original.filter(filteringClosure)
          }
          
          it("should also cancel the filtered result") {
            var wasCanceled = false
            
            if case .some(.cancelled) = filteredResult {
              wasCanceled = true
            }
            
            expect(wasCanceled).to(beTrue())
          }
        }
        
        context("when the original result is success") {
          context("when the success value satisfies the condition") {
            let result = 20
            
            beforeEach {
              original = .success(result)
              filteredResult = original.filter(filteringClosure)
            }
            
            it("should also succeed the filtered result") {
              var didSucceed = false
              
              if case .some(.success) = filteredResult {
                didSucceed = true
              }
              
              expect(didSucceed).to(beTrue())
            }
            
            it("should succeed the filtered result with the original value") {
              var successValue: Int?
              
              if case .some(.success(let value)) = filteredResult {
                successValue = value
              }
              
              expect(successValue).to(equal(result))
            }
          }
          
          context("when the success value doesn't satisfy the condition") {
            let result = -20
            
            beforeEach {
              original = .success(result)
              filteredResult = original.filter(filteringClosure)
            }
            
            it("should fail the filtered result") {
              var didFail = false
              
              if case .some(.error) = filteredResult {
                didFail = true
              }
              
              expect(didFail).to(beTrue())
            }
            
            it("should fail the filtered result with the right error") {
              var error: Error?
              
              if case .some(.error(let err)) = filteredResult {
                error = err
              }
              
              expect(error as? ResultFilteringError).to(equal(ResultFilteringError.conditionUnsatisfied))
            }
          }
        }
      }
    }
  }
}
