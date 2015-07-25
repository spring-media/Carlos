import Foundation
import UIKit
import Carlos

class DelayedNetworkFetcher: NetworkFetcher {
  private static let delay = dispatch_time(DISPATCH_TIME_NOW,
    Int64(2 * Double(NSEC_PER_SEC))) // 2 seconds
  
  override func get(key: KeyType) -> CacheRequest<OutputType> {
    let request = CacheRequest<OutputType>()
    
    super.get(key)
      .onSuccess({ value in
        dispatch_after(DelayedNetworkFetcher.delay, dispatch_get_main_queue()) {
          request.succeed(value)
        }
    })
      .onFailure({ error in
        dispatch_after(DelayedNetworkFetcher.delay, dispatch_get_main_queue()) {
          request.fail(error)
        }
    })
    
    return request
  }
}

class PooledCacheSampleViewController: BaseCacheViewController {
  private var cache: PoolCache<BasicCache<NSURL, NSData>>!
  
  override func fetchRequested() {
    super.fetchRequested()
    let timestamp = NSDate().timeIntervalSince1970
    self.eventsLogView.text = "\(self.eventsLogView.text)Request timestamp: \(timestamp)\n"
    cache.get(NSURL(string: urlKeyField?.text ?? "")!).onSuccess({ value in
      self.eventsLogView.text = "\(self.eventsLogView.text)Request with timestamp \(timestamp) succeeded\n"
    })
  }
  
  override func titleForScreen() -> String {
    return "Pooled cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = pooled(({ (input: NSURL) -> String in
      input.absoluteString!
    } =>> (MemoryCacheLevel() >>> DiskCacheLevel())) >>> DelayedNetworkFetcher())
  }
}