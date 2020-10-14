import Foundation

import Quick
import Nimble

import Carlos
import Combine

enum TestError: Error {
  case anotherError
  case simpleError
}

final class BasicCacheTests: QuickSpec {
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
      var getSubject: PassthroughSubject<Int, Error>!
      var setSubject: PassthroughSubject<Void, Error>!
      
      var cancellable: AnyCancellable?
      
      beforeEach {
        numberOfTimesCalledClear = 0
        numberOfTimesCalledGet = 0
        numberOfTimesCalledOnMemoryWarning = 0
        numberOfTimesCalledSet = 0
        
        getSubject = PassthroughSubject()
        setSubject = PassthroughSubject()
        
        cache = BasicCache<String, Int>(
          getClosure: { key in
            didGetKey = key
            numberOfTimesCalledGet += 1
            
            return getSubject.eraseToAnyPublisher()
          },
          setClosure: { (value, key) in
            didSetKey = key
            didSetValue = value
            numberOfTimesCalledSet += 1
            
            return setSubject.eraseToAnyPublisher()
          },
          clearClosure: {
            numberOfTimesCalledClear += 1
          },
          memoryClosure: {
            numberOfTimesCalledOnMemoryWarning += 1
          }
        )
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
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
          
          cancellable = cache.get(key)
            .handleEvents(receiveCancel: {
              canceled = true
            })
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failed = error
              }
            }, receiveValue: {
              succeeded = $0
            })
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
            getSubject.send(value)
          }
          
          it("should succeed the future") {
            expect(succeeded).to(equal(value))
          }
        }
        
        context("when the get clousure is canceled") {
          beforeEach {
            cancellable?.cancel()
          }
          
          it("should cancel the future") {
            expect(canceled).to(beTrue())
          }
        }
        
        context("when the get closure fails") {
          let error = TestError.anotherError
          
          beforeEach {
            getSubject.send(completion: .failure(error))
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
          
          cancellable = cache.set(value, forKey: key)
            .handleEvents(receiveCancel: {
              canceled = true
            })
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failed = error
              }
            }, receiveValue: {
              succeeded = true
            })
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
            setSubject.send()
          }
          
          it("should succeed the future") {
            expect(succeeded).to(beTrue())
          }
        }
        
        context("when the set clousure is canceled") {
          beforeEach {
            cancellable?.cancel()
          }
          
          it("should cancel the future") {
            expect(canceled).to(beTrue())
          }
        }
        
        context("when the set closure fails") {
          let error = TestError.anotherError
          
          beforeEach {
            setSubject.send(completion: .failure(error))
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
