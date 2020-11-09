import Combine
import CryptoKit
import Foundation

public extension String {
  func MD5String() -> String {
    guard let data = data(using: .utf8) else {
      return self
    }

    return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
  }
}

extension AnyPublisher {
  static func create(_ block: @escaping ((Result<Output, Failure>) -> Void) -> Void) -> AnyPublisher<Output, Failure> {
    Deferred {
      Future { promise in
        block(promise)
      }
    }
    .eraseToAnyPublisher()
  }
}
