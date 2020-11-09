import Foundation

import Combine

public enum NetworkFetcherError: Error {
  /// Used when the status code of the network response is not included in the range 200..<300
  case statusCodeNotOk

  /// Used when the network response had an invalid size
  case invalidNetworkResponse

  /// Used when the network request didn't manage to retrieve data
  case noDataRetrieved
}

/// This class is a network cache level, mostly acting as a fetcher (meaning that calls to the set method won't have any effect). It internally uses NSURLSession to retrieve values from the internet
open class NetworkFetcher: Fetcher {
  /// The network cache accepts only NSURL keys
  public typealias KeyType = URL

  /// The network cache returns only NSData values
  public typealias OutputType = NSData

  /**
   Initializes a new instance of a NetworkFetcher
   */
  public init() {}

  /**
   Asks the cache to get a value for the given key

   - parameter key: The key for the value. It represents the URL to fetch the value

   - returns: A Future that you can use to get the asynchronous results of the network fetch
   */
  open func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    URLSession.shared.dataTaskPublisher(for: key)
      .tryMap { [weak self] data, response -> NSData in
        guard let response = response as? HTTPURLResponse else {
          throw NetworkFetcherError.invalidNetworkResponse
        }

        guard 200..<300 ~= response.statusCode else {
          throw NetworkFetcherError.statusCodeNotOk
        }

        if self?.validate(response, withData: data) == true {
          return data as NSData
        }

        throw NetworkFetcherError.invalidNetworkResponse
      }
      .eraseToAnyPublisher()
  }

  private func validate(_ response: HTTPURLResponse, withData data: Data) -> Bool {
    var responseIsValid = true
    let expectedContentLength = response.expectedContentLength
    if expectedContentLength > -1 {
      responseIsValid = Int64(data.count) >= expectedContentLength
    }
    return responseIsValid
  }
}
