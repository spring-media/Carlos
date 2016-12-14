import Foundation
import UIKit
import Carlos

class UserDefaultsCacheSampleViewController: BaseCacheViewController {
  private var cache: NSUserDefaultsCacheLevel<String, NSData>!
  
  override func fetchRequested() {
    super.fetchRequested()
    
    _ = cache.get(urlKeyField?.text ?? "")
  }
  
  override func titleForScreen() -> String {
    return "User defaults cache"
  }
  
  @IBAction func clearCache(_ sender: AnyObject) {
    cache.clear()
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = NSUserDefaultsCacheLevel<String, NSData>()
    
    let values = [
      "test": "value".data(using: String.Encoding.utf8)!,
      "key": "another value".data(using: String.Encoding.utf8)!
    ]
    
    for (key, value) in values {
      cache.set(value as NSData, forKey: key)
    }
    
    let prepopulatingMessage = values.reduce("", { accumulator, value in
      "\(accumulator)\n\(value.0): \(value.1)"
    })
    
    self.eventsLogView.text = "\(self.eventsLogView.text!)Prepopulating the cache:\n\(prepopulatingMessage)\n"
  }
}
