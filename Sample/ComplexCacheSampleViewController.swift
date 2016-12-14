import Foundation
import UIKit
import Carlos
import PiedPiper

struct ModelDomain {
  let name: String
  let identifier: Int
  let URL: Foundation.URL
}

extension ModelDomain: StringConvertible {
  func toString() -> String {
    return "\(identifier)"
  }
}

enum IgnoreError: Error {
  case ignore
}

class CustomCacheLevel: Fetcher {
  typealias KeyType = Int
  typealias OutputType = String
  
  func get(_ key: KeyType) -> Future<OutputType> {
    let request = Promise<OutputType>()
    
    if key > 0 {
      Logger.log("Fetched \(key) on the custom cache", .Info)
      request.succeed("\(key)")
    } else {
      Logger.log("Failed fetching \(key) on the custom cache", .Info)
      request.fail(IgnoreError.ignore)
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
      Future($0.name)
    })
    
    let modelDomainToInt = OneWayTransformationBox<ModelDomain, Int>(transform: {
      Future($0.identifier)
    })
    
    let stringToData = StringTransformer().invert()
    let uppercaseTransformer = OneWayTransformationBox<String, String>(transform: { Future($0.uppercased()) })
    
    let memoryAndDisk = MemoryCacheLevel()
      .compose(DiskCacheLevel<String, NSData>())
      .transformKeys(modelDomainToString)
    let customCache = CustomCacheLevel()
      .postProcess(uppercaseTransformer)
      .transformKeys(modelDomainToInt)
      .transformValues(stringToData)

    cache = memoryAndDisk
      .compose(customCache)
      .compose(
        BasicFetcher(getClosure: { (key: ModelDomain) in
          let request = Promise<NSData>()
          
          Logger.log("Fetched \(key.name) on the fetcher closure", .Info)
          
          request.succeed(("Last level was hit!".data(using: .utf8, allowLossyConversion: false) as NSData?)!)
          
          return request.future
        })
      )
      .dispatch(DispatchQueue.global(qos: .userInitiated))
  }
  
  override func fetchRequested() {
    super.fetchRequested()
    
    let key = ModelDomain(name: nameField.text ?? "", identifier: Int(identifierField.text ?? "") ?? 0, URL: URL(string: urlField.text ?? "")!)
    
    _ = cache.get(key)
    
    for field in [nameField, identifierField, urlField] {
      field?.resignFirstResponder()
    }
  }
}
