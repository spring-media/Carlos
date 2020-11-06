import Carlos
import Foundation
import UIKit
import Combine

class DataCacheSampleViewController: BaseCacheViewController {
  fileprivate var cache: BasicCache<URL, NSData>!

  private var cancellable: AnyCancellable?

  override func fetchRequested() {
    super.fetchRequested()

    cancellable = cache.get(URL(string: urlKeyField?.text ?? "")!)
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
  }

  override func titleForScreen() -> String {
    "Data cache"
  }

  override func setupCache() {
    super.setupCache()

    cache = CacheProvider.dataCache()
  }
}
