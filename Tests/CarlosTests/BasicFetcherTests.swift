import Foundation
import Quick
import Nimble
import Carlos
import PiedPiper

class BasicFetcherTests: QuickSpec {
  override func spec() {
    describe("BasicFetcher") {
      var fetcher: BasicFetcher<String, Int>!
      var numberOfTimesCalledGet = 0
      var didGetKey: String?
      var getResult: Promise<Int>!
      
      beforeEach {
        numberOfTimesCalledGet = 0
        getResult = Promise<Int>()
        
        fetcher = BasicFetcher<String, Int>(
          getClosure: { key in
            didGetKey = key
            numberOfTimesCalledGet += 1
            
            return getResult.future
          }
        )
      }
      
      context("when calling get") {
        let key = "key to test"
        var succeeded: Int?
        var failed: Error?
        var canceled: Bool!
        
        beforeEach {
          canceled = false
          failed = nil
          succeeded = nil
          
          fetcher.get(key)
            .onSuccess { succeeded = $0 }
            .onFailure { failed = $0 }
            .onCancel { canceled = true }
        }
        
        it("should call the closure") {
          expect(numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(didGetKey).to(equal(key))
        }
        
        context("when the get closure succeeds") {
          let value = 3
          
          beforeEach {
            getResult.succeed(value)
          }
          
          it("should succeed the future") {
            expect(succeeded).to(equal(value))
          }
        }
        
        context("when the get clousure is canceled") {
          beforeEach {
            getResult.cancel()
          }
          
          it("should cancel the future") {
            expect(canceled).to(beTrue())
          }
        }
        
        context("when the get closure fails") {
          let error = TestError.anotherError
          
          beforeEach {
            getResult.fail(error)
          }
          
          it("should fail the future") {
            expect(failed as? TestError).to(equal(error))
          }
        }
      }
      
      context("when calling set") {
        var succeeded: Bool!
        
        beforeEach {
          succeeded = false
          
          fetcher.set(0, forKey: "").onSuccess { _ in succeeded = true }
        }
        
        it("should immediately succeed the future") {
          expect(succeeded).to(beTrue())
        }
      }
    }
  }
}
