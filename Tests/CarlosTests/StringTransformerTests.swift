//import Foundation
//import Quick
//import Nimble
//import Carlos
//
//class StringTransformerTests: QuickSpec {
//  override func spec() {
//    describe("String transformer") {
//      var transformer: StringTransformer!
//      var error: Error!
//      
//      beforeEach {
//        transformer = StringTransformer(encoding: .utf8)
//      }
//      
//      context("when transforming NSData to String") {
//        var result: String!
//        
//        context("when the NSData is a valid string") {
//          let stringSample = "this is a sample string"
//          
//          beforeEach {
//            transformer.transform((stringSample.data(using: .utf8) as NSData?)!)
//              .onSuccess({ result = $0 })
//              .onFailure({ error = $0 })
//          }
//          
//          it("should not return nil") {
//            expect(result).notTo(beNil())
//          }
//          
//          it("should not call the failure closure") {
//            expect(error).to(beNil())
//          }
//          
//          it("should return the expected String") {
//            expect(result).to(equal(stringSample))
//          }
//        }
//      }
//      
//      context("when transforming String to NSData") {
//        var result: NSData?
//        let expectedString = "this is the expected string value"
//        
//        beforeEach {
//          transformer.inverseTransform(expectedString)
//            .onSuccess({ result = $0 as NSData? })
//            .onFailure({ error = $0 })
//        }
//        
//        it("should call the success closure") {
//          expect(result).notTo(beNil())
//        }
//        
//        it("should return the expected data") {
//          expect(result).to(equal(expectedString.data(using: .utf8) as NSData?))
//        }
//      }
//    }
//  }
//}
