import Foundation
import Quick
import Nimble
import Carlos

class NSUserDefaultsCacheLevelTests: QuickSpec {
  override func spec() {
    describe("User defaults cache level") {
      var cache: NSUserDefaultsCacheLevel<String, NSString>!
      var secondCache: NSUserDefaultsCacheLevel<String, NSString>!
      var standardCache: NSUserDefaults!
      
      beforeEach {
        standardCache = NSUserDefaults.standardUserDefaults()
        cache = NSUserDefaultsCacheLevel(name: "tests")
        secondCache = NSUserDefaultsCacheLevel(name: "fallback")
      }
      
      afterSuite {
        cache.clear()
        secondCache.clear()
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
          cache.set(value, forKey: key).onSuccess {
            didWrite = true
          }
          secondCache.set(value, forKey: key)
          standardCache.setObject(value, forKey: key)
        }
        
        it("should eventually succeed the set future") {
          expect(didWrite).toEventually(beTrue())
        }
        
        context("when calling get") {
          beforeEach {
            cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
          }
          
          it("should succeed") {
            expect(result).notTo(beNil())
          }
          
          it("should return the right value") {
            expect(result).to(equal(value))
          }
          
          it("should not fail") {
            expect(failureSentinel).to(beNil())
          }
        }
        
        context("when setting a different value for the same key") {
          let newValue = "another value"
          
          beforeEach {
            cache.set(newValue, forKey: key)
          }
          
          context("when calling get") {
            beforeEach {
              cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
            }
            
            it("should succeed with the overwritten value") {
              expect(result).to(equal(newValue))
            }
          }
        }
        
        context("when calling clear") {
          beforeEach {
            failureSentinel = nil
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
          
          context("when calling get on the other cache") {
            beforeEach {
              secondCache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
            }
            
            it("should not fail") {
              expect(failureSentinel).to(beNil())
            }
            
            it("should succeed") {
              expect(result).notTo(beNil())
            }
            
            it("should return the right value") {
              expect(result).to(equal(value))
            }
          }
          
          context("when calling get on the standard user defaults") {
            beforeEach {
              result = standardCache.objectForKey(key) as? String
            }
            
            it("should succeed") {
              expect(result).notTo(beNil())
            }
            
            it("should return the right value") {
              expect(result).to(equal(value))
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
              
              it("should not fail") {
                expect(failureSentinel).to(beNil())
              }
              
              it("should succeed") {
                expect(result).notTo(beNil())
              }
              
              it("should return the right value") {
                expect(result).to(equal(value))
              }
            }
          }
          
          context("when calling get on the other cache") {
            beforeEach {
              secondCache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
            }
            
            it("should not fail") {
              expect(failureSentinel).to(beNil())
            }
            
            it("should succeed") {
              expect(result).notTo(beNil())
            }
            
            it("should return the right value") {
              expect(result).to(equal(value))
            }
          }
          
          context("when calling get on the standard user defaults") {
            beforeEach {
              result = standardCache.objectForKey(key) as? String
            }
            
            it("should succeed") {
              expect(result).notTo(beNil())
            }
            
            it("should return the right value") {
              expect(result).to(equal(value))
            }
          }
        }
      }
    }
  }
}