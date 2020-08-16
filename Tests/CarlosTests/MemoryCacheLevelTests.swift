import Foundation
import Quick
import Nimble
import Carlos
import OpenCombine

class MemoryCacheLevelTests: QuickSpec {
  override func spec() {
    describe("Memory cache level") {
      var cache: MemoryCacheLevel<String, NSString>!
      var cancellable: AnyCancellable?
      
      beforeEach {
        cache = MemoryCacheLevel(capacity: 100)
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
        
        cache = nil
      }
      
      context("when calling get") {
        var result: NSString?
        let key = "test-key"
        var failureSentinel: Bool?
        
        beforeEach {
          cancellable = cache.get(key).sink(receiveCompletion: { completion in
            if case .failure = completion {
              failureSentinel = true
            }
          }, receiveValue: { result = $0 })
        }
        
        afterEach {
          failureSentinel = nil
          result = nil
        }
        
        it("should fail") {
          expect(failureSentinel).toEventually(beTrue())
        }
        
        it("should not succeed") {
          expect(result).toEventually(beNil())
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
              cancellable = cache.get(anotherKey).sink(receiveCompletion: { completion in
                if case .failure = completion {
                  failureSentinel = true
                }
              }, receiveValue: { result = $0 })
            }
            
            it("should not succeed") {
              expect(result).toEventually(beNil())
            }
            
            it("should fail") {
              expect(failureSentinel).toEventuallyNot(beNil())
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
          cancellable = cache.set(value as NSString, forKey: key)
            .sink(receiveCompletion: { _ in }, receiveValue: { didWrite = true })
        }
        
        afterEach {
          didWrite = false
          result = nil
          failureSentinel = nil
        }
        
        it("should immediately succeed the future") {
          expect(didWrite).toEventually(beTrue())
        }
        
        context("when calling get") {
          beforeEach {
            cancellable = cache.get(key).sink(receiveCompletion: { completion in
              if case .failure = completion {
                failureSentinel = true
              }
            }, receiveValue: { result = $0 })
          }
          
          it("should succeed") {
            expect(result).toEventuallyNot(beNil())
          }
          
          it("should return the right value") {
            expect(result).toEventually(equal(value as NSString))
          }
          
          it("should not fail") {
            expect(failureSentinel).toEventually(beNil())
          }
        }
        
        context("when setting a different value for the same key") {
          let newValue = "another value"
          
          beforeEach {
            _ = cache.set(newValue as NSString, forKey: key)
          }
          
          context("when calling get") {
            beforeEach {
              cancellable = cache.get(key).sink(receiveCompletion: { completion in
                if case .failure = completion {
                  failureSentinel = true
                }
              }, receiveValue: { result = $0 })
            }
            
            it("should succeed with the overwritten value") {
              expect(result).toEventually(equal(newValue as NSString))
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
              cancellable = cache.get(key).sink(receiveCompletion: { completion in
                if case .failure = completion {
                  evictedAtLeastOne = true
                }
              }, receiveValue: { _ in })
            }
            
            expect(evictedAtLeastOne).toEventually(beTrue())
          }
        }
        
        context("when calling clear") {
          beforeEach {
            result = nil
            
            cache.clear()
          }
          
          context("when calling get") {
            beforeEach {
              cancellable = cache.get(key).sink(receiveCompletion: { completion in
                if case .failure = completion {
                  failureSentinel = true
                }
              }, receiveValue: { result = $0 })
            }
            
            it("should fail") {
              expect(failureSentinel).toEventually(beTrue())
            }
            
            it("should not succeed") {
              expect(result).toEventually(beNil())
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
                cancellable = cache.get(key).sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    failureSentinel = true
                  }
                }, receiveValue: { result = $0 })
              }
              
              it("should fail") {
                expect(failureSentinel).toEventually(beTrue())
              }
              
              it("should not succeed") {
                expect(result).toEventually(beNil())
              }
            }
          }
        }
      }
    }
  }
}
