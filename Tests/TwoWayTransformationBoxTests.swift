import Foundation
import Quick
import Nimble
import Carlos

class TwoWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("TwoWayTransformationBox") {
      var box: TwoWayTransformationBox<NSURL, String>!
      
      beforeEach {
        box = TwoWayTransformationBox<NSURL, String>(transform: { $0.absoluteString ?? "" }, inverseTransform: { NSURL(string: $0)! })
      }
      
      context("when using the transformation") {
        let originURL = NSURL(string: "http://github.com/WeltN24/Carlos")!
        var resultString: String!
        
        beforeEach {
          resultString = box.transform(originURL)
        }
        
        it("should return the expected result") {
          expect(resultString).to(equal(originURL.absoluteString!))
        }
      }
      
      context("when using the inverse transformation") {
        let originString = "http://github.com/WeltN24/Carlos"
        var resultURL: NSURL!
        
        beforeEach {
          resultURL = box.inverseTransform(originString)
        }
        
        it("should return the expected result") {
          expect(resultURL).to(equal(NSURL(string: originString)!))
        }
      }
      
      context("when inverting the transformer") {
        var invertedBox: TwoWayTransformationBox<String, NSURL>!
        
        beforeEach {
          invertedBox = invert(box)
        }
        
        context("when using the transformation") {
          let originString = "http://github.com/WeltN24/Carlos"
          var resultURL: NSURL!
          
          beforeEach {
            resultURL = invertedBox.transform(originString)
          }
          
          it("should return the expected result") {
            expect(resultURL).to(equal(NSURL(string: originString)!))
          }
        }
        
        context("when using the inverse transformation") {
          let originURL = NSURL(string: "http://github.com/WeltN24/Carlos")!
          var resultString: String!
          
          beforeEach {
            resultString = invertedBox.inverseTransform(originURL)
          }
          
          it("should return the expected result") {
            expect(resultString).to(equal(originURL.absoluteString!))
          }
        }
      }
    }
  }
}