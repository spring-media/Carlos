import Foundation
import UIKit
import Carlos

class MemoryWarningSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, NSData>!
  private var token: NSObjectProtocol?
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField?.text ?? "")!)
  }
  
  override func titleForScreen() -> String {
    return "Memory warnings"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = simpleCache()
  }
  
  @IBAction func memoryWarningSwitchValueChanged(sender: UISwitch) {
    if sender.on && token == nil {
      token = cache.listenToMemoryWarnings()
    } else if let token = token where !sender.on {
      unsubscribeToMemoryWarnings(token)
      self.token = nil
    }
  }
  
  @IBAction func simulateMemoryWarning(sender: AnyObject) {
    NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidReceiveMemoryWarningNotification, object: nil)
  }
}