import Foundation

import Nimble
import Quick

import Carlos
import Combine

private func filesInDirectory(directory: String) -> [String] {
  let result = (try? FileManager.default.contentsOfDirectory(atPath: directory)) ?? []

  return result
}

final class DiskCacheTests: QuickSpec {
  override func spec() {
    describe("DiskCacheLevel") {
      var cache: DiskCacheLevel<String, NSData>!
      let path = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString).appendingPathComponent("com.carlos.default")
      var fileManager: FileManager!
      var cancellables: Set<AnyCancellable>!

      beforeEach {
        cancellables = Set()

        fileManager = FileManager.default
        _ = try? fileManager.removeItem(atPath: path)

        cache = DiskCacheLevel(path: path, capacity: 400)
      }

      afterEach {
        cancellables = nil
      }

      context("when calling get") {
        var result: NSData?
        let key = "test-key"
        var failureSentinel: Bool?

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

        context("when setting a value for that key") {
          let value = "value to set".data(using: .utf8, allowLossyConversion: false)!

          beforeEach {
            failureSentinel = nil

            cache.set(value as NSData, forKey: key)
              .sink(receiveCompletion: { _ in }, receiveValue: {})
              .store(in: &cancellables)
          }

          context("when getting the value for another key") {
            let anotherKey = "test_key_2"

            beforeEach {
              cache.get(anotherKey)
                .sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    failureSentinel = true
                  }
                }, receiveValue: { result = $0 })
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
        let value = "value".data(using: .utf8, allowLossyConversion: false)!
        var result: NSData?
        var failureSentinel: Bool?
        var writeSucceeded: Bool!

        beforeEach {
          writeSucceeded = false

          cache.set(value as NSData, forKey: key)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
              writeSucceeded = true
            }).store(in: &cancellables)
        }

        afterEach {
          failureSentinel = nil
          result = nil
        }

        it("should save the key on disk") {
          expect(fileManager.fileExists(atPath: (path as NSString).appendingPathComponent(key.MD5String()))).toEventually(beTrue())
        }

        it("should save the data on disk") {
          expect(NSKeyedUnarchiver.unarchiveObject(withFile: (path as NSString).appendingPathComponent(key.MD5String())) as? NSData).toEventually(equal(value as NSData))
        }

        // TODO: How to simulate failure during writing in order to test it?
        it("should eventually succeed") {
          expect(writeSucceeded).toEventually(beTrue())
        }

        context("when calling get") {
          beforeEach {
            result = nil
            failureSentinel = nil

            cache.set(value as NSData, forKey: key)
              .flatMap {
                cache.get(key)
              }
              .sink(receiveCompletion: { completion in
                if case .failure = completion {
                  failureSentinel = true
                }
              }, receiveValue: { result = $0 })
              .store(in: &cancellables)
          }

          it("should succeed") {
            expect(result).toEventually(equal(value as NSData))
          }

          it("should not fail") {
            expect(failureSentinel).toEventually(beNil())
          }
        }

        context("when setting a different value for the same key") {
          let newValue = "another value".data(using: .utf8, allowLossyConversion: false)!

          beforeEach {
            cache.set(newValue as NSData, forKey: key)
              .sink(receiveCompletion: { _ in }, receiveValue: {})
              .store(in: &cancellables)
          }

          it("should keep the key on disk") {
            expect(fileManager.fileExists(atPath: (path as NSString).appendingPathComponent(key.MD5String()))).toEventually(beTrue())
          }

          it("should overwrite the data on disk") {
            expect(NSKeyedUnarchiver.unarchiveObject(withFile: (path as NSString).appendingPathComponent(key.MD5String())) as? NSData).toEventually(equal(newValue as NSData))
          }

          context("when calling get") {
            beforeEach {
              cache.set(newValue as NSData, forKey: key)
                .flatMap {
                  cache.get(key)
                }
                .sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    failureSentinel = true
                  }
                }, receiveValue: { result = $0 })
                .store(in: &cancellables)
            }

            it("should succeed with the overwritten value") {
              expect(result).toEventually(equal(newValue as NSData))
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
              cache.set(value.data(using: .utf8, allowLossyConversion: false)! as NSData, forKey: key)
                .sink(receiveCompletion: { _ in }, receiveValue: {})
                .store(in: &cancellables)
            }
          }

          it("should evict at least one value") {
            var evictedAtLeastOne = false

            for key in otherKeys {
              cache.get(key)
                .sink(receiveCompletion: { completion in
                  if case .failure = completion {
                    evictedAtLeastOne = true
                  }
                }, receiveValue: { result = $0 })
                .store(in: &cancellables)
            }

            expect(evictedAtLeastOne).toEventually(beTrue())
          }
        }

        context("when calling remove") {
          var result = false
          let key = "test-key"

          beforeEach {
            result = false

            cache.clear()
          }

          it("shall remove object from cache for given key") {
            cache.set("value".data(using: .utf8)! as NSData, forKey: key)
              .flatMap { cache.remove(key) }
              .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                  result = true
                }
              )
              .store(in: &cancellables)

            expect(result).toEventually(beTrue())
          }
        }

        context("when calling clear") {
          beforeEach {
            result = nil

            cache.clear()
          }

          it("should remove all the files on disk") {
            expect(filesInDirectory(directory: path)).toEventually(beEmpty())
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
                expect(result).toEventually(equal(value as NSData))
              }
            }
          }
        }
      }
    }
  }
}
