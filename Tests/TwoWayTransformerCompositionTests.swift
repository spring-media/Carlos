import Foundation
import Quick
import Nimble
import Carlos

private struct ComposedTwoWayTransformerSharedExamplesContext {
  static let TransformerToTest = "composedTransformer"
}

class TwoWayTransformerCompositionSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a composed two-way transformer") {
      (sharedExampleContext: SharedExampleContext) in
      var composedTransformer: TwoWayTransformationBox<String, Int>!
      
      beforeEach {
        composedTransformer = sharedExampleContext()[ComposedTwoWayTransformerSharedExamplesContext.TransformerToTest] as? TwoWayTransformationBox<String, Int>
      }
      
      context("when transforming a value") {
        var result: Int?
        
        context("if the transformation is possible") {
          beforeEach {
            result = composedTransformer.transform("12.15")
          }
          
          it("should not return nil") {
            expect(result).notTo(beNil())
          }
          
          it("should return the expected result") {
            expect(result).to(equal(12))
          }
        }
        
        context("if the transformation fails in the first transformer") {
          beforeEach {
            result = composedTransformer.transform("hallo world")
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
        
        context("if the transformation fails in the second transformer") {
          beforeEach {
            result = composedTransformer.transform("-13.2")
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
      }
      
      context("when doing the inverse transform") {
        var result: String?
        
        context("when the transformation is possible") {
          beforeEach {
            result = composedTransformer.inverseTransform(31)
          }
          
          it("should not return nil") {
            expect(result).notTo(beNil())
          }
          
          it("should return the expected result") {
            expect(result).to(equal("31.0"))
          }
        }
        
        context("if the transformation fails in the first transformer") {
          beforeEach {
            result = composedTransformer.inverseTransform(-4)
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
        
        context("if the transformation fails in the second transformer") {
          beforeEach {
            result = composedTransformer.inverseTransform(105)
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
      }
    }
  }
}

class TwoWayTransformerCompositionTests: QuickSpec {
  override func spec() {
    var transformer1: TwoWayTransformationBox<String, Float>!
    var transformer2: TwoWayTransformationBox<Float, Int>!
    var composedTransformer: TwoWayTransformationBox<String, Int>!
    
    beforeEach {
      transformer1 = TwoWayTransformationBox(transform: {
        Float($0)
      }, inverseTransform: {
        if $0 > 100 {
          return nil
        } else {
          return "\($0)"
        }
      })
      transformer2 = TwoWayTransformationBox(transform: {
        if $0 < 0 {
          return nil
        } else {
          return Int($0)
        }
      }, inverseTransform: {
        if $0 < 0 {
          return nil
        } else {
          return Float($0)
        }
      })
    }
    
    describe("Transformer composition using the global function") {
      beforeEach {
        composedTransformer = compose(transformer1, secondTransformer: transformer2)
      }
      
      itBehavesLike("a composed two-way transformer") {
        [
          ComposedTwoWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using the instance function") {
      beforeEach {
        composedTransformer = transformer1.compose(transformer2)
      }
      
      itBehavesLike("a composed two-way transformer") {
        [
          ComposedTwoWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using the operator") {
      beforeEach {
        composedTransformer = transformer1 >>> transformer2
      }
      
      itBehavesLike("a composed two-way transformer") {
        [
          ComposedTwoWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
  }
}