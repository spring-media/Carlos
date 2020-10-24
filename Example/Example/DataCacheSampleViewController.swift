import Carlos
import Foundation
import UIKit

class DataCacheSampleViewController: BaseCacheViewController {
  fileprivate var cache: BasicCache<URL, NSData>!

  override func fetchRequested() {
    super.fetchRequested()

    _ = cache.get(URL(string: urlKeyField?.text ?? "")!)
  }

  override func titleForScreen() -> String {
    "Data cache"
  }

  override func setupCache() {
    super.setupCache()

    cache = CacheProvider.dataCache()
  }
}
