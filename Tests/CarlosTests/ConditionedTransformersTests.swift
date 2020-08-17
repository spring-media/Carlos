import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

struct ConditionedTransformerSharedExamplesContext {
  static let TransformerToTest = "transformer"
}

final class ConditionedTransformerSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a conditioned one-way transformer") { (sharedExampleContext: @escaping SharedExampleContext) in
      var transformer: OneWayTransformationBox<String, Int>!
      var cancellable: AnyCancellable?
      
      beforeEach {
        transformer = sharedExampleContext()[ConditionedTransformerSharedExamplesContext.TransformerToTest] as? OneWayTransformationBox<String, Int>
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      context("when calling transform") {
        var result: Int?
        var failure: Error?
        
        beforeEach {
          result = nil
          failure = nil
        }
        
        context("when the condition is satisfied") {
          context("when the transformation is successful") {
            beforeEach {
              cancellable = transformer.transform("15")
                .sink(receiveCompletion: { completion in
                  if case let .failure(error) = completion {
                    failure = error
                  }
                }, receiveValue: { result = $0 })
            }
            
            it("should succeed") {
              expect(result).toEventuallyNot(beNil())
            }
            
            it("should return the right value") {
              expect(result).toEventually(equal(15))
            }
            
            it("should not fail") {
              expect(failure).toEventually(beNil())
            }
          }
          
          context("when the transformation fails") {
            beforeEach {
              cancellable = transformer.transform("not a number")
                .sink(receiveCompletion: { completion in
                  if case let .failure(error) = completion {
                    failure = error
                  }
                }, receiveValue: { result = $0 })
            }
            
            it("should not succeed") {
              expect(result).toEventually(beNil())
            }
            
            it("should fail") {
              expect(failure).toEventuallyNot(beNil())
            }
            
            it("should return the right error") {
              expect(failure as? TransformerError).toEventually(equal(TransformerError.transformationError))
            }
          }
        }
        
        context("when the condition is not satisfied") {
          beforeEach {
            cancellable = transformer.transform("fail now")
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failure = error
                }
              }, receiveValue: { result = $0 })
          }
          
          it("should not succeed") {
            expect(result).toEventually(beNil())
          }
          
          it("should fail") {
            expect(failure).toEventuallyNot(beNil())
          }
          
          it("should return the right error") {
            expect(failure as? FetchError).toEventually(equal(FetchError.conditionNotSatisfied))
          }
        }
        
        context("when the condition fails") {
          beforeEach {
            cancellable = transformer.transform("fail with custom error")
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failure = error
                }
              }, receiveValue: { result = $0 })
          }
          
          it("should not succeed") {
            expect(result).toEventually(beNil())
          }
          
          it("should fail") {
            expect(failure).toEventuallyNot(beNil())
          }
          
          it("should return the right error") {
            expect(failure as? ConditionError).toEventually(equal(ConditionError.customError))
          }
        }
      }
    }
    
    sharedExamples("a conditioned two-way transformer") { (sharedExampleContext: @escaping SharedExampleContext) in
      var transformer: TwoWayTransformationBox<String, Int>!
      var cancellable: AnyCancellable?
      
      beforeEach {
        transformer = sharedExampleContext()[ConditionedTransformerSharedExamplesContext.TransformerToTest] as? TwoWayTransformationBox<String, Int>
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      itBehavesLike("a conditioned one-way transformer") {
        [
          ConditionedTransformerSharedExamplesContext.TransformerToTest: OneWayTransformationBox<String, Int>(transform: transformer.transform)
        ]
      }
      
      context("when calling inverseTransform") {
        var result: String?
        var failure: Error?
        
        beforeEach {
          result = nil
          failure = nil
        }
        
        context("when the condition is satisfied") {
          beforeEach {
            cancellable = transformer.inverseTransform(15)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failure = error
                }
              }, receiveValue: { result = $0 })
          }
          
          it("should succeed") {
            expect(result).toEventuallyNot(beNil())
          }
          
          it("should return the right value") {
            expect(result).toEventually(equal("15"))
          }
          
          it("should not fail") {
            expect(failure).toEventually(beNil())
          }
        }
        
        context("when the condition is not satisfied") {
          beforeEach {
            cancellable = transformer.inverseTransform(-14)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failure = error
                }
              }, receiveValue: { result = $0 })
          }
          
          it("should not succeed") {
            expect(result).toEventually(beNil())
          }
          
          it("should fail") {
            expect(failure).toEventuallyNot(beNil())
          }
          
          it("should return the right error") {
            expect(failure as? FetchError).toEventually(equal(FetchError.conditionNotSatisfied))
          }
        }
        
        context("when the condition fails") {
          beforeEach {
            cancellable = transformer.inverseTransform(0)
              .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                  failure = error
                }
              }, receiveValue: { result = $0 })
          }
          
          it("should not succeed") {
            expect(result).toEventually(beNil())
          }
          
          it("should fail") {
            expect(failure).toEventuallyNot(beNil())
          }
          
          it("should return the right error") {
            expect(failure as? ConditionError).toEventually(equal(ConditionError.customError))
          }
        }
      }
    }
  }
}

private enum ConditionError: Error {
  case customError
}

private enum TransformerError: Error {
  case transformationError
}

final class ConditionedTransformersTests: QuickSpec {
  override func spec() {
    describe("Conditioned one way transformers") {
      var transformer: OneWayTransformationBox<String, Int>!
      let condition: (String) -> AnyPublisher<Bool, Error> = { input in
        if (input as NSString).range(of: "fail").location != NSNotFound {
          if (input as NSString).range(of: "custom").location != NSNotFound {
            return Fail(error: ConditionError.customError).eraseToAnyPublisher()
          } else {
            return Just(false).setFailureType(to: Error.self).eraseToAnyPublisher()
          }
        } else {
          return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
      }
      
      beforeEach {
        transformer = OneWayTransformationBox<String, Int>(transform: {
          guard let intValue = Int($0) else {
            return Fail(error: TransformerError.transformationError).eraseToAnyPublisher()
          }
          
          return Just(intValue).setFailureType(to: Error.self).eraseToAnyPublisher()
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
      let condition: (String) -> AnyPublisher<Bool, Error> = { input in
        if (input as NSString).range(of: "fail").location != NSNotFound {
          if (input as NSString).range(of: "custom").location != NSNotFound {
            return Fail(error: ConditionError.customError).eraseToAnyPublisher()
          } else {
            return Just(false).setFailureType(to: Error.self).eraseToAnyPublisher()
          }
        } else {
          return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
      }
      let inverseCondition: (Int) -> AnyPublisher<Bool, Error> = { input in
        if input >= 0 {
          if input == 0 {
            return Fail(error: ConditionError.customError).eraseToAnyPublisher()
          } else {
            return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
          }
        } else {
          return Just(false).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
      }
      
      beforeEach {
        transformer = TwoWayTransformationBox<String, Int>(transform: {
          guard let intValue = Int($0) else {
            return Fail(error: TransformerError.transformationError).eraseToAnyPublisher()
          }
          
          return Just(intValue).setFailureType(to: Error.self).eraseToAnyPublisher()
        }, inverseTransform: {
          Just("\($0)").setFailureType(to: Error.self).eraseToAnyPublisher()
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
