import Foundation
import OpenCombine

extension CacheLevel {  
  /**
   Performs a batch of get requests on this CacheLevel
   
   - parameter keys: The list of keys to batch
   
   - returns: A Future that will call the success callback when all the keys will be either fetched or failed, passing a list containing just the successful results
   */
  public func batchGetSome(_ keys: [KeyType]) -> AnyPublisher<[OutputType], Error> {
    keys.map(get).publisher
      .setFailureType(to: Error.self)
      .flatMap { $0 }
      .collect()
      .eraseToAnyPublisher()
  }
}
