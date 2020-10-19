import Foundation

import Quick
import Nimble

import Carlos
import Combine

struct ComposedTwoWayTransformerSharedExamplesContext {
  static let TransformerToTest = "composedTransformer"
}

final class TwoWayTransformerCompositionSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a composed two-way transformer") {
      (sharedExampleContext: @escaping SharedExampleContext) in
      var composedTransformer: TwoWayTransformationBox<String, Int>!
      var cancellable: AnyCancellable?
      
      beforeEach {
        composedTransformer = sharedExampleContext()[ComposedTwoWayTransformerSharedExamplesContext.TransformerToTest] as? TwoWayTransformationBox<String, Int>
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      context("when transforming a value") {
        var result: Int?
        
        beforeEach {
          result = nil
        }
        
        context("if the transformation is possible") {
          beforeEach {
            cancellable = composedTransformer.transform("12.15")
              .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
          }
          
          it("should not return nil") {
            expect(result).toEventuallyNot(beNil())
          }
          
          it("should return the expected result") {
            expect(result).toEventually(equal(12))
          }
        }
        
        context("if the transformation fails in the first transformer") {
          beforeEach {
            cancellable = composedTransformer.transform("hallo world")
              .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
          }
          
          it("should return nil") {
            expect(result).toEventually(beNil())
          }
        }
        
        context("if the transformation fails in the second transformer") {
          beforeEach {
            cancellable = composedTransformer.transform("-13.2")
              .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
          }
          
          it("should return nil") {
            expect(result).toEventually(beNil())
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
            cancellable = composedTransformer.inverseTransform(31)
              .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
          }
          
          it("should not return nil") {
            expect(result).toEventuallyNot(beNil())
          }
          
          it("should return the expected result") {
            expect(result).toEventually(equal("31.0"))
          }
        }
        
        context("if the transformation fails in the first transformer") {
          beforeEach {
            cancellable = composedTransformer.inverseTransform(-4)
              .sink(receiveCompletion: { _ in }, receiveValue: { result = $0 })
          }
          
          it("should return nil") {
            expect(result).toEventually(beNil())
          }
        }
        
        context("if the transformation fails in the second transformer") {
          beforeEach {
            cancellable = composedTransformer.inverseTransform(105)
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

final class TwoWayTransformerCompositionTests: QuickSpec {
  override func spec() {
    var transformer1: TwoWayTransformationBox<String, Float>!
    var transformer2: TwoWayTransformationBox<Float, Int>!
    var composedTransformer: TwoWayTransformationBox<String, Int>!
    
    beforeEach {
      transformer1 = TwoWayTransformationBox(transform: {
        guard let value = Float($0) else {
          return Fail(error: TestError.simpleError).eraseToAnyPublisher()
        }
        
        return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
      }, inverseTransform: {
        guard $0 < 100 else {
          return Fail(error: TestError.simpleError).eraseToAnyPublisher()
        }
        
        return Just("\($0)").setFailureType(to: Error.self).eraseToAnyPublisher()
      })
      transformer2 = TwoWayTransformationBox(transform: {
        guard $0 > 0 else {
          return Fail(error: TestError.simpleError).eraseToAnyPublisher()
        }
        
        return Just(Int($0)).setFailureType(to: Error.self).eraseToAnyPublisher()
      }, inverseTransform: {
        guard $0 > 0 else {
          return Fail(error: TestError.simpleError).eraseToAnyPublisher()
        }
        
        return Just(Float($0)).setFailureType(to: Error.self).eraseToAnyPublisher()
      })
    }
    
    describe("Transformer composition using the instance function") {
      beforeEach {
        composedTransformer = transformer1.compose(transformer2)
      }
      
      itBehavesLike("a composed two-way transformer") {
        [
          ComposedTwoWayTransformerSharedExamplesContext.TransformerToTest: composedTransformer as Any
        ]
      }
    }
  }
}
