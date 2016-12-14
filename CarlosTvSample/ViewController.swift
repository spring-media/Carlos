import UIKit
import CarlosTv
import PiedPiper

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
  enum SampleError: Error {
    case invalidJSON
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let JSONFetcher: BasicFetcher<URL, AnyObject> = NetworkFetcher() =>> JSONTransformer()
    let cache = JSONFetcher =>> { (JSONResult: AnyObject) -> Future<BitcoinResult> in
      let result = Promise<BitcoinResult>()
      
      if let JSON = JSONResult as? [String: AnyObject],
        let BTCDict = JSON["BTC"] as? [String: AnyObject],
        let USDStringValue = BTCDict["USD"] as? String,
        let USDFloatValue = Float(USDStringValue)
      {
        result.succeed(BitcoinResult(USDValue: USDFloatValue))
      } else {
        result.fail(SampleError.invalidJSON)
      }
      
      return result.future
    }
    
    cache.get(URL(string: "http://coinabul.com/api.php")!).onSuccess { result in
      print("Bitcoin value is \(result.USDValue) USD")
    }
  }
}

