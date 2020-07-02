import Foundation
import Quick
import Nimble
@testable import Carlos

class MemoryCacheLevelTests: QuickSpec {
  override func spec() {
    describe("Memory cache level") {
      var cache: MemoryCacheLevel<String, NSString>!
      
      beforeEach {
        cache = MemoryCacheLevel(capacity: 100)
      }
      
      context("when calling get") {
        var result: NSString?
        let key = "test-key"
        var failureSentinel: Bool?
        
        beforeEach {
          cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
        }
        
        it("should fail") {
          expect(failureSentinel).to(beTrue())
        }
        
        it("should not succeed") {
          expect(result).to(beNil())
        }
        
        context("when setting a value for that key") {
          let value = "value to set"
          
          beforeEach {
            failureSentinel = nil
            
            _ = cache.set(value as NSString, forKey: key)
          }
          
          context("when getting the value for another key") {
            let anotherKey = "test_key_2"
            
            beforeEach {
              cache.get(anotherKey).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
            }
            
            it("should not succeed") {
              expect(result).to(beNil())
            }
            
            it("should fail") {
              expect(failureSentinel).notTo(beNil())
            }
          }
        }
      }
      
      context("when calling set") {
        let key = "key"
        let value = "value"
        var result: NSString?
        var failureSentinel: Bool?
        var didWrite: Bool!
        
        beforeEach {
          didWrite = false
          cache.set(value as NSString, forKey: key).onSuccess {
            didWrite = true
          }
        }
        
        it("should immediately succeed the future") {
          expect(didWrite).to(beTrue())
        }
        
        context("when calling get") {
          beforeEach {
            cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
          }
          
          it("should succeed") {
            expect(result).notTo(beNil())
          }
          
          it("should return the right value") {
            expect(result).to(equal(value as NSString))
          }
          
          it("should not fail") {
            expect(failureSentinel).to(beNil())
          }
        }
        
        context("when setting a different value for the same key") {
          let newValue = "another value"
          
          beforeEach {
            _ = cache.set(newValue as NSString, forKey: key)
          }
          
          context("when calling get") {
            beforeEach {
              cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
            }
            
            it("should succeed with the overwritten value") {
              expect(result).to(equal(newValue as NSString))
            }
          }
        }
        
        context("when setting more than its capacity") {
          let otherKeys = ["key1", "key2", "key3"]
          let otherValues = [
            "long string value",
            "even longer string value but should still fit the cache",
            "longest string value that should fill the cache capacity and force it to evict some values"
          ]
          
          beforeEach {
            for (key, value) in zip(otherKeys, otherValues) {
              _ = cache.set(value as NSString, forKey: key)
            }
          }
          
          it("should evict at least one value") {
            var evictedAtLeastOne = false
            
            for key in otherKeys {
              cache.get(key).onFailure({ _ in evictedAtLeastOne = true })
            }
            
            expect(evictedAtLeastOne).to(beTrue())
          }
        }
        
        context("when calling clear") {
          beforeEach {
            result = nil
            
            cache.clear()
          }
          
          context("when calling get") {
            beforeEach {
              cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
            }
            
            it("should fail") {
              expect(failureSentinel).to(beTrue())
            }
            
            it("should not succeed") {
              expect(result).to(beNil())
            }
          }
        }
        
        context("when calling onMemoryWarning") {
          beforeEach {
            result = nil
            
            cache.onMemoryWarning()
          }
          
          context("when calling get") {
            beforeEach {
              beforeEach {
                cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
              }
              
              it("should fail") {
                expect(failureSentinel).to(beTrue())
              }
              
              it("should not succeed") {
                expect(result).to(beNil())
              }
            }
          }
        }
      }
    }
  }
}
