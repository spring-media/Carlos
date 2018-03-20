import Foundation
import Quick
import Nimble
@testable import Carlos

private func filesInDirectory(directory: String) -> [String] {
  let result = (try? FileManager.default.contentsOfDirectory(atPath: directory)) ?? []
  
  return result
}

class DiskCacheTests: QuickSpec {
  override func spec() {
    describe("DiskCacheLevel") {
      var cache: DiskCacheLevel<String, NSData>!
      let path = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString).appendingPathComponent("com.carlos.default")
      var fileManager: FileManager!
      
      beforeEach {
        fileManager = FileManager.default
        _ = try? fileManager.removeItem(atPath: path)
        
        cache = DiskCacheLevel(path: path, capacity: 400)
      }
      
      context("when calling get") {
        var result: NSData?
        let key = "test-key"
        var failureSentinel: Bool?
        
        beforeEach {
          cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
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
            
            _ = cache.set(value as NSData, forKey: key)
          }
          
          context("when getting the value for another key") {
            let anotherKey = "test_key_2"
            
            beforeEach {
              cache.get(anotherKey).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
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
          cache.set(value as NSData, forKey: key).onSuccess {
            writeSucceeded = true
          }
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
            cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
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
            _ = cache.set(newValue as NSData, forKey: key)
          }
          
          it("should keep the key on disk") {
            expect(fileManager.fileExists(atPath: (path as NSString).appendingPathComponent(key.MD5String()))).toEventually(beTrue())
          }
          
          it("should overwrite the data on disk") {
            expect(NSKeyedUnarchiver.unarchiveObject(withFile: (path as NSString).appendingPathComponent(key.MD5String())) as? NSData).toEventually(equal(newValue as NSData))
          }
          
          context("when calling get") {
            beforeEach {
              cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
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
              _ = cache.set(value.data(using: .utf8, allowLossyConversion: false)! as NSData, forKey: key)
            }
          }
          
          it("should evict at least one value") {
            var evictedAtLeastOne = false
            
            for key in otherKeys {
              cache.get(key).onFailure({ _ in evictedAtLeastOne = true })
            }
            
            expect(evictedAtLeastOne).toEventually(beTrue())
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
              cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
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
                cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
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
