import Foundation
import Quick
import Nimble
import Carlos

class MemoryCacheLevelTests: QuickSpec {
  override func spec() {
    describe("Memory cache level") {
      var cache: MemoryCacheLevel<NSString>!
      
      beforeEach {
        cache = MemoryCacheLevel<NSString>()
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
            
            cache.set(value, forKey: key)
          }
         
          context("when getting the value for another key") {
            beforeEach {
              cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
            }
            
            it("should succeed") {
              expect(result).to(equal(value))
            }
            
            it("should not fail") {
              expect(failureSentinel).to(beNil())
            }
          }
        }
      }
      
      context("when calling set") {
        let key = "key"
        let value = "value"
        var result: NSString?
        var failureSentinel: Bool?
        
        beforeEach {
          cache.set(value, forKey: key)
        }
        
        context("when calling get") {
          beforeEach {
            cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
          }
          
          it("should succeed") {
            expect(result).to(equal(value))
          }
          
          it("should not fail") {
            expect(failureSentinel).to(beNil())
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