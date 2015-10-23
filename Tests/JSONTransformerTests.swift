import Foundation
import Quick
import Nimble
import Carlos

class JSONTransformerTests: QuickSpec {
  override func spec() {
    describe("JSONTransformer") {
      var transformer: JSONTransformer!
    
      beforeEach {
        transformer = JSONTransformer()
      }
      
      context("when transforming NSData to JSON") {
        var result: AnyObject!
        var error: ErrorType!
        
        beforeEach {
          result = nil
        }
        
        context("when the NSData is a valid JSON") {
          context("when it's an array") {
            let testObject = [
              "list",
              "of",
              "strings"
            ]
            
            beforeEach {
              let data = try! NSJSONSerialization.dataWithJSONObject(testObject, options: [])
              transformer.transform(data)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should call the success closure") {
              expect(result).notTo(beNil())
            }
            
            it("should not call the failure closure") {
              expect(error).to(beNil())
            }
            
            it("should return an array") {
              expect(result as? [String]).notTo(beNil())
            }
            
            it("should contain the right number of items") {
              expect((result as? [String])?.count).to(equal(testObject.count))
            }
            
            it("should contain the right objects") {
              expect(result as? [String]).to(equal(testObject))
            }
          }
          
          context("when it's a dictionary") {
            let testObject: [String: AnyObject] = [
              "id": 2,
              "value": "test",
              "anotherKey": [
                "1",
                "2",
                "3"
              ]
            ]
            
            beforeEach {
              let data = try! NSJSONSerialization.dataWithJSONObject(testObject, options: [])
              transformer.transform(data)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should call the success closure") {
              expect(result).notTo(beNil())
            }
            
            it("should not call the failure closure") {
              expect(error).to(beNil())
            }
            
            it("should return a dictionary") {
              expect(result as? [String: AnyObject]).notTo(beNil())
            }
            
            it("should contain the right number of items") {
              expect((result as? [String: AnyObject])?.keys.count).to(equal(testObject.keys.count))
            }
          }
        }
        
        context("when the NSData is not a valid JSON") {
          beforeEach {
            transformer.transform("test for an invalid JSON".dataUsingEncoding(NSUTF8StringEncoding)!)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should not call the success closure") {
            expect(result).to(beNil())
          }
          
          it("should call the failure closure") {
            expect(error).notTo(beNil())
          }
        }
      }
      
      context("when transforming JSON to NSData") {
        var result: NSData!
        var error: ErrorType!
        
        context("when the JSON is valid") {
          var expectedResult: NSData!
          
          context("when it's an array") {
            let testObject = [
              "1", "two", "3", "some other thing"
            ]
            
            beforeEach {
              expectedResult = try! NSJSONSerialization.dataWithJSONObject(testObject, options: [])
              transformer.inverseTransform(testObject)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should call the success closure") {
              expect(result).notTo(beNil())
            }
          
            it("should not call the failure closure") {
              expect(error).to(beNil())
            }
            
            it("should pass the expected result") {
              expect(result).to(equal(expectedResult))
            }
          }
          
          context("when it's a dictionary") {
            let testObject: [String: AnyObject] = [
              "id": 1,
              "key": "value",
              "anotherKey": [
                1, 2, 3, 4, 5
              ]
            ]
            
            beforeEach {
              expectedResult = try! NSJSONSerialization.dataWithJSONObject(testObject, options: [])
              transformer.inverseTransform(testObject)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should call the success closure") {
              expect(result).notTo(beNil())
            }
                
            it("should not call the failure closure") {
              expect(error).to(beNil())
            }
            
            it("should pass the expected result") {
              expect(result).to(equal(expectedResult))
            }
          }
        }
        
        xcontext("when the JSON is invalid") { //FIX: :(
          beforeEach {
            transformer.inverseTransform("Test for an invalid JSON object" as NSString)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should not call the success closure") {
            expect(result).to(beNil())
          }
          
          it("should call the failure closure") {
            expect(error).notTo(beNil())
          }
        }
      }
    }
  }
}