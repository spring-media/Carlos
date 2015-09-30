import Foundation
import Quick
import Nimble
import Carlos

private struct ComposedOneWayTransformerSharedExamplesContext {
  static let TransformerToTest = "composedTransformer"
}

class OneWayTransformerCompositionSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a composed transformer") {
      (sharedExampleContext: SharedExampleContext) in
      var composedTransformer: OneWayTransformationBox<String, Int>!
      
      beforeEach {
        composedTransformer = sharedExampleContext()[ComposedOneWayTransformerSharedExamplesContext.TransformerToTest] as? OneWayTransformationBox<String, Int>
      }
      
      context("when transforming a value") {
        var result: Int?
        
        context("if the transformation is possible") {
          beforeEach {
            result = composedTransformer.transform("13.2")
          }
          
          it("should return the expected result") {
            expect(result).to(equal(13))
          }
        }
        
        context("if the transformation fails in one of the 2 transformers") {
          beforeEach {
            result = composedTransformer.transform("13hallo")
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
      }
    }
  }
}

class OneWayTransformerCompositionTests: QuickSpec {
  override func spec() {
    var transformer1: OneWayTransformationBox<String, Float>!
    var transformer2: OneWayTransformationBox<Float, Int>!
    var composedTransformer: OneWayTransformationBox<String, Int>!
    
    beforeEach {
      transformer1 = OneWayTransformationBox(transform: { Float($0) })
      transformer2 = OneWayTransformationBox(transform: { Int($0) })
    }
    
    describe("Transformer composition using two transformers with the global function") {
      beforeEach {
        composedTransformer = compose(transformer1, secondTransformer: transformer2)
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using two transformers with the instance function") {
      beforeEach {
        composedTransformer = transformer1.compose(transformer2)
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using two transformers with the operator") {
      beforeEach {
        composedTransformer = transformer1 >>> transformer2
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformer and a transformation closure with the global function") {
      beforeEach {
        composedTransformer = compose(transformer1, transformerClosure: transformer2.transform)
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformer and a transformation closure with the instance function") {
      beforeEach {
        composedTransformer = transformer1.compose(transformer2.transform)
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformer and a transformation closure with the operator") {
      beforeEach {
        composedTransformer = transformer1 >>> transformer2.transform
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformation closure and a transformer with the global function") {
      beforeEach {
        composedTransformer = compose(transformer1.transform, transformer: transformer2)
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformation closure and a transformer with the operator") {
      beforeEach {
        composedTransformer = transformer1.transform >>> transformer2
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using two transformation closures with the global function") {
      beforeEach {
        composedTransformer = compose(transformer1.transform, secondTransformerClosure: transformer2.transform)
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using two transformation closures with the operator") {
      beforeEach {
        composedTransformer = transformer1.transform >>> transformer2.transform
      }
      
      itBehavesLike("a composed transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
  }
}