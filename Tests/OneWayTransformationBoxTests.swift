import Foundation
import Quick
import Nimble
import Carlos

class OneWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("OneWayTransformationBox") {
      var box: OneWayTransformationBox<Int, String>!
      
      beforeEach {
        box = OneWayTransformationBox<Int, String>(transform: { "\($0)" })
      }
      
      context("when using the transformation") {
        let originInt = 102
        var resultString: String!
        
        beforeEach {
          resultString = box.transform(originInt)
        }
        
        it("should return the expected result") {
          expect(resultString).to(equal("\(originInt)"))
        }
      }
    }
  }
}