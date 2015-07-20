import Foundation
import UIKit
import Carlos

struct ModelDomain {
  let name: String
  let identifier: Int
  let URL: NSURL
}

class CustomCacheLevel: CacheLevel {
  typealias KeyType = Int
  typealias OutputType = String
  
  func get(key: KeyType) -> CacheRequest<OutputType> {
    let request = CacheRequest<OutputType>()
    
    if key > 0 {
      Logger.log("Fetched \(key) on the custom cache", .Info)
      request.succeed("\(key)")
    } else {
      Logger.log("Failed fetching \(key) on the custom cache", .Info)
      request.fail(nil)
    }
    
    return request
  }
  
  func set(value: OutputType, forKey key: KeyType) {
    //Fake cache
  }
  
  func clear() {
    //Fake cache
  }
  
  func onMemoryWarning() {
    //Fake cache
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
    
    let modelDomainToString: ModelDomain -> String = {
      $0.name
    }
    
    let modelDomainToInt: ModelDomain -> Int = {
      $0.identifier
    }
    
    let stringToData = TwoWayTransformationBox<String, NSData>(transform: {
      $0.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }, inverseTransform: {
      NSString(data: $0, encoding: NSUTF8StringEncoding)! as String
    })
    
    cache = (modelDomainToString =>> (MemoryCacheLevel() >>> DiskCacheLevel())) >>> (modelDomainToInt =>> CustomCacheLevel() =>> stringToData) >>> { (key: ModelDomain) in
      let request = CacheRequest<NSData>()
      
      Logger.log("Fetched \(key.name) on the fetcher closure", .Info)
      
      request.succeed("Last level was hit!".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
      
      return request
    }
  }
  
  override func fetchRequested() {
    super.fetchRequested()
    
    let key = ModelDomain(name: nameField.text, identifier: identifierField.text.toInt() ?? 0, URL: NSURL(string: urlField.text)!)
    
    cache.get(key)
    
    for field in [nameField, identifierField, urlField] {
      field.resignFirstResponder()
    }
  }
}