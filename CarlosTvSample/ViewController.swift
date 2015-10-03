import UIKit
import CarlosTv

class BitcoinResult {
  let USDValue: Float
  
  init(USDValue: Float) {
    self.USDValue = USDValue
  }
}

extension BitcoinResult: ExpensiveObject {
  var cost: Int {
    return 1
  }
}

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let JSONFetcher: BasicFetcher<NSURL, AnyObject> = NetworkFetcher() =>> JSONTransformer()
    let cache = JSONFetcher =>> { (JSONResult: AnyObject) -> BitcoinResult? in
      let result: BitcoinResult?
      
      if let JSON = JSONResult as? [String: AnyObject],
        let BTCDict = JSON["BTC"] as? [String: AnyObject],
        let USDStringValue = BTCDict["USD"] as? String,
        let USDFloatValue = Float(USDStringValue)
      {
        result = BitcoinResult(USDValue: USDFloatValue)
      } else {
        result = nil
      }
      
      return result
    }
    
    cache.get(NSURL(string: "http://coinabul.com/api.php")!).onSuccess { result in
      print("Bitcoin value is \(result.USDValue) USD")
    }
  }
}

