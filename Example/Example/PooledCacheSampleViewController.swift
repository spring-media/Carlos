import Foundation
import UIKit

import Carlos
import Combine

final class PooledCacheSampleViewController: BaseCacheViewController {
  private var cache: PoolCache<BasicCache<URL, NSData>>!
  private var cancellables = Set<AnyCancellable>()
  
  override func fetchRequested() {
    super.fetchRequested()
    let timestamp = Date().timeIntervalSince1970
    self.eventsLogView.text = "\(self.eventsLogView.text!)Request timestamp: \(timestamp)\n"
    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .sink(receiveCompletion: { _ in }, receiveValue: { data in
        self.eventsLogView.text = "\(self.eventsLogView.text!)Request with timestamp \(timestamp) succeeded\n"
      }).store(in: &cancellables)
  }
  
  override func titleForScreen() -> String {
    return "Pooled cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = delayedNetworkCache().pooled()
  }
}
