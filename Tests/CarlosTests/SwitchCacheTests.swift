import Foundation

import Nimble
import Quick

import Carlos
import Combine

let switchClosure: (String) -> CacheLevelSwitchResult = { str in
  if str.count > 5 {
    return .cacheA
  } else {
    return .cacheB
  }
}

struct SwitchCacheSharedExamplesContext {
  static let CacheA = "cacheA"
  static let CacheB = "cacheB"
  static let CacheToTest = "sutCache"
}

final class SwitchCacheSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_: Configuration) {
    sharedExamples("should correctly get") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      var cancellables: Set<AnyCancellable>!

      beforeEach {
        cancellables = Set()

        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }

      afterEach {
        cancellables = nil
      }

      context("when calling get") {
        var fakeRequest: PassthroughSubject<Int, Error>!
        var successValue: Int?
        var errorValue: Error?

        beforeEach {
          fakeRequest = PassthroughSubject()
          cacheA.getSubject = fakeRequest
          cacheB.getSubject = fakeRequest

          successValue = nil
          errorValue = nil
        }

        context("when the switch closure returns cacheA") {
          let key = "quite long key"

          beforeEach {
            finalCache.get(key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  errorValue = error
                }
              }, receiveValue: { successValue = $0 })
              .store(in: &cancellables)
          }

          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledGet).toEventually(equal(0))
          }

          it("should dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledGet).toEventually(equal(1))
          }

          it("should pass the right key") {
            expect(cacheA.didGetKey).toEventually(equal(key))
          }

          context("when the request succeeds") {
            let value = 2010

            beforeEach {
              fakeRequest.send(value)
            }

            it("should call the original success closure") {
              expect(successValue).toEventually(equal(value))
            }

            it("should not call the original failure closure") {
              expect(errorValue).toEventually(beNil())
            }
          }

          context("when the request fails") {
            let errorCode = TestError.simpleError

            beforeEach {
              fakeRequest.send(completion: .failure(errorCode))
            }

            it("should call the original failure closure") {
              expect(errorValue as? TestError).toEventually(equal(errorCode))
            }

            it("should not call the original success closure") {
              expect(successValue).toEventually(beNil())
            }
          }
        }

        context("when the switch closure returns cacheB") {
          let key = "short"

          beforeEach {
            finalCache.get(key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  errorValue = error
                }
              }, receiveValue: { successValue = $0 })
              .store(in: &cancellables)
          }

          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledGet).toEventually(equal(0))
          }

          it("should dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledGet).toEventually(equal(1))
          }

          it("should pass the right key") {
            expect(cacheB.didGetKey).toEventually(equal(key))
          }

          context("when the request succeeds") {
            let value = 2010

            beforeEach {
              fakeRequest.send(value)
            }

            it("should call the original success closure") {
              expect(successValue).toEventually(equal(value))
            }

            it("should not call the original failure closure") {
              expect(errorValue).toEventually(beNil())
            }
          }

          context("when the request fails") {
            let errorCode = TestError.anotherError

            beforeEach {
              fakeRequest.send(completion: .failure(errorCode))
            }

            it("should call the original failure closure") {
              expect(errorValue as? TestError).toEventually(equal(errorCode))
            }

            it("should not call the original success closure") {
              expect(successValue).toEventually(beNil())
            }
          }
        }
      }
    }

    sharedExamples("a switched cache with 2 fetch closures") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!

      beforeEach {
        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }

      itBehavesLike("should correctly get") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA as Any,
          SwitchCacheSharedExamplesContext.CacheB: cacheB as Any,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache as Any
        ]
      }
    }

    sharedExamples("a switched cache with 2 cache levels") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      var cancellables: Set<AnyCancellable>!

      beforeEach {
        cancellables = Set()
        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }

      afterEach {
        cancellables = nil
      }

      itBehavesLike("should correctly get") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA as Any,
          SwitchCacheSharedExamplesContext.CacheB: cacheB as Any,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache as Any
        ]
      }

      context("when calling set") {
        let value = 30
        var setSucceeded: Bool!
        var setError: Error?

        beforeEach {
          setSucceeded = false
          setError = nil
        }

        context("when the switch closure returns cacheA") {
          let key = "quite long key"

          beforeEach {
            finalCache.set(value, forKey: key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  setError = error
                }
              }, receiveValue: { setSucceeded = true })
              .store(in: &cancellables)
          }

          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).toEventually(equal(0))
          }

          it("should dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).toEventually(equal(1))
          }

          it("should pass the right key") {
            expect(cacheA.didSetKey).toEventually(equal(key))
          }

          it("should pass the right value") {
            expect(cacheA.didSetValue).toEventually(equal(value))
          }

          context("when set succeeds") {
            beforeEach {
              cacheA.setPublishers[key]?.send()
            }

            it("should succeed") {
              expect(setSucceeded).toEventually(beTrue())
            }
          }

          context("when set fails") {
            let setFailure = TestError.anotherError

            beforeEach {
              cacheA.setPublishers[key]?.send(completion: .failure(setFailure))
            }

            it("should fail") {
              expect(setError).toEventuallyNot(beNil())
            }

            it("should pass the error through") {
              expect(setError as? TestError).toEventually(equal(setFailure))
            }
          }
        }

        context("when the switch closure returns cacheB") {
          let key = "short"

          beforeEach {
            finalCache.set(value, forKey: key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  setError = error
                }
              }, receiveValue: { setSucceeded = true })
              .store(in: &cancellables)
          }

          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).toEventually(equal(0))
          }

          it("should dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).toEventually(equal(1))
          }

          it("should pass the right key") {
            expect(cacheB.didSetKey).toEventually(equal(key))
          }

          it("should pass the right value") {
            expect(cacheB.didSetValue).toEventually(equal(value))
          }

          context("when set succeeds") {
            beforeEach {
              cacheB.setPublishers[key]?.send()
            }

            it("should succeed") {
              expect(setSucceeded).toEventually(beTrue())
            }
          }

          context("when set fails") {
            let setFailure = TestError.anotherError

            beforeEach {
              cacheB.setPublishers[key]?.send(completion: .failure(setFailure))
            }

            it("should fail") {
              expect(setError).toEventuallyNot(beNil())
            }

            it("should pass the error through") {
              expect(setError as? TestError).toEventually(equal(setFailure))
            }
          }
        }
      }

      context("when calling clear") {
        beforeEach {
          finalCache.clear()
        }

        it("should dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledClear).toEventually(equal(1))
        }

        it("should dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledClear).toEventually(equal(1))
        }
      }

      context("when calling onMemoryWarning") {
        beforeEach {
          finalCache.onMemoryWarning()
        }

        it("should dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }

        it("should dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }
      }
    }

    sharedExamples("a switched cache with a cache level and a fetch closure") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      var cancellables: Set<AnyCancellable>!

      beforeEach {
        cancellables = Set()
        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }

      afterEach {
        cancellables = nil
      }

      itBehavesLike("should correctly get") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA as Any,
          SwitchCacheSharedExamplesContext.CacheB: cacheB as Any,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache as Any
        ]
      }

      context("when calling set") {
        let value = 30
        var setSucceeded: Bool!
        var setError: Error?

        beforeEach {
          setSucceeded = false
          setError = nil
        }

        context("when the switch closure returns cacheA") {
          let key = "quite long key"

          beforeEach {
            finalCache.set(value, forKey: key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  setError = error
                }
              }, receiveValue: { setSucceeded = true })
              .store(in: &cancellables)
          }

          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).toEventually(equal(0))
          }

          it("should dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).toEventually(equal(1))
          }

          it("should pass the right key") {
            expect(cacheA.didSetKey).toEventually(equal(key))
          }

          it("should pass the right value") {
            expect(cacheA.didSetValue).toEventually(equal(value))
          }

          context("when set succeeds") {
            beforeEach {
              cacheA.setPublishers[key]?.send()
            }

            it("should succeed") {
              expect(setSucceeded).toEventually(beTrue())
            }
          }

          context("when set fails") {
            let setFailure = TestError.anotherError

            beforeEach {
              cacheA.setPublishers[key]?.send(completion: .failure(setFailure))
            }

            it("should fail") {
              expect(setError).toEventuallyNot(beNil())
            }

            it("should pass the error through") {
              expect(setError as? TestError).toEventually(equal(setFailure))
            }
          }
        }

        context("when the switch closure returns cacheB") {
          let key = "short"

          beforeEach {
            _ = finalCache.set(value, forKey: key)
          }

          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).toEventually(equal(0))
          }

          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).toEventually(equal(0))
          }
        }
      }

      context("when calling clear") {
        beforeEach {
          finalCache.clear()
        }

        it("should dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledClear).toEventually(equal(1))
        }

        it("should not dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledClear).toEventually(equal(0))
        }
      }

      context("when calling onMemoryWarning") {
        beforeEach {
          finalCache.onMemoryWarning()
        }

        it("should dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }

        it("should not dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledOnMemoryWarning).toEventually(equal(0))
        }
      }
    }

    sharedExamples("a switched cache with a fetch closure and a cache level") { (sharedExampleContext: @escaping SharedExampleContext) in
      var cacheA: CacheLevelFake<String, Int>!
      var cacheB: CacheLevelFake<String, Int>!
      var finalCache: BasicCache<String, Int>!
      var cancellables: Set<AnyCancellable>!

      beforeEach {
        cancellables = Set()

        cacheA = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheA] as? CacheLevelFake<String, Int>
        cacheB = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheB] as? CacheLevelFake<String, Int>
        finalCache = sharedExampleContext()[SwitchCacheSharedExamplesContext.CacheToTest] as? BasicCache<String, Int>
      }

      afterEach {
        cancellables = nil
      }

      itBehavesLike("should correctly get") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA as Any,
          SwitchCacheSharedExamplesContext.CacheB: cacheB as Any,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache as Any
        ]
      }

      context("when calling set") {
        let value = 30
        var setSucceeded: Bool!
        var setError: Error?

        beforeEach {
          setSucceeded = false
          setError = nil
        }

        context("when the switch closure returns cacheA") {
          let key = "quite long key"

          beforeEach {
            _ = finalCache.set(value, forKey: key)
          }

          it("should not dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).toEventually(equal(0))
          }

          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).toEventually(equal(0))
          }
        }

        context("when the switch closure returns cacheB") {
          let key = "short"

          beforeEach {
            finalCache.set(value, forKey: key)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  setError = error
                }
              }, receiveValue: { setSucceeded = true })
              .store(in: &cancellables)
          }

          it("should not dispatch the call to the first cache") {
            expect(cacheA.numberOfTimesCalledSet).toEventually(equal(0))
          }

          it("should dispatch the call to the second cache") {
            expect(cacheB.numberOfTimesCalledSet).toEventually(equal(1))
          }

          it("should pass the right key") {
            expect(cacheB.didSetKey).toEventually(equal(key))
          }

          it("should pass the right value") {
            expect(cacheB.didSetValue).toEventually(equal(value))
          }

          context("when set succeeds") {
            beforeEach {
              cacheB.setPublishers[key]?.send()
            }

            it("should succeed") {
              expect(setSucceeded).toEventually(beTrue())
            }
          }

          context("when set fails") {
            let setFailure = TestError.anotherError

            beforeEach {
              cacheB.setPublishers[key]?.send(completion: .failure(setFailure))
            }

            it("should fail") {
              expect(setError).toEventuallyNot(beNil())
            }

            it("should pass the error through") {
              expect(setError as? TestError).toEventually(equal(setFailure))
            }
          }
        }
      }

      context("when calling clear") {
        beforeEach {
          finalCache.clear()
        }

        it("should not dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledClear).toEventually(equal(0))
        }

        it("should dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledClear).toEventually(equal(1))
        }
      }

      context("when calling onMemoryWarning") {
        beforeEach {
          finalCache.onMemoryWarning()
        }

        it("should not dispatch the call to the first cache") {
          expect(cacheA.numberOfTimesCalledOnMemoryWarning).toEventually(equal(0))
        }

        it("should dispatch the call to the second cache") {
          expect(cacheB.numberOfTimesCalledOnMemoryWarning).toEventually(equal(1))
        }
      }
    }
  }
}

final class SwitchCacheTests: QuickSpec {
  override func spec() {
    var cacheA: CacheLevelFake<String, Int>!
    var cacheB: CacheLevelFake<String, Int>!
    var finalCache: BasicCache<String, Int>!

    describe("Switching two cache levels") {
      beforeEach {
        cacheA = CacheLevelFake<String, Int>()
        cacheB = CacheLevelFake<String, Int>()
        finalCache = switchLevels(cacheA: cacheA, cacheB: cacheB, switchClosure: switchClosure)
      }

      itBehavesLike("a switched cache with 2 cache levels") {
        [
          SwitchCacheSharedExamplesContext.CacheA: cacheA as Any,
          SwitchCacheSharedExamplesContext.CacheB: cacheB as Any,
          SwitchCacheSharedExamplesContext.CacheToTest: finalCache as Any
        ]
      }
    }
  }
}
