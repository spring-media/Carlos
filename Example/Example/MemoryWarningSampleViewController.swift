import Carlos
import Foundation
import UIKit
import Combine

class MemoryWarningSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, NSData>!
  private var token: NSObjectProtocol?

  var cancellable: AnyCancellable?

  override func fetchRequested() {
    super.fetchRequested()
    
    cancellable = cache.get(URL(string: urlKeyField?.text ?? "")!)
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
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
