import Foundation
import Quick
import Nimble
import Carlos

private struct ConditionedTransformerSharedExamplesContext {
  static let TransformerToTest = "transformer"
}

class ConditionedTransformerSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a conditioned one-way transformer") { (sharedExampleContext: SharedExampleContext) in
      var transformer: OneWayTransformationBox<String, Int>!
      
      beforeEach {
        transformer = sharedExampleContext()[ConditionedTransformerSharedExamplesContext.TransformerToTest] as? OneWayTransformationBox<String, Int>!
      }
      
      context("when calling transform") {
        var result: Int?
        var failure: ErrorType?
        
        beforeEach {
          result = nil
          failure = nil
        }
        
        context("when the condition is satisfied") {
          context("when the transformation is successful") {
            beforeEach {
              transformer.transform("15").onSuccess { value in
                result = value
                }.onFailure { error in
                  failure = error
              }
            }
            
            it("should succeed") {
              expect(result).notTo(beNil())
            }
            
            it("should return the right value") {
              expect(result).to(equal(15))
            }
            
            it("should not fail") {
              expect(failure).to(beNil())
            }
          }
          
          context("when the transformation fails") {
            beforeEach {
              transformer.transform("not a number").onSuccess { value in
                result = value
              }.onFailure { error in
                failure = error
              }
            }
            
            it("should not succeed") {
              expect(result).to(beNil())
            }
            
            it("should fail") {
              expect(failure).notTo(beNil())
            }
            
            it("should return the right error") {
              expect(failure as? TransformerError).to(equal(TransformerError.TransformationError))
            }
          }
        }
        
        context("when the condition is not satisfied") {
          beforeEach {
            transformer.transform("fail now").onSuccess { value in
              result = value
            }.onFailure { error in
              failure = error
            }
          }
          
          it("should not succeed") {
            expect(result).to(beNil())
          }
          
          it("should fail") {
            expect(failure).notTo(beNil())
          }
          
          it("should return the right error") {
            expect(failure as? FetchError).to(equal(FetchError.ConditionNotSatisfied))
          }
        }
        
        context("when the condition fails") {
          beforeEach {
            transformer.transform("fail with custom error").onSuccess { value in
              result = value
            }.onFailure { error in
              failure = error
            }
          }
          
          it("should not succeed") {
            expect(result).to(beNil())
          }
          
          it("should fail") {
            expect(failure).notTo(beNil())
          }
          
          it("should return the right error") {
            expect(failure as? ConditionError).to(equal(ConditionError.CustomError))
          }
        }
      }
    }
    
    sharedExamples("a conditioned two-way transformer") { (sharedExampleContext: SharedExampleContext) in
      var transformer: TwoWayTransformationBox<String, Int>!
      
      beforeEach {
        transformer = sharedExampleContext()[ConditionedTransformerSharedExamplesContext.TransformerToTest] as? TwoWayTransformationBox<String, Int>!
      }
      
      itBehavesLike("a conditioned one-way transformer") {
        [
          ConditionedTransformerSharedExamplesContext.TransformerToTest: OneWayTransformationBox<String, Int>(transform: transformer.transform)
        ]
      }
      
      context("when calling inverseTransform") {
        var result: String?
        var failure: ErrorType?
        
        beforeEach {
          result = nil
          failure = nil
        }
        
        context("when the condition is satisfied") {
          beforeEach {
            transformer.inverseTransform(15).onSuccess { value in
              result = value
              }.onFailure { error in
                failure = error
            }
          }
          
          it("should succeed") {
            expect(result).notTo(beNil())
          }
          
          it("should return the right value") {
            expect(result).to(equal("15"))
          }
          
          it("should not fail") {
            expect(failure).to(beNil())
          }
        }
        
        context("when the condition is not satisfied") {
          beforeEach {
            transformer.inverseTransform(-14).onSuccess { value in
              result = value
            }.onFailure { error in
              failure = error
            }
          }
          
          it("should not succeed") {
            expect(result).to(beNil())
          }
          
          it("should fail") {
            expect(failure).notTo(beNil())
          }
          
          it("should return the right error") {
            expect(failure as? FetchError).to(equal(FetchError.ConditionNotSatisfied))
          }
        }
        
        context("when the condition fails") {
          beforeEach {
            transformer.inverseTransform(0).onSuccess { value in
              result = value
            }.onFailure { error in
              failure = error
            }
          }
          
          it("should not succeed") {
            expect(result).to(beNil())
          }
          
          it("should fail") {
            expect(failure).notTo(beNil())
          }
          
          it("should return the right error") {
            expect(failure as? ConditionError).to(equal(ConditionError.CustomError))
          }
        }
      }
    }
  }
}

private enum ConditionError: ErrorType {
  case CustomError
}

private enum TransformerError: ErrorType {
  case TransformationError
}

class ConditionedTransformersTests: QuickSpec {
  override func spec() {
    describe("Conditioned one way transformers") {
      var transformer: OneWayTransformationBox<String, Int>!
      let condition: (String) -> Promise<Bool> = { input in
        if input.rangeOfString("fail") != nil {
          if input.rangeOfString("custom") != nil {
            return Promise(error: ConditionError.CustomError)
          } else {
            return Promise(value: false)
          }
        } else {
          return Promise(value: true)
        }
      }
      
      beforeEach {
        transformer = OneWayTransformationBox<String, Int>(transform: {
          Promise(value: Int($0), error: TransformerError.TransformationError)
        }).conditioned(condition)
      }
      
      itBehavesLike("a conditioned one-way transformer") {
        [
          ConditionedTransformerSharedExamplesContext.TransformerToTest: transformer
        ]
      }
    }
    
    describe("Conditioned two way transformers") {
      var transformer: TwoWayTransformationBox<String, Int>!
      let condition: (String) -> Promise<Bool> = { input in
        if input.rangeOfString("fail") != nil {
          if input.rangeOfString("custom") != nil {
            return Promise(error: ConditionError.CustomError)
          } else {
            return Promise(value: false)
          }
        } else {
          return Promise(value: true)
        }
      }
      let inverseCondition: (Int) -> Promise<Bool> = { input in
        if input >= 0 {
          if input == 0 {
            return Promise(error: ConditionError.CustomError)
          } else {
            return Promise(value: true)
          }
        } else {
          return Promise(value: false)
        }
      }
      
      beforeEach {
        transformer = TwoWayTransformationBox<String, Int>(transform: {
          Promise(value: Int($0), error: TransformerError.TransformationError)
        }, inverseTransform: {
          Promise(value: "\($0)")
        }).conditioned(condition, inverseCondition: inverseCondition)
      }
      
      itBehavesLike("a conditioned two-way transformer") {
        [
          ConditionedTransformerSharedExamplesContext.TransformerToTest: transformer
        ]
      }
    }
  }
}