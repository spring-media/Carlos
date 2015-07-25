import Foundation
import UIKit
import Carlos

class ConditionedCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, NSData>!
  private var globalKillSwitch = false
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField?.text ?? "")!).onFailure { error in
      if let error = error {
        self.eventsLogView.text = "\(self.eventsLogView.text)Failed because of condition: \"\(error.localizedDescription)\"\n"
      }
    }
  }
  
  override func titleForScreen() -> String {
    return "Conditioned cache"
  }
  
  @IBAction func killSwitchValueChanged(sender: UISwitch) {
    globalKillSwitch = sender.on
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = { (key) -> (Bool, NSError?) in
      if self.globalKillSwitch {
        return (false, NSError(domain: "ConditionedCache", code: -10, userInfo: [
            NSLocalizedDescriptionKey: "Global kill switch is on"
          ]))
      } else if key.scheme != "http" {
        return (false, NSError(domain: "ConditionedCache", code: -11, userInfo: [
            NSLocalizedDescriptionKey: "URL Scheme is not HTTP"
          ]))
      } else {
        return (true, nil)
      }
    } <?> simpleCache()
  }
}