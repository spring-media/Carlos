import Foundation
import Quick
import Nimble
import Carlos

class NSNumberFormatterTransformerTests: QuickSpec {
  override func spec() {
    describe("NSNumberFormatter") {
      var formatter: NSNumberFormatter!
      
      beforeEach {
        formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 3
      }
      
      context("when used as a transformer") {
        context("when transforming") {
          context("when the number contains a valid number of fraction digits") {
            let originNumber = 10.1203
            var resultString: String!
            
            beforeEach {
              resultString = formatter.transform(originNumber)
            }
            
            it("should return the expected string") {
              expect(resultString).to(equal("10.1203"))
            }
          }
          
          context("when the number contains less fractions digits") {
            let originNumber = 10.12
            var resultString: String!
            
            beforeEach {
              resultString = formatter.transform(originNumber)
            }
            
            it("should return the expected string") {
              expect(resultString).to(equal("10.120"))
            }
          }
          
          context("when the number contains more fraction digits") {
            let originNumber = 10.120312
            var resultString: String!
            
            beforeEach {
              resultString = formatter.transform(originNumber)
            }
            
            it("should return the expected string") {
              expect(resultString).to(equal("10.12031"))
            }
          }
        }
        
        context("when inverse transforming") {
          let originString = "10.1203"
          var resultNumber: NSNumber!
          
          beforeEach {
            resultNumber = formatter.inverseTransform(originString)
          }
          
          it("should return the expected number") {
            expect("\(resultNumber)").to(equal(originString))
          }
        }
      }
    }
  }
}