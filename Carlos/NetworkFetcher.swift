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
public class NetworkFetcher: CacheLevel {
  /// The network cache accepts only NSURL keys
  public typealias KeyType = NSURL
  
  /// The network cache returns only NSData values
  public typealias OutputType = NSData
  
  private class Request {
    private static let ValidStatusCodes = 200..<300
    private let URL : NSURL
    private var task : NSURLSessionDataTask? = nil
    
    init(URL: NSURL, success succeed : (NSData, Request) -> (), failure fail : ((ErrorType, Request) -> ())) {
      self.URL = URL
      self.task = NSURLSession.sharedSession().dataTaskWithURL(URL) {[weak self] (data, response, error) in
        if let strongSelf = self {
          strongSelf.dataReceived(data, response: response, error: error, failure: fail, success: succeed)
        }
      }
      task?.resume()
    }
    
    private func validate(response: NSHTTPURLResponse, withData data: NSData) -> Bool {
      var responseIsValid = true
      let expectedContentLength = response.expectedContentLength
      if expectedContentLength > -1 {
        responseIsValid = Int64(data.length) >= expectedContentLength
      }
      return responseIsValid
    }
    
    private func dataReceived(data : NSData!, response : NSURLResponse!, error : NSError!, failure fail : ((ErrorType, Request) -> Void), success succeed : (NSData,Request) -> Void) {
      if let error = error {
        if error.domain != NSURLErrorDomain || error.code != NSURLErrorCancelled {
          dispatch_async(dispatch_get_main_queue(), {
            fail(error, self)
          })
        }
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if !Request.ValidStatusCodes.contains(httpResponse.statusCode) {
          dispatch_async(dispatch_get_main_queue()) {
            fail(NetworkFetcherError.StatusCodeNotOk, self)
          }
        } else if !validate(httpResponse, withData: data) {
          dispatch_async(dispatch_get_main_queue()) {
            fail(NetworkFetcherError.InvalidNetworkResponse, self)
          }
        } else if let data = data {
          dispatch_async(dispatch_get_main_queue()) {
            succeed(data,self)
          }
        } else {
          dispatch_async(dispatch_get_main_queue()) {
            fail(NetworkFetcherError.NoDataRetrieved, self)
          }
        }
      }
    }
  }

  private lazy var lockQueue: dispatch_queue_t = {
    return dispatch_queue_create(CarlosGlobals.QueueNamePrefix + "networkfetcher", DISPATCH_QUEUE_SERIAL)
  }()

  private var pendingRequests: [Request] = []

  private func addPendingRequest(request: Request) {
    dispatch_async(lockQueue) {
      self.pendingRequests.append(request)
    }
  }

  private func removePendingRequests(request: Request) {
    dispatch_async(lockQueue) {
      if let idx = self.pendingRequests.enumerate().filter({ $1 === request }).first?.index {
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
  
  - returns: A CacheRequest that you can use to get the asynchronous results of the network fetch
  */
  public func get(key: KeyType) -> CacheRequest<OutputType> {
    let result = CacheRequest<OutputType>()
    
    let request = Request(URL: key, success: { data,request in
      Logger.log("Fetched \(key) from the network fetcher")
      result.succeed(data)
      self.removePendingRequests(request)
    }, failure: { error, request in
      Logger.log("Failed fetching \(key) from the network fetcher", .Error)
      result.fail(error)
      self.removePendingRequests(request)
    })
    self.addPendingRequest(request)
    return result
  }
  
  /**
  This call is a no-op
  */
  public func set(value: NSData, forKey key: NSURL) {}
  
  /**
  This call is a no-op
  */
  public func onMemoryWarning() {}
  
  /**
  This call is a no-op
  */
  public func clear() {}
}