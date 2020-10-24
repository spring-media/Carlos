import Combine
import Foundation

extension CacheLevel {
  /**
   Performs a batch of get requests on this CacheLevel

   - parameter keys: The list of keys to batch

   - returns: A Future that will call the success callback when all the keys will be either fetched or failed, passing a list containing just the successful results
   */
  public func batchGetSome(_ keys: [KeyType]) -> AnyPublisher<[OutputType], Error> {
    let allResults: [AnyPublisher<Result<OutputType, Error>, Error>] = keys.map { key in
      get(key)
        .map { Result<Self.OutputType, Error>.success($0) }
        .catch {
          Just(Result<Self.OutputType, Error>.failure($0))
            .setFailureType(to: Error.self)
        }
        .eraseToAnyPublisher()
    }

    return allResults.publisher
      .setFailureType(to: Error.self)
      .flatMap { $0 }
      .collect(allResults.count)
      .map { result in
        result.compactMap { try? $0.get() }
      }
      .eraseToAnyPublisher()
  }
}
