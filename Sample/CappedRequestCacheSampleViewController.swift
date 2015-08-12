import Foundation
import UIKit
import Carlos

class CappedRequestCacheSampleViewController: BaseCacheViewController {
  private var cache: RequestCapperCache<BasicCache<NSURL, NSData>>!
  private static let RequestsCap = 3
  
  override func fetchRequested() {
    super.fetchRequested()
    
    let timestamp = NSDate().timeIntervalSince1970
    self.eventsLogView.text = "\(self.eventsLogView.text)Request timestamp: \(timestamp)\n"
    cache.get(NSURL(string: urlKeyField?.text ?? "")!)
      .onSuccess { value in
        self.eventsLogView.text = "\(self.eventsLogView.text)Request with timestamp \(timestamp) succeeded\n"
      }
  }
  
  override func titleForScreen() -> String {
    return "Capped cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = capRequests(delayedNetworkCache(), CappedRequestCacheSampleViewController.RequestsCap)
  }
}