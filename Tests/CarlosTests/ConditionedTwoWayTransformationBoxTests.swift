//import Foundation
//import Carlos
//import Quick
//import Nimble
//import PiedPiper
//
//class ConditionedTwoWayTransformationBoxTests: QuickSpec {
//  override func spec() {
//    describe("Conditioned two-way transformation box") {
//      var box: ConditionedTwoWayTransformationBox<Int, NSURL, String>!
//      var error: Error!
//      
//      context("when created through closures") {
//        beforeEach {
//          error = nil
//          
//          box = ConditionedTwoWayTransformationBox<Int, NSURL, String>(conditionalTransformClosure: { (key, value) in
//            if key > 0 {
//              let possible = value.scheme == "http"
//              
//              return Future(value: possible ? value.absoluteString : nil, error: TestError.simpleError)
//            } else {
//              return Future(TestError.anotherError)
//            }
//          }, conditionalInverseTransformClosure: { (key, value) in
//            if key > 0 {
//              return Future(value: NSURL(string: value), error: TestError.simpleError)
//            } else {
//              return Future(TestError.anotherError)
//            }
//          })
//        }
//        
//        context("when calling the conditional transformation") {
//          var result: String!
//          
//          beforeEach {
//            result = nil
//          }
//          
//          context("if the transformation is possible") {
//            let expectedResult = "http://www.google.de?test=1"
//            
//            beforeEach {
//              box.conditionalTransform(key: 1, value: NSURL(string: expectedResult)!)
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should call the success closure") {
//              expect(result).notTo(beNil())
//            }
//            
//            it("should not call the failure closure") {
//              expect(error).to(beNil())
//            }
//            
//            it("should return the expected result") {
//              expect(result).to(equal(expectedResult))
//            }
//          }
//          
//          context("if the transformation is not possible") {
//            beforeEach {
//              box.conditionalTransform(key: 1, value: NSURL(string: "ftp://google.de/robots.txt")!)
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should not call the success closure") {
//              expect(result).to(beNil())
//            }
//            
//            it("should call the failure closure") {
//              expect(error).notTo(beNil())
//            }
//            
//            it("should pass the right error") {
//              expect(error as? TestError).to(equal(TestError.simpleError))
//            }
//          }
//          
//          context("if the key doesn't satisfy the condition") {
//            beforeEach {
//              box.conditionalTransform(key: -1, value: NSURL(string: "http://google.de/robots.txt")!)
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should not call the success closure") {
//              expect(result).to(beNil())
//            }
//            
//            it("should call the failure closure") {
//              expect(error).notTo(beNil())
//            }
//            
//            it("should pass the right error") {
//              expect(error as? TestError).to(equal(TestError.anotherError))
//            }
//          }
//        }
//        
//        context("when calling the conditional inverse transformation") {
//          var result: NSURL!
//          
//          beforeEach {
//            result = nil
//          }
//          
//          context("if the transformation is possible") {
//            let usedString = "http://www.google.de?test=1"
//            
//            beforeEach {
//              box.conditionalInverseTransform(key: 1, value: usedString)
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should call the success closure") {
//              expect(result).notTo(beNil())
//            }
//            
//            it("should not call the failure closure") {
//              expect(error).to(beNil())
//            }
//            
//            it("should return the expected result") {
//              expect(result).to(equal(NSURL(string: usedString)!))
//            }
//          }
//          
//          context("if the transformation is not possible") {
//            beforeEach {
//              box.conditionalInverseTransform(key: 1, value: "this is not a valid URL :'(")
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should not call the success closure") {
//              expect(result).to(beNil())
//            }
//            
//            it("should call the failure closure") {
//              expect(error).notTo(beNil())
//            }
//            
//            it("should pass the right error") {
//              expect(error as? TestError).to(equal(TestError.simpleError))
//            }
//          }
//          
//          context("if the key doesn't satisfy the condition") {
//            beforeEach {
//              box.conditionalInverseTransform(key: -1, value: "http://validurl.de")
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should not call the success closure") {
//              expect(result).to(beNil())
//            }
//            
//            it("should call the failure closure") {
//              expect(error).notTo(beNil())
//            }
//            
//            it("should pass the right error") {
//              expect(error as? TestError).to(equal(TestError.anotherError))
//            }
//          }
//        }
//        
//        context("when inverting the transformer") {
//          var invertedBox: ConditionedTwoWayTransformationBox<Int, String, NSURL>!
//          
//          beforeEach {
//            invertedBox = box.invert()
//          }
//          
//          context("when calling the inverse transformation") {
//            var result: String!
//            
//            beforeEach {
//              result = nil
//            }
//            
//            context("if the transformation is possible") {
//              let expectedResult = "http://www.google.de?test=1"
//              
//              beforeEach {
//                invertedBox.conditionalInverseTransform(key: 1, value: NSURL(string: expectedResult)!)
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should call the success closure") {
//                expect(result).notTo(beNil())
//              }
//              
//              it("should not call the failure closure") {
//                expect(error).to(beNil())
//              }
//              
//              it("should return the expected result") {
//                expect(result).to(equal(expectedResult))
//              }
//            }
//            
//            context("if the transformation is not possible") {
//              beforeEach {
//                invertedBox.conditionalInverseTransform(key: 1, value: NSURL(string: "ftp://google.de/robots.txt")!)
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should not call the success closure") {
//                expect(result).to(beNil())
//              }
//              
//              it("should call the failure closure") {
//                expect(error).notTo(beNil())
//              }
//              
//              it("should pass the right error") {
//                expect(error as? TestError).to(equal(TestError.simpleError))
//              }
//            }
//            
//            context("if the key doesn't satisfy the condition") {
//              beforeEach {
//                invertedBox.conditionalInverseTransform(key: -1, value: NSURL(string: "http://google.de/robots.txt")!)
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should not call the success closure") {
//                expect(result).to(beNil())
//              }
//              
//              it("should call the failure closure") {
//                expect(error).notTo(beNil())
//              }
//              
//              it("should pass the right error") {
//                expect(error as? TestError).to(equal(TestError.anotherError))
//              }
//            }
//          }
//          
//          context("when calling the conditional transformation") {
//            var result: NSURL!
//            
//            beforeEach {
//              result = nil
//            }
//            
//            context("if the transformation is possible") {
//              let usedString = "http://www.google.de?test=1"
//              
//              beforeEach {
//                invertedBox.conditionalTransform(key: 1, value: usedString)
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should call the success closure") {
//                expect(result).notTo(beNil())
//              }
//              
//              it("should not call the failure closure") {
//                expect(error).to(beNil())
//              }
//              
//              it("should return the expected result") {
//                expect(result).to(equal(NSURL(string: usedString)!))
//              }
//            }
//            
//            context("if the transformation is not possible") {
//              beforeEach {
//                invertedBox.conditionalTransform(key: 1, value: "this is not a valid URL :'(")
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should not call the success closure") {
//                expect(result).to(beNil())
//              }
//              
//              it("should call the failure closure") {
//                expect(error).notTo(beNil())
//              }
//              
//              it("should pass the right error") {
//                expect(error as? TestError).to(equal(TestError.simpleError))
//              }
//            }
//            
//            context("if the key doesn't satisfy the condition") {
//              beforeEach {
//                invertedBox.conditionalTransform(key: -1, value: "http://validurl.de")
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should not call the success closure") {
//                expect(result).to(beNil())
//              }
//              
//              it("should call the failure closure") {
//                expect(error).notTo(beNil())
//              }
//              
//              it("should pass the right error") {
//                expect(error as? TestError).to(equal(TestError.anotherError))
//              }
//            }
//          }
//        }
//      }
//      
//      context("when created through a 2-way transformer") {
//        var originalTransformer: TwoWayTransformationBox<NSURL, String>!
//        
//        beforeEach {
//          error = nil
//          originalTransformer = TwoWayTransformationBox(transform: { (value) in
//            let possible = value.scheme == "http"
//            
//            return Future(value: possible ? value.absoluteString : nil, error: TestError.simpleError)
//          }, inverseTransform: { (value) in
//              return Future(value: NSURL(string: value), error: TestError.simpleError)
//          })
//          
//          box = ConditionedTwoWayTransformationBox<Int, NSURL, String>(transformer: originalTransformer)
//        }
//        
//        context("when calling the conditional transformation") {
//          var result: String!
//          
//          beforeEach {
//            result = nil
//          }
//          
//          context("if the transformation is possible") {
//            let expectedResult = "http://www.google.de?test=1"
//            
//            beforeEach {
//              box.conditionalTransform(key: -1, value: NSURL(string: expectedResult)!)
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should call the success closure") {
//              expect(result).notTo(beNil())
//            }
//            
//            it("should not call the failure closure") {
//              expect(error).to(beNil())
//            }
//            
//            it("should return the expected result") {
//              expect(result).to(equal(expectedResult))
//            }
//          }
//          
//          context("if the transformation is not possible") {
//            beforeEach {
//              box.conditionalTransform(key: 1, value: NSURL(string: "ftp://google.de/robots.txt")!)
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should not call the success closure") {
//              expect(result).to(beNil())
//            }
//            
//            it("should call the failure closure") {
//              expect(error).notTo(beNil())
//            }
//            
//            it("should pass the right error") {
//              expect(error as? TestError).to(equal(TestError.simpleError))
//            }
//          }
//        }
//        
//        context("when calling the conditional inverse transformation") {
//          var result: NSURL!
//          
//          beforeEach {
//            result = nil
//          }
//          
//          context("if the transformation is possible") {
//            let usedString = "http://www.google.de?test=1"
//            
//            beforeEach {
//              box.conditionalInverseTransform(key: -1, value: usedString)
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should call the success closure") {
//              expect(result).notTo(beNil())
//            }
//            
//            it("should not call the failure closure") {
//              expect(error).to(beNil())
//            }
//            
//            it("should return the expected result") {
//              expect(result).to(equal(NSURL(string: usedString)!))
//            }
//          }
//          
//          context("if the transformation is not possible") {
//            beforeEach {
//              box.conditionalInverseTransform(key: 1, value: "this is not a valid URL :'(")
//                .onSuccess({ result = $0 })
//                .onFailure({ error = $0 })
//            }
//            
//            it("should not call the success closure") {
//              expect(result).to(beNil())
//            }
//            
//            it("should call the failure closure") {
//              expect(error).notTo(beNil())
//            }
//            
//            it("should pass the right error") {
//              expect(error as? TestError).to(equal(TestError.simpleError))
//            }
//          }
//        }
//        
//        context("when inverting the transformer") {
//          var invertedBox: ConditionedTwoWayTransformationBox<Int, String, NSURL>!
//          
//          beforeEach {
//            invertedBox = box.invert()
//          }
//          
//          context("when calling the inverse transformation") {
//            var result: String!
//            
//            beforeEach {
//              result = nil
//            }
//            
//            context("if the transformation is possible") {
//              let expectedResult = "http://www.google.de?test=1"
//              
//              beforeEach {
//                invertedBox.conditionalInverseTransform(key: 1, value: NSURL(string: expectedResult)!)
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should call the success closure") {
//                expect(result).notTo(beNil())
//              }
//              
//              it("should not call the failure closure") {
//                expect(error).to(beNil())
//              }
//              
//              it("should return the expected result") {
//                expect(result).to(equal(expectedResult))
//              }
//            }
//            
//            context("if the transformation is not possible") {
//              beforeEach {
//                invertedBox.conditionalInverseTransform(key: 1, value: NSURL(string: "ftp://google.de/robots.txt")!)
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should not call the success closure") {
//                expect(result).to(beNil())
//              }
//              
//              it("should call the failure closure") {
//                expect(error).notTo(beNil())
//              }
//              
//              it("should pass the right error") {
//                expect(error as? TestError).to(equal(TestError.simpleError))
//              }
//            }
//          }
//          
//          context("when calling the conditional transformation") {
//            var result: NSURL!
//            
//            beforeEach {
//              result = nil
//            }
//            
//            context("if the transformation is possible") {
//              let usedString = "http://www.google.de?test=1"
//              
//              beforeEach {
//                invertedBox.conditionalTransform(key: 1, value: usedString)
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should call the success closure") {
//                expect(result).notTo(beNil())
//              }
//              
//              it("should not call the failure closure") {
//                expect(error).to(beNil())
//              }
//              
//              it("should return the expected result") {
//                expect(result).to(equal(NSURL(string: usedString)!))
//              }
//            }
//            
//            context("if the transformation is not possible") {
//              beforeEach {
//                invertedBox.conditionalTransform(key: 1, value: "this is not a valid URL :'(")
//                  .onSuccess({ result = $0 })
//                  .onFailure({ error = $0 })
//              }
//              
//              it("should not call the success closure") {
//                expect(result).to(beNil())
//              }
//              
//              it("should call the failure closure") {
//                expect(error).notTo(beNil())
//              }
//              
//              it("should pass the right error") {
//                expect(error as? TestError).to(equal(TestError.simpleError))
//              }
//            }
//          }
//        }
//      }
//    }
//  }
//}
