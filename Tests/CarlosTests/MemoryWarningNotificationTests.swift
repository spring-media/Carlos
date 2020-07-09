import Foundation
import Quick
import Nimble
import Carlos

#if !os(macOS)
import UIKit

class MemoryWarningNotificationTests: QuickSpec {
  override func spec() {
    describe("Memory warning listener") {
      var cache: CacheLevelFake<String, Int>!
      var token: NSObjectProtocol!
      
      beforeEach {
        cache = CacheLevelFake<String, Int>()
      }
      
      context("when listening to memory warnings") {
        beforeEach {
          token = cache.listenToMemoryWarnings()
        }
        
        context("when posting memory warnings") {
          beforeEach {
            NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
          }
          
          it("should call onMemoryWarning on the cache") {
            expect(cache.numberOfTimesCalledOnMemoryWarning).to(equal(1))
          }
          
          it("should not directly call clear") {
            expect(cache.numberOfTimesCalledClear).to(equal(0))
          }
        }
        
        context("when unsubscribing later") {
          beforeEach {
            unsubscribeToMemoryWarnings(token)
          }
          
          context("when posting memory warnings") {
            beforeEach {
              NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
            }
            
            it("should not call onMemoryWarning on the cache") {
              expect(cache.numberOfTimesCalledOnMemoryWarning).to(equal(0))
            }
            
            it("should not call clear") {
              expect(cache.numberOfTimesCalledClear).to(equal(0))
            }
          }
        }
      }
      
      context("by default, posting memory warning notifications") {
        beforeEach {
          NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }
        
        it("should not call clear") {
          expect(cache.numberOfTimesCalledClear).to(equal(0))
        }
        
        it("should not call onMemoryWarning") {
          expect(cache.numberOfTimesCalledOnMemoryWarning).to(equal(0))
        }
      }
    }
  }
}
#endif
