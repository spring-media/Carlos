import Foundation
import UIKit

import Carlos
import Combine

final class SwitchCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, NSData>!

  private var cancellables = Set<AnyCancellable>()

  override func fetchRequested() {
    super.fetchRequested()

    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
      .store(in: &cancellables)
  }

  override func titleForScreen() -> String {
    "Switched caches"
  }

  override func setupCache() {
    super.setupCache()

    let lane1 = MemoryCacheLevel<URL, NSData>()
    lane1.set(("Yes, this is hitting the memory cache now".data(using: .utf8, allowLossyConversion: false) as NSData?)!, forKey: URL(string: "test")!)
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
      .store(in: &cancellables)
    lane1.set(("Carlos lets you create quite complex cache infrastructures".data(using: .utf8, allowLossyConversion: false) as NSData?)!, forKey: URL(string: "carlos")!)
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
      .store(in: &cancellables)

    let lane2 = CacheProvider.dataCache()

    cache = switchLevels(cacheA: lane1, cacheB: lane2, switchClosure: { key in
      if key.scheme == "http" {
        return .cacheB
      } else {
        return .cacheA
      }
    })
  }
}
