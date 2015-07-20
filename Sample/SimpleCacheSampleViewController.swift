import Foundation
import UIKit
import Carlos

class SimpleCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, NSData>!
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField.text)!)
  }
  
  override func titleForScreen() -> String {
    return "Simple cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    cache = simpleCache()
  }
}