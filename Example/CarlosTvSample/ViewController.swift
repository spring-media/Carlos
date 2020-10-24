import Carlos
import Combine
import UIKit

class BitcoinResult {
  let USDValue: Float

  init(USDValue: Float) {
    self.USDValue = USDValue
  }
}

extension BitcoinResult: ExpensiveObject {
  var cost: Int {
    1
  }
}

enum SampleError: Error {
  case invalidJSON
}

class ViewController: UIViewController {
  private var cancellables = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()

    let JSONFetcher: BasicFetcher<URL, AnyObject> = NetworkFetcher().transformValues(JSONTransformer())
    let cache = JSONFetcher.transformValues(BTCTransformer())

    cache.get(URL(string: "http://coinabul.com/api.php")!)
      .sink(receiveCompletion: { completion in
        print(completion)
      }, receiveValue: { result in
        print("Bitcoin value is \(result.USDValue) USD")
      }).store(in: &cancellables)
  }
}

struct BTCTransformer: OneWayTransformer {
  func transform(_ val: AnyObject) -> AnyPublisher<BitcoinResult, Error> {
    Future { promise in
      if let JSON = val as? [String: AnyObject],
        let BTCDict = JSON["BTC"] as? [String: AnyObject],
        let USDStringValue = BTCDict["USD"] as? String,
        let USDFloatValue = Float(USDStringValue)
      {
        promise(.success(BitcoinResult(USDValue: USDFloatValue)))
      } else {
        promise(.failure(SampleError.invalidJSON))
      }
    }.eraseToAnyPublisher()
  }
}
