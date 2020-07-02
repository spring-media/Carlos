import UIKit
import Carlos
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

enum SampleError: Error {
  case invalidJSON
}

class ViewController: UIViewController {
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let JSONFetcher: BasicFetcher<URL, AnyObject> =  NetworkFetcher().transformValues(JSONTransformer())
    let cache = JSONFetcher.transformValues(BTCTransformer())
    
    cache.get(URL(string: "http://coinabul.com/api.php")!).onSuccess { result in
      print("Bitcoin value is \(result.USDValue) USD")
    }
  }
}

struct BTCTransformer: OneWayTransformer {
  func transform(_ val: AnyObject) -> Future<BitcoinResult> {
    let result = Promise<BitcoinResult>()
    
    if let JSON = val as? [String: AnyObject],
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
}
