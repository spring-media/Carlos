import Foundation
import UIKit
import Carlos

private var myContext = 0

class JSONCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<NSURL, AnyObject>!
  
  override func fetchRequested() {
    super.fetchRequested()
    
    cache.get(NSURL(string: urlKeyField?.text ?? "")!).onSuccess { JSON in
      self.eventsLogView.text = "\(self.eventsLogView.text)\nJSON Dictionary result: \(JSON as? NSDictionary)\n"
    }
    
    let progrss = NSProgress.currentProgress()
    
    progrss?.addObserver(self, forKeyPath: "fractionCompleted", options: .Initial, context: &myContext)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if context == &myContext {
      if let newValue = change?[NSKeyValueChangeNewKey] {
        print("Progress changed: \(newValue)")
      }
    } else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
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