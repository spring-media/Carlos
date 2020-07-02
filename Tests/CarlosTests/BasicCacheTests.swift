import Foundation
import Quick
import Nimble
@testable import Carlos
import PiedPiper

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
      var getResult: Promise<Int>!
      var setResult: Promise<()>!
      
      beforeEach {
        numberOfTimesCalledClear = 0
        numberOfTimesCalledGet = 0
        numberOfTimesCalledOnMemoryWarning = 0
        numberOfTimesCalledSet = 0
        
        getResult = Promise<Int>()
        setResult = Promise<()>()
        
        cache = BasicCache<String, Int>(
          getClosure: { key in
            didGetKey = key
            numberOfTimesCalledGet += 1
            
            return getResult.future
          },
          setClosure: { (value, key) in
            didSetKey = key
            didSetValue = value
            numberOfTimesCalledSet += 1
            
            return setResult.future
          },
          clearClosure: {
            numberOfTimesCalledClear += 1
          },
          memoryClosure: {
            numberOfTimesCalledOnMemoryWarning += 1
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
          
          cache.get(key)
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
        let key = "test key"
        let value = 101
        var succeeded: Bool!
        var failed: Error?
        var canceled: Bool!
        
        beforeEach {
          succeeded = false
          failed = nil
          canceled = false
          
          cache.set(value, forKey: key)
            .onSuccess { _ in succeeded = true }
            .onFailure { failed = $0 }
            .onCancel { canceled = true }
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
        
        context("when the set closure succeeds") {
          beforeEach {
            setResult.succeed(())
          }
          
          it("should succeed the future") {
            expect(succeeded).to(beTrue())
          }
        }
        
        context("when the set clousure is canceled") {
          beforeEach {
            setResult.cancel()
          }
          
          it("should cancel the future") {
            expect(canceled).to(beTrue())
          }
        }
        
        context("when the set closure fails") {
          let error = TestError.anotherError
          
          beforeEach {
            setResult.fail(error)
          }
          
          it("should fail the future") {
            expect(failed as? TestError).to(equal(error))
          }
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
