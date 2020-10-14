import Foundation

import Carlos
import Combine

final class DelayedNetworkFetcher: NetworkFetcher {
  override func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    super.get(key)
      .delay(for: 2, scheduler: DispatchQueue.global())
      .eraseToAnyPublisher()
  }
}
