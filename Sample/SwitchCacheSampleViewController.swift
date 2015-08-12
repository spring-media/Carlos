import Foundation
import UIKit
import Carlos

class SwitchCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, NSData>!
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField?.text ?? "")!)
  }
  
  override func titleForScreen() -> String {
    return "Switched caches"
  }
  
  override func setupCache() {
    super.setupCache()
    
    let lane1 = MemoryCacheLevel<NSURL, NSData>()
    lane1.set("Yes, this is hitting the memory cache now".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: NSURL(string: "test")!)
    lane1.set("Carlos lets you create quite complex cache infrastructures".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: NSURL(string: "carlos")!)
    
    let lane2 = CacheProvider.dataCache()
    
    cache = switchLevels(lane1, lane2, { key in
      if key.scheme == "http" {
        return .CacheB
      } else {
        return .CacheA
      }
    })
  }
}