import Foundation
import Quick
import Nimble
import Carlos
import PiedPiper

class ConditionedOneWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("Conditioned one-way transformation box") {
      var box: ConditionedOneWayTransformationBox<[String: Bool], String, Int>!
      
      context("when created through a closure") {
        beforeEach {
          box = ConditionedOneWayTransformationBox(conditionalTransformClosure: { key, value in
            if let _ = key["value"] {
              return Future(value: Int(value), error: TestError.SimpleError)
            } else {
              return Future(TestError.AnotherError)
            }
          })
        }
        
        context("when calling conditionalTransform") {
          var result: Int!
          var error: ErrorType!
          
          beforeEach {
            result = nil
            error = nil
          }
          
          context("if the transformation is possible") {
            let originString = "102"
            
            beforeEach {
              box.conditionalTransform(["value": true], value: originString)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should call the success closure") {
              expect(result).notTo(beNil())
            }
            
            it("should not call the failure closure") {
              expect(error).to(beNil())
            }
            
            it("should return the expected result") {
              expect(result).to(equal(Int(originString)))
            }
          }
          
          context("if the transformation is not possible") {
            let originString = "10asd2"
            
            beforeEach {
              box.conditionalTransform(["value": true], value: originString)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should not call the success closure") {
              expect(result).to(beNil())
            }
            
            it("should call the failure closure") {
              expect(error).notTo(beNil())
            }
            
            it("should pass the right error") {
              expect(error as? TestError).to(equal(TestError.SimpleError))
            }
          }
          
          context("if the key doesn't satisfy the condition") {
            beforeEach {
              box.conditionalTransform([:], value: "whatever")
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should not call the success closure") {
              expect(result).to(beNil())
            }
            
            it("should call the failure closure") {
              expect(error).notTo(beNil())
            }
            
            it("should pass the right error") {
              expect(error as? TestError).to(equal(TestError.AnotherError))
            }
          }
        }
      }
      
      context("when created through a one way transformer") {
        beforeEach {
          let transformer = OneWayTransformationBox<String, Int>(transform: { value in
            Future(value: Int(value), error: TestError.SimpleError)
          })
          
          box = ConditionedOneWayTransformationBox(transformer: transformer)
        }
        
        context("when calling conditionalTransform") {
          var result: Int!
          var error: ErrorType!
          
          beforeEach {
            result = nil
            error = nil
          }
          
          context("if the transformation is possible") {
            let originString = "102"
            
            beforeEach {
              box.conditionalTransform(["value": true], value: originString)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should call the success closure") {
              expect(result).notTo(beNil())
            }
            
            it("should not call the failure closure") {
              expect(error).to(beNil())
            }
            
            it("should return the expected result") {
              expect(result).to(equal(Int(originString)))
            }
          }
          
          context("if the transformation is not possible") {
            let originString = "10asd2"
            
            beforeEach {
              box.conditionalTransform([:], value: originString)
                .onSuccess({ result = $0 })
                .onFailure({ error = $0 })
            }
            
            it("should not call the success closure") {
              expect(result).to(beNil())
            }
            
            it("should call the failure closure") {
              expect(error).notTo(beNil())
            }
            
            it("should pass the right error") {
              expect(error as? TestError).to(equal(TestError.SimpleError))
            }
          }
        }
      }
    }
  }
}