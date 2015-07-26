import Foundation
import Quick
import Nimble
import Carlos

class CacheRequestTests: QuickSpec {
  override func spec() {
    describe("CacheRequest") {
      var request: CacheRequest<String>!
      var successSentinels: [String?]!
      var failureSentinels: [NSError?]!
      
      context("when initialized with the empty initializer") {
        beforeEach {
          request = CacheRequest<String>()
          
          successSentinels = [nil, nil, nil]
          failureSentinels = [nil, nil, nil]
        }
        
        context("when calling onSuccess") {
          beforeEach {
            for idx in 0..<successSentinels.count {
              request.onSuccess({ result in
                successSentinels[idx] = result
              })
            }
          }
          
          it("should not immediately call the closures") {
            expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
          }
          
          context("when calling succeed") {
            let value = "success value"
            
            beforeEach {
              request.succeed(value)
            }
            
            it("should call the closures") {
              expect(successSentinels).to(allPass({ $0! == value }))
            }
            
            context("when calling onSuccess again") {
              var subsequentSuccessSentinel: String?
              
              beforeEach {
                request.onSuccess({ result in
                  subsequentSuccessSentinel = result
                })
              }
              
              it("should immediately call the closures") {
                expect(subsequentSuccessSentinel).to(equal(value))
              }
            }
          }
          
          context("when calling fail") {
            beforeEach {
              request.fail(nil)
            }
            
            it("should not call any success closure") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
            }
          }
        }
        
        context("when calling onFailure") {
          beforeEach {
            for idx in 0..<successSentinels.count {
              request.onFailure({ error in
                failureSentinels[idx] = error
              })
            }
          }
          
          it("should not immediately call the closures") {
            expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
          }
          
          context("when calling fail") {
            let errorCode = -1100
            
            beforeEach {
              request.fail(NSError(domain: "test", code: errorCode, userInfo: nil))
            }
            
            it("should call the closures") {
              expect(failureSentinels).to(allPass({ $0!?.code == errorCode }))
            }
            
            context("when calling onFailure again") {
              var subsequentFailureSentinel: NSError?
              
              beforeEach {
                request.onFailure({ error in
                  subsequentFailureSentinel = error
                })
              }
              
              it("should immediately call the closures") {
                expect(subsequentFailureSentinel?.code).to(equal(errorCode))
              }
            }
          }
          
          context("when calling succeed") {
            beforeEach {
              request.succeed("test")
            }
            
            it("should not call any closure") {
              expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
            }
          }
        }
      }
      
      context("when initialized with a value") {
        let value = "this is a sync success value"
        
        beforeEach {
          request = CacheRequest(value: value)
          
          successSentinels = [nil, nil, nil]
          failureSentinels = [nil, nil, nil]
        }
        
        context("when calling onSuccess") {
          beforeEach {
            for idx in 0..<successSentinels.count {
              request.onSuccess({ result in
                successSentinels[idx] = result
              })
            }
          }
          
          it("should immediately call the closures") {
            expect(successSentinels.filter({ $0 != nil }).count).to(equal(successSentinels.count))
          }
          
          it("should pass the right value") {
            expect(successSentinels).to(allPass({ $0! == value }))
          }
        }
        
        context("when calling onFailure") {
          beforeEach {
            for idx in 0..<successSentinels.count {
              request.onFailure({ error in
                failureSentinels[idx] = error
              })
            }
          }
          
          it("should not call the closures") {
            expect(failureSentinels.filter({ $0 == nil }).count).to(equal(failureSentinels.count))
          }
        }
      }
      
      context("when initialized with an error") {
        context("when the error is not nil") {
          let error = NSError(domain: "Test", code: 10, userInfo: nil)
          
          beforeEach {
            request = CacheRequest<String>(error: error)
            
            successSentinels = [nil, nil, nil]
            failureSentinels = [nil, nil, nil]
          }
          
          context("when calling onSuccess") {
            beforeEach {
              for idx in 0..<successSentinels.count {
                request.onSuccess({ result in
                  successSentinels[idx] = result
                })
              }
            }
            
            it("should not call the closures") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
            }
          }
          
          context("when calling onFailure") {
            beforeEach {
              for idx in 0..<successSentinels.count {
                request.onFailure({ error in
                  failureSentinels[idx] = error
                })
              }
            }
            
            it("should immediately call the closures") {
              expect(failureSentinels.filter({ $0 != nil }).count).to(equal(failureSentinels.count))
            }
            
            it("should pass the right error") {
              expect(failureSentinels).to(allPass({ $0!!.code == error.code }))
            }
          }
        }
        
        context("when the error is nil") {
          var failureSentinels: [Bool?]!
      
          beforeEach {
            request = CacheRequest<String>(error: nil)
            
            successSentinels = [nil, nil, nil]
            failureSentinels = [nil, nil, nil]
          }
          
          context("when calling onSuccess") {
            beforeEach {
              for idx in 0..<successSentinels.count {
                request.onSuccess({ result in
                  successSentinels[idx] = result
                })
              }
            }
            
            it("should not call the closures") {
              expect(successSentinels.filter({ $0 == nil }).count).to(equal(successSentinels.count))
            }
          }
          
          context("when calling onFailure") {
            beforeEach {
              for idx in 0..<successSentinels.count {
                request.onFailure({ error in
                  failureSentinels[idx] = true
                })
              }
            }
            
            it("should immediately call the closures") {
              expect(failureSentinels.filter({ $0 != nil }).count).to(equal(failureSentinels.count))
            }
          }
        }
      }
    }
  }
}