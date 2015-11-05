import Foundation
import Quick
import Nimble
import Carlos

struct ComposedOneWayTransformerSharedExamplesContext {
  static let TransformerToTest = "composedTransformer"
}

class OneWayTransformerCompositionSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a composed one-way transformer") {
      (sharedExampleContext: SharedExampleContext) in
      var composedTransformer: OneWayTransformationBox<String, Int>!
      
      beforeEach {
        composedTransformer = sharedExampleContext()[ComposedOneWayTransformerSharedExamplesContext.TransformerToTest] as? OneWayTransformationBox<String, Int>
      }
      
      context("when transforming a value") {
        var result: Int!
        
        beforeEach {
          result = nil
        }
        
        context("if the transformation is possible") {
          beforeEach {
            composedTransformer.transform("13.2").onSuccess { result = $0 }
          }
          
          it("should not return nil") {
            expect(result).notTo(beNil())
          }
          
          it("should return the expected result") {
            expect(result).to(equal(13))
          }
        }
        
        context("if the transformation fails in the first transformer") {
          beforeEach {
            composedTransformer.transform("13hallo").onSuccess { result = $0 }
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
        
        context("if the transformation fails in the second transformer") {
          beforeEach {
            composedTransformer.transform("-13").onSuccess { result = $0 }
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
      transformer1 = OneWayTransformationBox(transform: { Promise(value: Float($0), error: TestError.SimpleError).future })
      transformer2 = OneWayTransformationBox(transform: {
        let result = Promise<Int>()
        
        if $0 < 0 {
          result.fail(TestError.SimpleError)
        } else {
          result.succeed(Int($0))
        }
        
        return result.future
      })
    }
    
    describe("Transformer composition using two transformers with the global function") {
      beforeEach {
        composedTransformer = compose(transformer1, secondTransformer: transformer2)
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using two transformers with the instance function") {
      beforeEach {
        composedTransformer = transformer1.compose(transformer2)
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using two transformers with the operator") {
      beforeEach {
        composedTransformer = transformer1 >>> transformer2
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformer and a transformation closure with the global function") {
      beforeEach {
        composedTransformer = compose(transformer1, transformerClosure: transformer2.transform)
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformer and a transformation closure with the instance function") {
      beforeEach {
        composedTransformer = transformer1.compose(transformer2.transform)
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformer and a transformation closure with the operator") {
      beforeEach {
        composedTransformer = transformer1 >>> transformer2.transform
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformation closure and a transformer with the global function") {
      beforeEach {
        composedTransformer = compose(transformer1.transform, transformer: transformer2)
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using a transformation closure and a transformer with the operator") {
      beforeEach {
        composedTransformer = transformer1.transform >>> transformer2
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using two transformation closures with the global function") {
      beforeEach {
        composedTransformer = compose(transformer1.transform, secondTransformerClosure: transformer2.transform)
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
    
    describe("Transformer composition using two transformation closures with the operator") {
      beforeEach {
        composedTransformer = transformer1.transform >>> transformer2.transform
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer
        ]
      }
    }
  }
}