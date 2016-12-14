import Foundation
import UIKit
import Carlos

class PooledCacheSampleViewController: BaseCacheViewController {
  private var cache: PoolCache<BasicCache<URL, NSData>>!
  
  override func fetchRequested() {
    super.fetchRequested()
    let timestamp = Date().timeIntervalSince1970
    self.eventsLogView.text = "\(self.eventsLogView.text)Request timestamp: \(timestamp)\n"
    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .onSuccess { value in
        self.eventsLogView.text = "\(self.eventsLogView.text)Request with timestamp \(timestamp) succeeded\n"
      }
  }
  
  override func titleForScreen() -> String {
    return "Pooled cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = delayedNetworkCache().pooled()
  }
}
