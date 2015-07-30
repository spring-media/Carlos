import Foundation

public enum NetworkFetcherError: Int {
  /// Used when the status code of the network response is not included in the range 200..<300
  case StatusCodeNotOk = 11100
  
  /// Used when the network response had an invalid size
  case InvalidNetworkResponse = 11101
  
  /// Used when the network request didn't manage to retrieve data
  case NoDataRetrieved = 11102
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
    
    init(URL: NSURL, success succeed : (NSData,Request) -> (), failure fail : ((NSError?,Request) -> ())) {
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
    
    private func dataReceived(data : NSData!, response : NSURLResponse!, error : NSError!, failure fail : ((NSError?,Request) -> Void), success succeed : (NSData,Request) -> Void) {
      if let error = error {
        if error.domain != NSURLErrorDomain || error.code != NSURLErrorCancelled {
          dispatch_async(dispatch_get_main_queue(), {
            fail(error,self)
          })
        }
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if !contains(Request.ValidStatusCodes, httpResponse.statusCode) {
          failWithCode(.StatusCodeNotOk, failure: fail)
        } else if !validate(httpResponse, withData: data) {
          failWithCode(.InvalidNetworkResponse, failure: fail)
        } else if let data = data {
          dispatch_async(dispatch_get_main_queue()) {
            succeed(data,self)
          }
        } else {
          failWithCode(.NoDataRetrieved, failure: fail)
        }
      }
    }
    
    private func failWithCode(code: NetworkFetcherError, failure fail : ((NSError?,Request) -> ())) {
      dispatch_async(dispatch_get_main_queue()) {
        fail(errorWithCode(code.rawValue),self)
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
      var idx: Int?

      for (index, obj) in enumerate(self.pendingRequests) {
        if request === obj {
          idx = index
          break
        }
      }

      if let idx = idx {
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
  
  :param: key The key for the value. It represents the URL to fetch the value
  
  :returns: A CacheRequest that you can use to get the asynchronous results of the network fetch
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