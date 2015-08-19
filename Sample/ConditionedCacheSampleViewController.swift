import Foundation
import UIKit
import Carlos

enum ConditionError: ErrorType {
  case GlobalKillSwitch
  case URLScheme
  
  func toString() -> String {
    switch self {
    case .GlobalKillSwitch:
      return "Global kill switch is on"
    case .URLScheme:
      return "URL Scheme is not HTTP"
    }
  }
}

class ConditionedCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, NSData>!
  private var globalKillSwitch = false
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField?.text ?? "")!)
      .onFailure { errorThrowing in
        self.eventsLogView.text = "\(self.eventsLogView.text)Failed because of condition\n"
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
    
    cache = { (key) -> (Bool, ErrorType?) in
      if self.globalKillSwitch {
        return (false, ConditionError.GlobalKillSwitch)
      } else if key.scheme != "http" {
        return (false, ConditionError.URLScheme)
      } else {
        return (true, nil)
      }
    } <?> simpleCache()
  }
}