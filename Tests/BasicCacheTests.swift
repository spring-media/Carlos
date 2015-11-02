import Foundation
import Quick
import Nimble
import Carlos

class BasicCacheTests: QuickSpec {
  override func spec() {
    describe("BasicCache") {
      var cache: BasicCache<String, Int>!
      var numberOfTimesCalledClear = 0
      var numberOfTimesCalledOnMemoryWarning = 0
      var numberOfTimesCalledGet = 0
      var numberOfTimesCalledSet = 0
      var didSetKey: String?
      var didSetValue: Int?
      var didGetKey: String?
      var fakeRequest: Promise<Int>!
      
      beforeEach {
        numberOfTimesCalledClear = 0
        numberOfTimesCalledGet = 0
        numberOfTimesCalledOnMemoryWarning = 0
        numberOfTimesCalledSet = 0
        
        fakeRequest = Promise<Int>()
        
        cache = BasicCache<String, Int>(
          getClosure: { key in
            didGetKey = key
            numberOfTimesCalledGet++
            
            return fakeRequest
          },
          setClosure: { (value, key) in
            didSetKey = key
            didSetValue = value
            numberOfTimesCalledSet++
          },
          clearClosure: {
            numberOfTimesCalledClear++
          },
          memoryClosure: {
            numberOfTimesCalledOnMemoryWarning++
          }
        )
      }
      
      context("when calling perform") {
        let key = "key to test"
        var request: Promise<Int>!
        
        beforeEach {
          request = cache.perform(key)
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
        var request: Promise<Int>!
        
        beforeEach {
          request = cache.get(key)
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
      
      context("when calling set") {
        let key = "test key"
        let value = 101
        
        beforeEach {
          cache.set(value, forKey: key)
        }
        
        it("should call the closure") {
          expect(numberOfTimesCalledSet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(didSetKey).to(equal(key))
        }
        
        it("should pass the right value") {
          expect(didSetValue).to(equal(value))
        }
      }
      
      context("when calling clear") {
        beforeEach {
          cache.clear()
        }
        
        it("should call the closure") {
          expect(numberOfTimesCalledClear).to(equal(1))
        }
      }
      
      context("when calling onMemoryWarning") {
        beforeEach {
          cache.onMemoryWarning()
        }
        
        it("should call the closure") {
          expect(numberOfTimesCalledOnMemoryWarning).to(equal(1))
        }
      }
    }
  }
}