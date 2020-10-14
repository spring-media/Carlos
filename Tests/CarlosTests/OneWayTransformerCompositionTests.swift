import Foundation

import Quick
import Nimble

import Carlos
import Combine

struct ComposedOneWayTransformerSharedExamplesContext {
  static let TransformerToTest = "composedTransformer"
}

final class OneWayTransformerCompositionSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a composed one-way transformer") {
      (sharedExampleContext: @escaping SharedExampleContext) in
      var composedTransformer: OneWayTransformationBox<String, Int>!
      var cancellable: AnyCancellable?
      
      beforeEach {
        composedTransformer = sharedExampleContext()[ComposedOneWayTransformerSharedExamplesContext.TransformerToTest] as? OneWayTransformationBox<String, Int>
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      context("when transforming a value") {
        var result: Int!
        
        beforeEach {
          result = nil
        }
        
        context("if the transformation is possible") {
          beforeEach {
            cancellable = composedTransformer.transform("13.2")
              .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
          }
          
          it("should not return nil") {
            expect(result).toEventuallyNot(beNil())
          }
          
          it("should return the expected result") {
            expect(result).toEventually(equal(13))
          }
        }
        
        context("if the transformation fails in the first transformer") {
          beforeEach {
            cancellable = composedTransformer.transform("13hallo")
              .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
          }
          
          it("should return nil") {
            expect(result).toEventually(beNil())
          }
        }
        
        context("if the transformation fails in the second transformer") {
          beforeEach {
            cancellable = composedTransformer.transform("-13")
              .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
          }
          
          it("should return nil") {
            expect(result).toEventually(beNil())
          }
        }
      }
    }
  }
}

final class OneWayTransformerCompositionTests: QuickSpec {
  override func spec() {
    var transformer1: OneWayTransformationBox<String, Float>!
    var transformer2: OneWayTransformationBox<Float, Int>!
    var composedTransformer: OneWayTransformationBox<String, Int>!
    
    beforeEach {
      transformer1 = OneWayTransformationBox(transform: {
        guard let value = Float($0) else {
          return Fail(error: TestError.simpleError).eraseToAnyPublisher()
        }
        
        return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
      })
      transformer2 = OneWayTransformationBox(transform: {
        guard $0 > 0 else {
          return Fail(error: TestError.simpleError).eraseToAnyPublisher()
        }
        
        return Just(Int($0)).setFailureType(to: Error.self).eraseToAnyPublisher()
      })
    }
    
    describe("Transformer composition using two transformers with the instance function") {
      beforeEach {
        composedTransformer = transformer1.compose(transformer2)
      }
      
      itBehavesLike("a composed one-way transformer") {
        [
          ComposedOneWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer as Any
        ]
      }
    }
  }
}
