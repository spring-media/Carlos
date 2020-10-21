import Foundation
import UIKit

import Carlos
import Combine

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
  
  func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    if key > 0 {
      Logger.log("Fetched \(key) on the custom cache", .info)
      return Just("\(key)")
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    Logger.log("Failed fetching \(key) on the custom cache", .info)
    return Fail(error: IgnoreError.ignore).eraseToAnyPublisher()
  }
}

class ComplexCacheSampleViewController: BaseCacheViewController {
  
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var identifierField: UITextField!
  @IBOutlet weak var urlField: UITextField!
  
  private var cache: BasicCache<ModelDomain, NSData>!
  
  private var cancellables = Set<AnyCancellable>()
  
  override func titleForScreen() -> String {
    return "Complex cache"
  }
  
  override func setupCache() {
    super.setupCache()
    
    let modelDomainToString = OneWayTransformationBox<ModelDomain, String>(transform: {
      Just($0.name).setFailureType(to: Error.self).eraseToAnyPublisher()
    })
    
    let modelDomainToInt = OneWayTransformationBox<ModelDomain, Int>(transform: {
      Just($0.identifier).setFailureType(to: Error.self).eraseToAnyPublisher()
    })
    
    let stringToData = StringTransformer().invert()
    let uppercaseTransformer = OneWayTransformationBox<String, String>(transform: {
      Just($0.uppercased()).setFailureType(to: Error.self).eraseToAnyPublisher()
    })
    
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
          Logger.log("Fetched \(key.name) on the fetcher closure", .info)
          
          return Just(("Last level was hit!".data(using: .utf8, allowLossyConversion: false) as NSData?)!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        })
      )
  }
  
  override func fetchRequested() {
    super.fetchRequested()
    
    let key = ModelDomain(name: nameField.text ?? "", identifier: Int(identifierField.text ?? "") ?? 0, URL: URL(string: urlField.text ?? "")!)
    
    cache.get(key)
      .subscribe(on: DispatchQueue(label: "carlose test queu", qos: .userInitiated))
      .sink(receiveCompletion: { _ in }) { data in
        print("Is Main Thread:", Thread.isMainThread)
        print(data)
      }.store(in: &cancellables)
    
    for field in [nameField, identifierField, urlField] {
      field?.resignFirstResponder()
    }
  }
}
