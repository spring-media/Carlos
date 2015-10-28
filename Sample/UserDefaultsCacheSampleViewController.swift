import Foundation
import UIKit
import Carlos

class UserDefaultsCacheSampleViewController: BaseCacheViewController {
  private var cache: NSUserDefaultsCacheLevel<String, NSData>!
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(urlKeyField?.text ?? "")
  }
  
  override func titleForScreen() -> String {
    return "User defaults cache"
  }
  
  @IBAction func clearCache(sender: AnyObject) {
    cache.clear()
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = NSUserDefaultsCacheLevel<String, NSData>()
    
    let values = [
      "test": "value".dataUsingEncoding(NSUTF8StringEncoding)!,
      "key": "another value".dataUsingEncoding(NSUTF8StringEncoding)!
    ]
    
    for (key, value) in values {
      cache.set(value, forKey: key)
    }
    
    let prepopulatingMessage = values.reduce("", combine: { accumulator, value in
      "\(accumulator)\n\(value.0): \(value.1)"
    })
    
    self.eventsLogView.text = "\(self.eventsLogView.text)Prepopulating the cache:\n\(prepopulatingMessage)\n"
  }
}