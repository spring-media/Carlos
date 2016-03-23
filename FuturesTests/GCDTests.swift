import Foundation
import Quick
import Nimble
import PiedPiper

var kCurrentQueue = 0

func getMutablePointer (object: AnyObject) -> UnsafeMutablePointer<Void> {
  return UnsafeMutablePointer<Void>(bitPattern: Int(ObjectIdentifier(object).uintValue))
}

func currentQueueSpecific() -> UnsafeMutablePointer<Void> {
  return dispatch_get_specific(&kCurrentQueue)
}

//FIXME: Tests checking the queueSpecific don't work properly?
class GCDTests: QuickSpec {
  override func spec() {
    describe("GCD") {
      var queueSpecific: UnsafeMutablePointer<Void>!
      
      context("when running some code on the main queue") {
        beforeEach {
          GCD.main {
            queueSpecific = currentQueueSpecific()
          }
        }
        
        xit("should run the block on the main queue") {
          expect(queueSpecific).toEventually(equal(getMutablePointer(dispatch_get_main_queue())))
        }
      }
      
      context("when running some code on a background queue") {
        beforeEach {
          GCD.background {
            queueSpecific = currentQueueSpecific()
          }
        }
        
        xit("should run the block on the background queue") {
          expect(queueSpecific).toEventually(equal(getMutablePointer(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))))
        }
      }
      
      context("when creating a serial queue") {
        var reference: GCDQueue!
        
        beforeEach {
          reference = GCD.serial("test")
        }
        
        context("when executing two blocks of code") {
          var timestamp1: NSTimeInterval!
          var timestamp2: NSTimeInterval!
          
          beforeEach {
            reference.async {
              timestamp1 = NSDate().timeIntervalSince1970
            }
            
            reference.async {
              timestamp2 = NSDate().timeIntervalSince1970
            }
          }
          
          it("should execute the first block before the second") {
            expect(timestamp2).toEventually(beGreaterThan(timestamp1))
          }
        }
      }
      
      context("when initialized with a custom queue") {
        var queue: dispatch_queue_t!
        var reference: GCDQueue!
        
        beforeEach {
          queue = dispatch_queue_create("custom", DISPATCH_QUEUE_CONCURRENT)
          reference = GCD(queue: queue)
        }
        
        context("when executing some code on it") {
          beforeEach {
            reference.async {
              queueSpecific = currentQueueSpecific()
            }
          }
          
          xit("should run the code on the right queue") {
            expect(queueSpecific).toEventually(equal(getMutablePointer(queue)))
          }
        }
      }
    }
  }
}