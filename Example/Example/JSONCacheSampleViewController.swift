import Foundation
import UIKit

import Carlos
import Combine

private var myContext = 0

final class JSONCacheSampleViewController: BaseCacheViewController {
  private var cache: BasicCache<URL, AnyObject>!
  private var cancellables = Set<AnyCancellable>()

  override func fetchRequested() {
    super.fetchRequested()

    cache.get(URL(string: urlKeyField?.text ?? "")!)
      .sink(receiveCompletion: { _ in }, receiveValue: { JSON in
        self.eventsLogView.text = "\(self.eventsLogView.text!)\nJSON Dictionary result: \(JSON as? NSDictionary)\n"
      })
      .store(in: &cancellables)

    let progress = Progress.current()
    progress?.addObserver(self, forKeyPath: "fractionCompleted", options: .initial, context: &myContext)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    if context == &myContext {
      if let newValue = change?[NSKeyValueChangeKey.newKey] {
        print("Progress changed: \(newValue)")
      }
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  override func titleForScreen() -> String {
    "JSON cache"
  }

  override func setupCache() {
    super.setupCache()

    cache = CacheProvider.JSONCache()
  }
}
