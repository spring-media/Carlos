import Foundation
import Quick
import Nimble
import Carlos

private struct FetcherValueTransformationsSharedExamplesContext {
  static let FetcherToTest = "fetcher"
  static let InternalFetcher = "internalFetcher"
  static let Transformer = "transformer"
}

class FetcherValueTransformationSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("a fetch closure with transformed values") { (sharedExampleContext: SharedExampleContext) in
      var fetcher: BasicFetcher<String, String>!
      var internalFetcher: CacheLevelFake<String, Int>!
      var transformer: OneWayTransformationBox<Int, String>!
      
      beforeEach {
        fetcher = sharedExampleContext()[FetcherValueTransformationsSharedExamplesContext.FetcherToTest] as? BasicFetcher<String, String>
        internalFetcher = sharedExampleContext()[FetcherValueTransformationsSharedExamplesContext.InternalFetcher] as? CacheLevelFake<String, Int>
        transformer = sharedExampleContext()[FetcherValueTransformationsSharedExamplesContext.Transformer] as? OneWayTransformationBox<Int, String>
      }
      
      context("when calling get") {
        let key = "12"
        var successValue: String?
        var failureValue: ErrorType?
        var fakeRequest: CacheRequest<Int>!
        
        beforeEach {
          fakeRequest = CacheRequest<Int>()
          internalFetcher.cacheRequestToReturn = fakeRequest
          
          fetcher.get(key).onSuccess { successValue = $0 }.onFailure { failureValue = $0 }
        }
        
        it("should forward the call to the internal cache") {
          expect(internalFetcher.numberOfTimesCalledGet).to(equal(1))
        }
        
        it("should pass the right key") {
          expect(internalFetcher.didGetKey).to(equal(key))
        }
        
        context("when the request succeeds") {
          context("when the value can be successfully transformed") {
            let value = 101
            
            beforeEach {
              fakeRequest.succeed(value)
            }
            
            it("should call the original success closure") {
              expect(successValue).notTo(beNil())
            }
            
            it("should transform the value") {
              expect(successValue).to(equal(transformer.transform(value)))
            }
          }
          
          context("when the value transformation returns nil") {
            let value = -101
            
            beforeEach {
              successValue = nil
              fakeRequest.succeed(value)
            }
            
            it("should not call the original success closure") {
              expect(successValue).to(beNil())
            }
            
            it("should call the original failure closure") {
              expect(failureValue).notTo(beNil())
            }
            
            it("should fail with the right code") {
              expect(failureValue as? FetchError).to(equal(FetchError.ValueTransformationFailed))
            }
          }
        }
        
        context("when the request fails") {
          let errorCode = TestError.AnotherError
          
          beforeEach {
            fakeRequest.fail(errorCode)
          }
          
          it("should call the original failure closure") {
            expect(failureValue).notTo(beNil())
          }
          
          it("should fail with the right code") {
            expect(failureValue as? TestError).to(equal(errorCode))
          }
        }
      }
    }
  }
}

class FetcherValueTransformationTests: QuickSpec {
  override func spec() {
    var fetcher: BasicFetcher<String, String>!
    var internalFetcher: CacheLevelFake<String, Int>!
    var transformer: OneWayTransformationBox<Int, String>!
    let forwardTransformationClosure: Int -> String? = {
      if $0 > 0 {
        return "\($0 + 1)"
      } else {
        return nil
      }
    }
    
    describe("Value transformation using a transformer and a fetch closure, with the global function") {
      beforeEach {
        internalFetcher = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: forwardTransformationClosure)
        let fetchClosure = internalFetcher.get
        fetcher = transformValues(fetchClosure, transformer: transformer)
      }
      
      itBehavesLike("a fetch closure with transformed values") {
        [
          FetcherValueTransformationsSharedExamplesContext.FetcherToTest: fetcher,
          FetcherValueTransformationsSharedExamplesContext.InternalFetcher: internalFetcher,
          FetcherValueTransformationsSharedExamplesContext.Transformer: transformer
        ]
      }
    }
    
    describe("Value transformation using a transformer and a fetch closure, with the operator") {
      beforeEach {
        internalFetcher = CacheLevelFake<String, Int>()
        transformer = OneWayTransformationBox(transform: forwardTransformationClosure)
        let fetchClosure = internalFetcher.get
        fetcher = fetchClosure =>> transformer
      }
      
      itBehavesLike("a fetch closure with transformed values") {
        [
          FetcherValueTransformationsSharedExamplesContext.FetcherToTest: fetcher,
          FetcherValueTransformationsSharedExamplesContext.InternalFetcher: internalFetcher,
          FetcherValueTransformationsSharedExamplesContext.Transformer: transformer
        ]
      }
    }
  }
}