import Carlos
import Foundation
import UIKit

class MemoryWarningSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, NSData>!
  private var token: NSObjectProtocol?

  override func fetchRequested() {
    super.fetchRequested()

    _ = cache.get(URL(string: urlKeyField?.text ?? "")!)
  }

  override func titleForScreen() -> String {
    "Memory warnings"
  }

  override func setupCache() {
    super.setupCache()

    cache = simpleCache()
  }

  @IBAction func memoryWarningSwitchValueChanged(_ sender: UISwitch) {
    if sender.isOn, token == nil {
      token = cache.listenToMemoryWarnings()
    } else if let token = token, !sender.isOn {
      unsubscribeToMemoryWarnings(token)
      self.token = nil
    }
  }

  @IBAction func simulateMemoryWarning(_: AnyObject) {
    NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
  }
}
