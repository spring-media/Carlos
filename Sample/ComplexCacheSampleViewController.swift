import Foundation
import UIKit
import Carlos
import CarlosFutures

struct ModelDomain {
  let name: String
  let identifier: Int
  let URL: NSURL
}

enum IgnoreError: ErrorType {
  case Ignore
}

class CustomCacheLevel: Fetcher {
  typealias KeyType = Int
  typealias OutputType = String
  
  func get(key: KeyType) -> Future<OutputType> {
    let request = Promise<OutputType>()
    
    if key > 0 {
      Logger.log("Fetched \(key) on the custom cache", .Info)
      request.succeed("\(key)")
    } else {
      Logger.log("Failed fetching \(key) on the custom cache", .Info)
      request.fail(IgnoreError.Ignore)
    }
    
    return request.future
  }
}

class ComplexCacheSampleViewController: BaseCacheViewController {
  
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var identifierField: UITextField!
  @IBOutlet weak var urlField: UITextField!
  
  private var cache: BasicCache<ModelDomain, NSData>!
  
  override func titleForScreen() -> String {
    return "Complex cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    let modelDomainToString = OneWayTransformationBox<ModelDomain, String>(transform: {
      Promise(value: $0.name).future
    })
    
    let modelDomainToInt = OneWayTransformationBox<ModelDomain, Int>(transform: {
      Promise(value: $0.identifier).future
    })
    
    let stringToData = StringTransformer().invert()
    let uppercaseTransformer = OneWayTransformationBox<String, String>(transform: { Promise(value: $0.uppercaseString).future })
    
    cache = ((modelDomainToString =>> (MemoryCacheLevel() >>> DiskCacheLevel())) >>> (modelDomainToInt =>> (CustomCacheLevel() ~>> uppercaseTransformer) =>> stringToData) >>> BasicFetcher(getClosure: { (key: ModelDomain) in
      let request = Promise<NSData>()
      
      Logger.log("Fetched \(key.name) on the fetcher closure", .Info)
      
      request.succeed("Last level was hit!".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
      
      return request.future
    })).dispatch(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0))
  }
  
  override func fetchRequested() {
    super.fetchRequested()
    
    let key = ModelDomain(name: nameField.text ?? "", identifier: Int(identifierField.text ?? "") ?? 0, URL: NSURL(string: urlField.text ?? "")!)
    
    cache.get(key)
    
    for field in [nameField, identifierField, urlField] {
      field.resignFirstResponder()
    }
  }
}