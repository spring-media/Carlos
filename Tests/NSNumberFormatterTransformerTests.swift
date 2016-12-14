import Foundation
import Quick
import Nimble
import Carlos

class NSNumberFormatterTransformerTests: QuickSpec {
  override func spec() {
    describe("NumberFormatter") {
      var formatter: NumberFormatter!
      
      beforeEach {
        formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "us_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 3
      }
      
      context("when used as a transformer") {
        var error: Error!
        
        context("when transforming") {
          var result: String!
          
          beforeEach {
            result = nil
          }
          
          context("when the number contains a valid number of fraction digits") {
            let originNumber = 10.1203
            
            beforeEach {
              formatter.transform(NSNumber(value: originNumber))
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
              expect(result).to(equal("10.1203"))
            }
          }
          
          context("when the number contains less fractions digits") {
            let originNumber = 10.12
            
            beforeEach {
              formatter.transform(NSNumber(value: originNumber))
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
              expect(result).to(equal("10.120"))
            }
          }
          
          context("when the number contains more fraction digits") {
            let originNumber = 10.120312
            
            beforeEach {
              formatter.transform(NSNumber(value: originNumber))
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
              expect(result).to(equal("10.12031"))
            }
          }
        }
        
        context("when inverse transforming") {
          var result: NSNumber!
              
          beforeEach {
            result = nil
          }
          
          context("when the string is valid") {
            let originString = "10.1203"
            
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
            
            it("should return the expected number") {
              let compare = result ?? NSNumber(value: 0)
              expect("\(compare)").to(equal(originString))
            }
          }
          
          context("when the string is invalid") {
            beforeEach {
              formatter.inverseTransform("not a number!")
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
