import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

struct FetcherValueTransformationsSharedExamplesContext {
  static let FetcherToTest = "fetcher"
  static let InternalFetcher = "internalFetcher"
  static let Transformer = "transformer"
}

final class FetcherValueTransformationSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(_ configuration: Configuration) {
    sharedExamples("a fetch closure with transformed values") { (sharedExampleContext: @escaping SharedExampleContext) in
      var fetcher: BasicFetcher<String, String>!
      var internalFetcher: FetcherFake<String, Int>!
      var transformer: OneWayTransformationBox<Int, String>!
      var cancellables: Set<AnyCancellable>!
      
      beforeEach {
        cancellables = Set()
        
        fetcher = sharedExampleContext()[FetcherValueTransformationsSharedExamplesContext.FetcherToTest] as? BasicFetcher<String, String>
        internalFetcher = sharedExampleContext()[FetcherValueTransformationsSharedExamplesContext.InternalFetcher] as? FetcherFake<String, Int>
        transformer = sharedExampleContext()[FetcherValueTransformationsSharedExamplesContext.Transformer] as? OneWayTransformationBox<Int, String>
      }
      
      context("when calling get") {
        let key = "12"
        var successValue: String?
        var failureValue: Error?
        var getSubject: PassthroughSubject<Int, Error>!
        
        beforeEach {
          getSubject = PassthroughSubject()
          internalFetcher.getSubject = getSubject
          
          fetcher.get(key)
            .sink(receiveCompletion: { completion in
              if case let .failure(error) = completion {
                failureValue = error
              }
            }, receiveValue: { successValue = $0 })
            .store(in: &cancellables)
        }
        
        it("should forward the call to the internal cache") {
          expect(internalFetcher.numberOfTimesCalledGet).toEventually(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalFetcher.didGetKey).toEventually(equal(key))
        }
        
        context("when the request succeeds") {
          context("when the value can be successfully transformed") {
            let value = 101
            
            beforeEach {
              getSubject.send(value)
            }
            
            it("should call the original success closure") {
              expect(successValue).toEventuallyNot(beNil())
            }
            
            it("should transform the value") {
              var expected: String!
              transformer.transform(value)
                .sink(receiveCompletion: { _ in }, receiveValue: { expected = $0 })
                .store(in: &cancellables)
              expect(successValue).toEventually(equal(expected))
            }
          }
          
          context("when the value transformation returns nil") {
            let value = -101
            
            beforeEach {
              successValue = nil
              getSubject.send(value)
            }
            
            it("should not call the original success closure") {
              expect(successValue).toEventually(beNil())
            }
            
            it("should call the original failure closure") {
              expect(failureValue).toEventuallyNot(beNil())
            }
            
            it("should fail with the right code") {
              expect(failureValue as? TestError).toEventually(equal(TestError.simpleError))
            }
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.anotherError
          
          beforeEach {
            getSubject.send(completion: .failure(errorCode))
          }
          
          it("should call the original failure closure") {
            expect(failureValue).toEventuallyNot(beNil())
          }
          
          it("should fail with the right code") {
            expect(failureValue as? TestError).toEventually(equal(errorCode))
          }
        }
      }
    }
  }
}

final class FetcherValueTransformationTests: QuickSpec {
  override func spec() {
    var fetcher: BasicFetcher<String, String>!
    var internalFetcher: FetcherFake<String, Int>!
    var transformer: OneWayTransformationBox<Int, String>!
    let forwardTransformationClosure: (Int) -> AnyPublisher<String, Error> = {
      if $0 > 0 {
        return Just("\($0 + 1)").setFailureType(to: Error.self).eraseToAnyPublisher()
      }
      
      return Fail(error: TestError.simpleError).eraseToAnyPublisher()
    }
    
    describe("Value transformation using a transformer and a fetcher, with the instance function") {
      beforeEach {
        internalFetcher = FetcherFake<String, Int>()
        transformer = OneWayTransformationBox(transform: forwardTransformationClosure)
        fetcher = internalFetcher.transformValues(transformer)
      }
      
      itBehavesLike("a fetch closure with transformed values") {
        [
          FetcherValueTransformationsSharedExamplesContext.FetcherToTest: fetcher as Any,
          FetcherValueTransformationsSharedExamplesContext.InternalFetcher: internalFetcher as Any,
          FetcherValueTransformationsSharedExamplesContext.Transformer: transformer as Any
        ]
      }
    }
  }
}
