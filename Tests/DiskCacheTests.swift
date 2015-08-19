import Foundation
import Quick
import Nimble
import Carlos

private func filesInDirectory(directory: String) -> [String] {
  var result: [String] = []
  
  do {
    result = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(directory)
  } catch _ {}
  
  return result
}

extension String {
  private func MD5String() -> String {
    if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
      let MD5Calculator = MD5(data)
      let MD5Data = MD5Calculator.calculate()
      let resultBytes = UnsafeMutablePointer<CUnsignedChar>(MD5Data.bytes)
      let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: MD5Data.length)
      let MD5String = NSMutableString()
      for c in resultEnumerator {
        MD5String.appendFormat("%02x", c)
      }
      return MD5String as String
    } else {
      return self
    }
  }
}

class DiskCacheTests: QuickSpec {
  override func spec() {
    describe("DiskCacheLevel") {
      var cache: DiskCacheLevel<String, NSData>!
      let path = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]).stringByAppendingPathComponent("com.carlos.default")
      var fileManager: NSFileManager!
      
      beforeEach {
        fileManager = NSFileManager.defaultManager()
        do {
          try fileManager.removeItemAtPath(path)
        } catch _ {}
        
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
          let value = "value to set".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
          
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
        let value = "value".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        var result: NSData?
        var failureSentinel: Bool?
        
        beforeEach {
          cache.set(value, forKey: key)
        }
        
        it("should save the key on disk") {
          expect(fileManager.fileExistsAtPath(path.stringByAppendingPathComponent(key.MD5String()))).toEventually(beTrue())
        }
        
        it("should save the data on disk") {
          expect(NSKeyedUnarchiver.unarchiveObjectWithFile(path.stringByAppendingPathComponent(key.MD5String())) as? NSData).toEventually(equal(value))
        }
        
        context("when calling get") {
          beforeEach {
            cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
          }
          
          it("should succeed") {
            expect(result).toEventually(equal(value))
          }
          
          it("should not fail") {
            expect(failureSentinel).toEventually(beNil())
          }
        }
        
        context("when setting a different value for the same key") {
          let newValue = "another value".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
          
          beforeEach {
            cache.set(newValue, forKey: key)
          }
          
          it("should keep the key on disk") {
            expect(fileManager.fileExistsAtPath(path.stringByAppendingPathComponent(key.MD5String()))).toEventually(beTrue())
          }
          
          it("should overwrite the data on disk") {
            expect(NSKeyedUnarchiver.unarchiveObjectWithFile(path.stringByAppendingPathComponent(key.MD5String())) as? NSData).toEventually(equal(newValue))
          }
          
          context("when calling get") {
            beforeEach {
              cache.get(key).onSuccess({ result = $0 }).onFailure({ _ in failureSentinel = true })
            }
            
            it("should succeed with the overwritten value") {
              expect(result).toEventually(equal(newValue))
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
              cache.set(value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: key)
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
            expect(filesInDirectory(path)).toEventually(beEmpty())
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
                expect(result).toEventually(equal(value))
              }
            }
          }
        }
      }
    }
  }
}