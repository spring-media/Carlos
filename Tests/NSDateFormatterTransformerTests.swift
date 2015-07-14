import Foundation
import Quick
import Nimble
import Carlos

class NSDateFormatterTransformerTests: QuickSpec {
  override func spec() {
    describe("NSDateFormatter") {
      var formatter: NSDateFormatter!
      
      beforeEach {
        formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
      }
      
      context("when used as a transformer") {
        context("when transforming") {
          let originDate = NSDate(timeIntervalSince1970: 1436644623)
          var resultString: String!
          
          beforeEach {
            resultString = formatter.transform(originDate)
          }
          
          it("should return the expected string") {
            expect(resultString).to(equal("2015-07-11"))
          }
        }
        
        context("when inverse transforming") {
          let originString = "2015-07-11"
          var resultDate: NSDate!
          
          beforeEach {
            resultDate = formatter.inverseTransform(originString)
          }
          
          it("should return the expected date") {
            expect(formatter.stringFromDate(resultDate)).to(equal(originString))
          }
        }
      }
    }
  }
}