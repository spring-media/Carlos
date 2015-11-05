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
  enum Error: ErrorType {
    case InvalidJSON
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let JSONFetcher: BasicFetcher<NSURL, AnyObject> = NetworkFetcher() =>> JSONTransformer()
    let cache = JSONFetcher =>> { (JSONResult: AnyObject) -> Future<BitcoinResult> in
      let result = Promise<BitcoinResult>()
      
      if let JSON = JSONResult as? [String: AnyObject],
        let BTCDict = JSON["BTC"] as? [String: AnyObject],
        let USDStringValue = BTCDict["USD"] as? String,
        let USDFloatValue = Float(USDStringValue)
      {
        result.succeed(BitcoinResult(USDValue: USDFloatValue))
      } else {
        result.fail(Error.InvalidJSON)
      }
      
      return result.future
    }
    
    cache.get(NSURL(string: "http://coinabul.com/api.php")!).onSuccess { result in
      print("Bitcoin value is \(result.USDValue) USD")
    }
  }
}

