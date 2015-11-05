import Foundation

public enum NetworkFetcherError: ErrorType {
  /// Used when the status code of the network response is not included in the range 200..<300
  case StatusCodeNotOk
  
  /// Used when the network response had an invalid size
  case InvalidNetworkResponse
  
  /// Used when the network request didn't manage to retrieve data
  case NoDataRetrieved
}

/// This class is a network cache level, mostly acting as a fetcher (meaning that calls to the set method won't have any effect). It internally uses NSURLSession to retrieve values from the internet
public class NetworkFetcher: Fetcher {
  private static let ValidStatusCodes = 200..<300
  private let lock: ReadWriteLock = PThreadReadWriteLock()
  
  /// The network cache accepts only NSURL keys
  public typealias KeyType = NSURL
  
  /// The network cache returns only NSData values
  public typealias OutputType = NSData
  
  private func validate(response: NSHTTPURLResponse, withData data: NSData) -> Bool {
    var responseIsValid = true
    let expectedContentLength = response.expectedContentLength
    if expectedContentLength > -1 {
      responseIsValid = Int64(data.length) >= expectedContentLength
    }
    return responseIsValid
  }
  
  private func startRequest(URL: NSURL) -> Future<NSData> {
    let result = Promise<NSData>()
    
    let task = NSURLSession.sharedSession().dataTaskWithURL(URL) { [weak self] (data, response, error) in
      guard let strongSelf = self else { return }
      
      if let error = error {
        if error.domain != NSURLErrorDomain || error.code != NSURLErrorCancelled {
          GCD.main {
            result.fail(error)
          }
        }
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if !NetworkFetcher.ValidStatusCodes.contains(httpResponse.statusCode) {
          GCD.main {
            result.fail(NetworkFetcherError.StatusCodeNotOk)
          }
        } else if let data = data where !strongSelf.validate(httpResponse, withData: data) {
          GCD.main {
            result.fail(NetworkFetcherError.InvalidNetworkResponse)
          }
        } else if let data = data {
          GCD.main {
            result.succeed(data)
          }
        } else {
          GCD.main {
            result.fail(NetworkFetcherError.NoDataRetrieved)
          }
        }
      }
    }
    
    result.onCancel {
      task.cancel()
    }
    
    task.resume()
    
    return result.future
  }

  private var pendingRequests: [Future<OutputType>] = []

  private func addPendingRequest(request: Future<OutputType>) {
    lock.withWriteLock {
      self.pendingRequests.append(request)
    }
  }

  private func removePendingRequests(request: Future<OutputType>) {
    if let idx = lock.withReadLock({ self.pendingRequests.indexOf({ $0 === request }) }) {
      lock.withWriteLock {
        self.pendingRequests.removeAtIndex(idx)
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
  public func get(key: KeyType) -> Future<OutputType> {
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
    
    self.addPendingRequest(result)
    
    return result
  }
}