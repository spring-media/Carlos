import UIKit
import CarlosTv

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cache = CacheProvider.JSONCache()
    
    cache.get(NSURL(string: "http://coinabul.com/api.php")!).onSuccess { result in
      if let JSON = result as? [String: AnyObject],
        let BTCDict = JSON["BTC"] as? [String: AnyObject],
        let USDStringValue = BTCDict["USD"] as? String,
        let USDFloatValue = Float(USDStringValue) {
          print("Bitcoin value is \(USDFloatValue) USD")
      }
    }
  }
}

