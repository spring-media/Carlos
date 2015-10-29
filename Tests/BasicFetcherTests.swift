import Foundation
import Quick
import Nimble
import Carlos

class BasicFetcherTests: QuickSpec {
  override func spec() {
    describe("BasicFetcher") {
      var fetcher: BasicFetcher<String, Int>!
      var numberOfTimesCalledGet = 0
      var didGetKey: String?
      var fakeRequest: Result<Int>!
      
      beforeEach {
        numberOfTimesCalledGet = 0
        fakeRequest = Result<Int>()
        
        fetcher = BasicFetcher<String, Int>(
          getClosure: { key in
            didGetKey = key
            numberOfTimesCalledGet++
            
            return fakeRequest
          }
        )
      }
      
      context("when calling perform") {
        let key = "key to test"
        var request: Result<Int>!
        
        beforeEach {
          request = fetcher.perform(key)
        }
        
        it("should call the closure") {
          expect(numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(didGetKey).to(equal(key))
        }
        
        it("should not modify the request") {
          expect(request).to(beIdenticalTo(fakeRequest))
        }
      }
      
      context("when calling get") {
        let key = "key to test"
        var request: Result<Int>!
        
        beforeEach {
          request = fetcher.get(key)
        }
        
        it("should call the closure") {
          expect(numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(didGetKey).to(equal(key))
        }
        
        it("should not modify the request") {
          expect(request).to(beIdenticalTo(fakeRequest))
        }
      }
    }
  }
}