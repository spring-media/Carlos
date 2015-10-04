import Foundation
import UIKit
import Carlos

class JSONCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, AnyObject>!
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField?.text ?? "")!).onSuccess { JSON in
      self.eventsLogView.text = "\(self.eventsLogView.text)\nJSON Dictionary result: \(JSON as? NSDictionary)\n"
    }
  }
  
  override func titleForScreen() -> String {
    return "JSON cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = CacheProvider.JSONCache()
  }
}