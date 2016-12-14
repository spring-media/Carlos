import Foundation
import UIKit
import Carlos

class SwitchCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, NSData>!
  
  override func fetchRequested() {
    super.fetchRequested()
    
    _ = cache.get(URL(string: urlKeyField?.text ?? "")!)
  }
  
  override func titleForScreen() -> String {
    return "Switched caches"
  }
  
  override func setupCache() {
    super.setupCache()
    
    let lane1 = MemoryCacheLevel<URL, NSData>()
    lane1.set(("Yes, this is hitting the memory cache now".data(using: .utf8, allowLossyConversion: false) as NSData?)!, forKey: URL(string: "test")!)
    lane1.set(("Carlos lets you create quite complex cache infrastructures".data(using: .utf8, allowLossyConversion: false) as NSData?)!, forKey: URL(string: "carlos")!)
    
    let lane2 = CacheProvider.dataCache()
    
    cache = switchLevels(cacheA: lane1, cacheB: lane2, switchClosure: { key in
      if key.scheme == "http" {
        return .cacheB
      } else {
        return .cacheA
      }
    })
  }
}
