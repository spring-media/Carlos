import Foundation
import Quick
import Nimble
import Carlos

class OneWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("OneWayTransformationBox") {
      var box: OneWayTransformationBox<String, Int>!
      
      beforeEach {
        box = OneWayTransformationBox(transform: { Int($0) })
      }
      
      context("when using the transformation") {
        context("if the transformation is possible") {
          let originString = "102"
          var result: Int!
          
          beforeEach {
            result = box.transform(originString)
          }
          
          it("should return the expected result") {
            expect(result).to(equal(Int(originString)))
          }
        }
        
        context("if the transformation is not possible") {
          let originString = "10asd2"
          var result: Int?
          
          beforeEach {
            result = box.transform(originString)
          }
          
          it("should return the expected result") {
            expect(result).to(beNil())
          }
        }
      }
    }
  }
}