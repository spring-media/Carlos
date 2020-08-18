import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

final class NSUserDefaultsCacheLevelTests: QuickSpec {
  override func spec() {
    describe("User defaults cache level") {
      var cache: NSUserDefaultsCacheLevel<String, NSString>!
      var secondCache: NSUserDefaultsCacheLevel<String, NSString>!
      var standardCache: UserDefaults!
      var cancellables: Set<AnyCancellable>!
      
      beforeEach {
        cancellables = Set<AnyCancellable>()
        standardCache = UserDefaults.standard
        cache = NSUserDefaultsCacheLevel(name: "tests")
        secondCache = NSUserDefaultsCacheLevel(name: "fallback")
      }
      
      afterEach {
        cancellables = nil
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
          cache.get(key)
            .sink(receiveCompletion: { completion in
              if case .failure = completion {
                failureSentinel = true
              }
            }, receiveValue: {
              result = $0
            })
            .store(in: &cancellables)
        }
        
        afterEach {
          result = nil
          failureSentinel = nil
        }
        
        it("should fail") {
          expect(failureSentinel).toEventually(beTrue())
        }
        
        it("should not succeed") {
          expect(result).toEventually(beNil())
        }
        
        context("when setting a value for that key") {
          context("when getting the value for another key") {
            let value = "value to set"
            let anotherKey = "test_key_2"
            
            beforeEach {
              cache.set(value as NSString, forKey: key)
                .flatMap {
                  cache.get(anotherKey)
                }
                .sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    result = nil
                    failureSentinel = true
                  }
                }, receiveValue: {
                  result = $0
                })
                .store(in: &cancellables)
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
          didWrite = false
          
          cache.set(value as NSString, forKey: key)
            .sink(receiveCompletion: { _ in }, receiveValue: { didWrite = true })
            .store(in: &cancellables)
          
          secondCache.set(value as NSString, forKey: key)
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
          
          standardCache.set(value, forKey: key)
        }
        
        it("should eventually succeed the set future") {
          expect(didWrite).toEventually(beTrue())
        }
        
        context("when calling get") {
          beforeEach {
            cache.get(key)
              .sink(receiveCompletion: { completion in
                if case .failure = completion {
                  failureSentinel = true
                }
              }, receiveValue: { result = $0 })
              .store(in: &cancellables)
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
          
          context("when calling get") {
            beforeEach {
              cache.set(newValue as NSString, forKey: key)
                .flatMap {
                  return cache.get(key)
                }
                .sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    failureSentinel = true
                  }
                }, receiveValue: {
                  result = $0
                })
                .store(in: &cancellables)
            }
            
            it("should succeed with the overwritten value") {
              expect(result).toEventually(equal(newValue as NSString), timeout: 5)
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
              cache.get(key)
                .sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    failureSentinel = true
                  }
                }, receiveValue: { result = $0 })
                .store(in: &cancellables)
            }
            
            it("should fail") {
              expect(failureSentinel).toEventually(beTrue())
            }
            
            it("should not succeed") {
              expect(result).toEventually(beNil())
            }
          }
          
          context("when calling get on the other cache") {
            beforeEach {
              secondCache.get(key)
                .sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    failureSentinel = true
                  }
                }, receiveValue: { result = $0 })
                .store(in: &cancellables)
            }
            
            it("should not fail") {
              expect(failureSentinel).toEventually(beNil())
            }
            
            it("should succeed") {
              expect(result).toEventuallyNot(beNil())
            }
            
            it("should return the right value") {
              expect(result).toEventually(equal(value as NSString))
            }
          }
          
          context("when calling get on the standard user defaults") {
            beforeEach {
              result = standardCache.object(forKey: key) as? NSString
            }
            
            it("should succeed") {
              expect(result).toEventuallyNot(beNil())
            }
            
            it("should return the right value") {
              expect(result).toEventually(equal(value as NSString))
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
                cache.get(key)
                  .sink(receiveCompletion: { completion in
                    if case .failure = completion {
                      failureSentinel = true
                    }
                  }, receiveValue: { result = $0 })
                  .store(in: &cancellables)
              }
              
              it("should not fail") {
                expect(failureSentinel).toEventually(beNil())
              }
              
              it("should succeed") {
                expect(result).toEventuallyNot(beNil())
              }
              
              it("should return the right value") {
                expect(result).toEventually(equal(value as NSString))
              }
            }
          }
          
          context("when calling get on the other cache") {
            beforeEach {
              secondCache.get(key)
                .sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    failureSentinel = true
                  }
                }, receiveValue: { result = $0 })
                .store(in: &cancellables)
            }
            
            it("should not fail") {
              expect(failureSentinel).toEventually(beNil())
            }
            
            it("should succeed") {
              expect(result).toEventuallyNot(beNil())
            }
            
            it("should return the right value") {
              expect(result).toEventually(equal(value as NSString))
            }
          }
          
          context("when calling get on the standard user defaults") {
            beforeEach {
              result = standardCache.object(forKey: key) as? NSString
            }
            
            it("should succeed") {
              expect(result).toEventuallyNot(beNil())
            }
            
            it("should return the right value") {
              expect(result).toEventually(equal(value as NSString))
            }
          }
        }
      }
    }
  }
}
