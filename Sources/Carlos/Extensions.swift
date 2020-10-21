import Foundation
import CryptoKit
import Combine

public extension String {
  func MD5String() -> String {
    guard let data = data(using: .utf8) else {
      return self
    }

    return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
  }
}

extension Publishers {
  static func create<Output, Failure: Error>(_ block: @escaping (Future<Output, Failure>.Promise) -> Void) -> AnyPublisher<Output, Failure> {
    Deferred {
      Future { promise in
        block(promise)
      }
    }
    .eraseToAnyPublisher()
  }
}
