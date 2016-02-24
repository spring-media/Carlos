import Foundation
import Quick
import Nimble
import Carlos
import CarlosFutures

struct TwoWayTransformationBoxSharedExamplesContext {
  static let TransformerToTest = "transformer"
}

class TwoWayTransformationBoxSharedExamplesConfiguration: QuickConfiguration {
  override class func configure(configuration: Configuration) {
    sharedExamples("an inverted two-way transformation box") { (sharedExampleContext: SharedExampleContext) in
      var invertedBox: TwoWayTransformationBox<String, NSURL>!
      var error: ErrorType!
      
      beforeEach {
        error = nil
        
        invertedBox = sharedExampleContext()[TwoWayTransformationBoxSharedExamplesContext.TransformerToTest] as? TwoWayTransformationBox<String, NSURL>
      }
      
      context("when using the transformation") {
        var result: NSURL!
        
        beforeEach {
          result = nil
        }
        
        context("if the transformation is possible") {
          let originString = "http://github.com/WeltN24/Carlos"
          
          beforeEach {
            invertedBox.transform(originString)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should call the success closure") {
            expect(result).notTo(beNil())
          }
          
          it("should not call the failure closure") {
            expect(error).to(beNil())
          }
          
          it("should return the expected result") {
            expect(result?.absoluteString).to(equal(originString))
          }
        }
        
        context("if the transformation is not possible") {
          beforeEach {
            invertedBox.transform("not an URL")
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should call the error closure") {
            expect(error).notTo(beNil())
          }
          
          it("should not call the success closure") {
            expect(result).to(beNil())
          }
          
          it("should pass the right error") {
            expect(error as? TestError).to(equal(TestError.AnotherError))
          }
        }
      }
      
      context("when using the inverse transformation") {
        var result: String!
            
        beforeEach {
          result = nil
        }
        
        context("when the transformation is possible") {
          let originURL = NSURL(string: "http://github.com/WeltN24/Carlos")!
          
          beforeEach {
            invertedBox.inverseTransform(originURL)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should call the success closure") {
            expect(result).notTo(beNil())
          }
          
          it("should not call the failure closure") {
            expect(error).to(beNil())
          }
          
          it("should return the expected result") {
            expect(result).to(equal(originURL.absoluteString))
          }
        }
        
        context("when the transformation is not possible") {
          beforeEach {
            invertedBox.inverseTransform(NSURL(string: "ftp://test")!)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should call the error closure") {
            expect(error).notTo(beNil())
          }
            
          it("should not call the success closure") {
            expect(result).to(beNil())
          }
          
          it("should pass the right error") {
            expect(error as? TestError).to(equal(TestError.AnotherError))
          }
        }
      }
    }
  }
}

class TwoWayTransformationBoxTests: QuickSpec {
  override func spec() {
    describe("TwoWayTransformationBox") {
      var box: TwoWayTransformationBox<NSURL, String>!
      var error: ErrorType!
      
      beforeEach {
        error = nil
  
        box = TwoWayTransformationBox<NSURL, String>(transform: {
          let possible = $0.scheme == "http"
          
          return Promise(value: possible ? $0.absoluteString : nil, error: TestError.AnotherError).future
        }, inverseTransform: {
          Promise(value: NSURL(string: $0), error: TestError.AnotherError).future
        })
      }
      
      context("when using the transformation") {
        var result: String!
            
        beforeEach {
          result = nil
        }
        
        context("when the transformation is possible") {
          let originURL = NSURL(string: "http://github.com/WeltN24/Carlos")!
          
          beforeEach {
            box.transform(originURL)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should call the success closure") {
            expect(result).notTo(beNil())
          }
          
          it("should not call the failure closure") {
            expect(error).to(beNil())
          }
          
          it("should return the expected result") {
            expect(result).to(equal(originURL.absoluteString))
          }
        }
        
        context("when the transformation is not possible") {
          beforeEach {
            box.transform(NSURL(string: "ftp://whatever")!)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should not call the success closure") {
            expect(result).to(beNil())
          }
          
          it("should call the error closure") {
            expect(error).notTo(beNil())
          }
          
          it("should pass the right error") {
            expect(error as? TestError).to(equal(TestError.AnotherError))
          }
        }
      }
      
      context("when using the inverse transformation") {
        var result: NSURL!
            
        beforeEach {
          result = nil
        }
        
        context("when the transformation is possible") {
          let originString = "http://github.com/WeltN24/Carlos"
          
          beforeEach {
            box.inverseTransform(originString)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
        
          it("should call the success closure") {
            expect(result).notTo(beNil())
          }
          
          it("should not call the failure closure") {
                expect(error).to(beNil())
          }
          
          it("should return the expected result") {
            expect(result).to(equal(NSURL(string: originString)!))
          }
        }
        
        context("when the transformation is not possible") {
          beforeEach {
            box.inverseTransform("not an URL")
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
            
          it("should not call the success closure") {
            expect(result).to(beNil())
          }
          
          it("should call the error closure") {
            expect(error).notTo(beNil())
          }
          
          it("should pass the right error") {
            expect(error as? TestError).to(equal(TestError.AnotherError))
          }
        }
      }
      
      context("when inverting the transformer") {
        var invertedBox: TwoWayTransformationBox<String, NSURL>!
        
        context("when using the global function") {
          beforeEach {
            invertedBox = invert(box)
          }
          
          itBehavesLike("an inverted two-way transformation box") {
            [
              TwoWayTransformationBoxSharedExamplesContext.TransformerToTest: invertedBox
            ]
          }
        }
        
        context("when using the protocol extension") {
          beforeEach {
            invertedBox = box.invert()
          }
          
          itBehavesLike("an inverted two-way transformation box") {
            [
              TwoWayTransformationBoxSharedExamplesContext.TransformerToTest: invertedBox
            ]
          }
        }
      }
    }
  }
}