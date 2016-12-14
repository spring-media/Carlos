import Foundation
import PiedPiper

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
  private static let ValidStatusCodes = 200..<300
  private let lock: ReadWriteLock = PThreadReadWriteLock()
  
  /// The network cache accepts only NSURL keys
  public typealias KeyType = URL
  
  /// The network cache returns only NSData values
  public typealias OutputType = NSData
  
  private func validate(_ response: HTTPURLResponse, withData data: Data) -> Bool {
    var responseIsValid = true
    let expectedContentLength = response.expectedContentLength
    if expectedContentLength > -1 {
      responseIsValid = Int64(data.count) >= expectedContentLength
    }
    return responseIsValid
  }
  
  private func startRequest(_ URL: Foundation.URL) -> Future<NSData> {
    let result = Promise<NSData>()
    
    let task = URLSession.shared.dataTask(with: URL, completionHandler: { [weak self] (data, response, error) in
      guard let strongSelf = self else { return }
      
      if let error = error as? NSError {
        if error.domain != NSURLErrorDomain || error.code != NSURLErrorCancelled {
          GCD.main {
            result.fail(error)
          }
        }
      } else if let httpResponse = response as? HTTPURLResponse {
        if !NetworkFetcher.ValidStatusCodes.contains(httpResponse.statusCode) {
          GCD.main {
            result.fail(NetworkFetcherError.statusCodeNotOk)
          }
        } else if let data = data , !strongSelf.validate(httpResponse, withData: data) {
          GCD.main {
            result.fail(NetworkFetcherError.invalidNetworkResponse)
          }
        } else if let data = data {
          GCD.main {
            result.succeed(data as NSData)
          }
        } else {
          GCD.main {
            result.fail(NetworkFetcherError.noDataRetrieved)
          }
        }
      }
    }) 
    
    result.onCancel {
      task.cancel()
    }
    
    task.resume()
    
    return result.future
  }

  private var pendingRequests: [Future<OutputType>] = []

  private func addPendingRequest(_ request: Future<OutputType>) {
    lock.withWriteLock {
      self.pendingRequests.append(request)
    }
  }

  private func removePendingRequests(_ request: Future<OutputType>) {
    if let idx = lock.withReadLock({ self.pendingRequests.index(where: { $0 === request }) }) {
      _ = lock.withWriteLock {
        self.pendingRequests.remove(at: idx)
      }
    }
  }

  /**
  Initializes a new instance of a NetworkFetcher
  */
  public init() {}
  
  /**
  Asks the cache to get a value for the given key
  
  - parameter key: The key for the value. It represents the URL to fetch the value
  
  - returns: A Future that you can use to get the asynchronous results of the network fetch
  */
  open func get(_ key: KeyType) -> Future<OutputType> {
    let result = startRequest(key)
      
    result
      .onSuccess { _ in
        Logger.log("Fetched \(key) from the network fetcher")
        self.removePendingRequests(result)
      }
      .onFailure { _ in
        Logger.log("Failed fetching \(key) from the network fetcher", .Error)
        self.removePendingRequests(result)
      }
      .onCancel {
        Logger.log("Canceled request for \(key) on the network fetcher", .Info)
        self.removePendingRequests(result)
      }
    
    self.addPendingRequest(result)
    
    return result
  }
}
