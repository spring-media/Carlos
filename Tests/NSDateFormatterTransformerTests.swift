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
        var error: ErrorType!
        
        beforeEach {
          error = nil
        }
        
        context("when transforming") {
          let originDate = NSDate(timeIntervalSince1970: 1436644623)
          var result: String!
          
          beforeEach {
            result = nil
            
            formatter.transform(originDate)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should call the success closure") {
            expect(result).notTo(beNil())
          }
          
          it("should not call the failure closure") {
            expect(error).to(beNil())
          }
          
          it("should return the expected string") {
            expect(result).to(equal("2015-07-11"))
          }
        }
        
        context("when inverse transforming") {
          var result: NSDate!
          
          beforeEach {
            result = nil
          }
          
          context("when the string is valid") {
            let originString = "2015-07-11"
            
            beforeEach {
              formatter.inverseTransform(originString)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should call the success closure") {
              expect(result).notTo(beNil())
            }
            
            it("should not call the failure closure") {
              expect(error).to(beNil())
            }
            
            it("should return the expected date") {
              expect(formatter.stringFromDate(result)).to(equal(originString))
            }
          }
          
          context("when the string is invalid") {
            beforeEach {
              formatter.inverseTransform("this is not a valid date")
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should not call the success closure") {
              expect(result).to(beNil())
            }
                
            it("should call the error closure") {
              expect(error).notTo(beNil())
            }
          }
        }
      }
    }
  }
}