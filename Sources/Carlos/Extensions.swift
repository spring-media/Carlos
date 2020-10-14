import Foundation
import CryptoKit
import CommonCrypto
import Combine

public extension String {
  func MD5String() -> String {
    guard let data = data(using: .utf8) else {
      return self
    }

    return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
  }
}

extension DispatchQueue {
  func publisher<Output, Failure: Error>(_ block: @escaping (Future<Output, Failure>.Promise) -> Void) -> AnyPublisher<Output, Failure> {
      Future<Output, Failure> { promise in
          self.async { block(promise) }
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}
