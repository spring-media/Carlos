import Foundation
import Quick
import Nimble
import Carlos
import CarlosFutures

struct ComposedTwoWayTransformerSharedExamplesContext {
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
        
        beforeEach {
          result = nil
        }
        
        context("if the transformation is possible") {
          beforeEach {
            composedTransformer.transform("12.15").onSuccess { result = $0 }
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
            composedTransformer.transform("hallo world").onSuccess { result = $0 }
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
        
        context("if the transformation fails in the second transformer") {
          beforeEach {
            composedTransformer.transform("-13.2").onSuccess { result = $0 }
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
      }
      
      context("when doing the inverse transform") {
        var result: String?
        
        beforeEach {
          result = nil
        }
        
        context("when the transformation is possible") {
          beforeEach {
            composedTransformer.inverseTransform(31).onSuccess { result = $0 }
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
            composedTransformer.inverseTransform(-4).onSuccess { result = $0 }
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
        
        context("if the transformation fails in the second transformer") {
          beforeEach {
            composedTransformer.inverseTransform(105).onSuccess { result = $0 }
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
        Promise(value: Float($0), error: TestError.SimpleError).future
      }, inverseTransform: {
        let result = Promise<String>()
        if $0 > 100 {
          result.fail(TestError.SimpleError)
        } else {
          result.succeed("\($0)")
        }
        return result.future
      })
      transformer2 = TwoWayTransformationBox(transform: {
        let result = Promise<Int>()
        if $0 < 0 {
          result.fail(TestError.SimpleError)
        } else {
          result.mimic(Promise(value: Int($0), error: TestError.SimpleError).future)
        }
        return result.future
      }, inverseTransform: {
        let result = Promise<Float>()
        if $0 < 0 {
          result.fail(TestError.SimpleError)
        } else {
          result.mimic(Promise(value: Float($0), error: TestError.SimpleError).future)
        }
        return result.future
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