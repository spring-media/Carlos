import Foundation
import Quick
import Nimble
import Carlos

class StringTransformerTests: QuickSpec {
  override func spec() {
    describe("String transformer") {
      var transformer: StringTransformer!
      
      beforeEach {
        transformer = StringTransformer(encoding: NSUTF8StringEncoding)
      }
      
      context("when transforming NSData to String") {
        var result: String?
        
        context("when the NSData is a valid string") {
          let stringSample = "this is a sample string"
          
          beforeEach {
            result = transformer.transform(stringSample.dataUsingEncoding(NSUTF8StringEncoding)!)
          }
          
          it("should not return nil") {
            expect(result).notTo(beNil())
          }
          
          it("should return the expected String") {
            expect(result).to(equal(stringSample))
          }
        }
      }
      
      context("when transforming String to NSData") {
        var result: NSData?
        let expectedString = "this is the expected string value"
        
        beforeEach {
          result = transformer.inverseTransform(expectedString)
        }
        
        it("should not return nil") {
          expect(result).notTo(beNil())
        }
        
        it("should return the expected data") {
          expect(result).to(equal(expectedString.dataUsingEncoding(NSUTF8StringEncoding)))
        }
      }
    }
  }
}