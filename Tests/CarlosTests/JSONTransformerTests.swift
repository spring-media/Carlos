import Foundation
import Quick
import Nimble
import Carlos
import OpenCombine

class JSONTransformerTests: QuickSpec {
  override func spec() {
    describe("JSONTransformer") {
      var transformer: JSONTransformer!
      
      var cancellable: AnyCancellable?
    
      beforeEach {
        transformer = JSONTransformer()
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      context("when transforming NSData to JSON") {
        var result: AnyObject!
        var error: Error!
        
        afterEach {
          result = nil
          error = nil
        }
        
        context("when the NSData is a valid JSON") {
          context("when it's an array") {
            let testObject = [
              "list",
              "of",
              "strings"
            ]
            
            beforeEach {
              let data = try! JSONSerialization.data(withJSONObject: testObject, options: [])
              cancellable = transformer.transform(data as NSData)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: { result = $0 })
            }
            
            it("should call the success closure") {
              expect(result).toEventuallyNot(beNil())
            }
            
            it("should not call the failure closure") {
              expect(error).toEventually(beNil())
            }
            
            it("should return an array") {
              expect(result as? [String]).toEventuallyNot(beNil())
            }
            
            it("should contain the right number of items") {
              expect((result as? [String])?.count).toEventually(equal(testObject.count))
            }
            
            it("should contain the right objects") {
              expect(result as? [String]).toEventually(equal(testObject))
            }
          }
          
          context("when it's a dictionary") {
            let testObject: [String: Any] = [
              "id": 2,
              "value": "test",
              "anotherKey": [
                "1",
                "2",
                "3"
              ]
            ]
            
            beforeEach {
              let data = try! JSONSerialization.data(withJSONObject: testObject, options: [])
              cancellable = transformer.transform(data as NSData)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: {
                  result = $0
                })
            }
            
            it("should call the success closure") {
              expect(result).toEventuallyNot(beNil())
            }
            
            it("should not call the failure closure") {
              expect(error).toEventually(beNil())
            }
            
            it("should return a dictionary") {
              expect(result as? [String: AnyObject]).toEventuallyNot(beNil())
            }
            
            it("should contain the right number of items") {
              expect((result as? [String: AnyObject])?.keys.count).toEventually(equal(testObject.keys.count))
            }
          }
        }
        
        context("when the NSData is not a valid JSON") {
          beforeEach {
            cancellable = transformer.transform(("test for an invalid JSON".data(using: .utf8) as NSData?)!)
              .sink(receiveCompletion: { completion in
                if case let .failure(e) = completion {
                  error = e
                }
              }, receiveValue: { result = $0 })
          }
          
          it("should not call the success closure") {
            expect(result).toEventually(beNil())
          }
          
          it("should call the failure closure") {
            expect(error).toEventuallyNot(beNil())
          }
        }
      }
      
      context("when transforming JSON to NSData") {
        var result: NSData!
        var error: Error!
        
        context("when the JSON is valid") {
          var expectedResult: NSData!
          
          context("when it's an array") {
            let testObject = [
              "1", "two", "3", "some other thing"
            ]
            
            beforeEach {
              expectedResult = try! JSONSerialization.data(withJSONObject: testObject, options: []) as NSData
              cancellable = transformer.inverseTransform(testObject as AnyObject)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: { result = $0 })
            }
            
            it("should call the success closure") {
              expect(result).toEventuallyNot(beNil())
            }
          
            it("should not call the failure closure") {
              expect(error).toEventually(beNil())
            }
            
            it("should pass the expected result") {
              expect(result).toEventually(equal(expectedResult))
            }
          }
          
          context("when it's a dictionary") {
            let testObject: [String: Any] = [
              "id": 1,
              "key": "value",
              "anotherKey": [
                1, 2, 3, 4, 5
              ]
            ]
            
            beforeEach {
              expectedResult = try! JSONSerialization.data(withJSONObject: testObject, options: []) as NSData
              cancellable = transformer.inverseTransform(testObject as AnyObject)
                .sink(receiveCompletion: { completion in
                  if case let .failure(e) = completion {
                    error = e
                  }
                }, receiveValue: { result = $0 })
            }
            
            it("should call the success closure") {
              expect(result).toEventuallyNot(beNil())
            }
                
            it("should not call the failure closure") {
              expect(error).toEventually(beNil())
            }
            
            it("should pass the expected result") {
              expect(result).toEventually(equal(expectedResult))
            }
          }
        }
      }
    }
  }
}
