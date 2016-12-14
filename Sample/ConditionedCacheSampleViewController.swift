import Foundation
import UIKit
import Carlos
import PiedPiper

enum ConditionError: Error {
  case globalKillSwitch
  case urlScheme
  
  func toString() -> String {
    switch self {
    case .globalKillSwitch:
      return "Global kill switch is on"
    case .urlScheme:
      return "URL Scheme is not HTTP"
    }
  }
}

class ConditionedCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, NSData>!
  private var globalKillSwitch = false
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .onFailure { errorThrowing in
        self.eventsLogView.text = "\(self.eventsLogView.text!)Failed because of condition\n"
      }
  }
  
  override func titleForScreen() -> String {
    return "Conditioned cache"
  }
  
  @IBAction func killSwitchValueChanged(_ sender: UISwitch) {
    globalKillSwitch = sender.isOn
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = simpleCache().conditioned { key -> Future<Bool> in
      let result = Promise<Bool>()
      
      if self.globalKillSwitch {
        result.fail(ConditionError.globalKillSwitch)
      } else if key.scheme != "http" {
        result.fail(ConditionError.urlScheme)
      } else {
        result.succeed(true)
      }
      
      return result.future
    }
  }
}
