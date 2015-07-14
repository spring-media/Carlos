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
//TODO: Think about how to make possible a NSURL key type and still make it work with other levels in the pipeline
public class NetworkFetcher: CacheLevel {
  public typealias KeyType = NSURL
  public typealias OutputType = NSData
  
  private class Request {
    private static let ValidStatusCodes = 200..<300
    private let URL : NSURL
    private var task : NSURLSessionDataTask? = nil
    
    init(URL: NSURL, success succeed : (NSData) -> (), failure fail : ((NSError?) -> ())) {
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
    
    private func dataReceived(data : NSData!, response : NSURLResponse!, error : NSError!, failure fail : ((NSError?) -> Void), success succeed : (NSData) -> Void) {
      if let error = error {
        if error.domain != NSURLErrorDomain || error.code != NSURLErrorCancelled {
          dispatch_async(dispatch_get_main_queue(), {
            fail(error)
          })
        }
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if !contains(Request.ValidStatusCodes, httpResponse.statusCode) {
          failWithCode(.StatusCodeNotOk, failure: fail)
        } else if !validate(httpResponse, withData: data) {
          failWithCode(.InvalidNetworkResponse, failure: fail)
        } else if let data = data {
          dispatch_async(dispatch_get_main_queue()) {
            succeed(data)
          }
        } else {
          failWithCode(.NoDataRetrieved, failure: fail)
        }
      }
    }
    
    private func failWithCode(code: NetworkFetcherError, failure fail : ((NSError?) -> ())) {
      dispatch_async(dispatch_get_main_queue()) {
        fail(errorWithCode(code.rawValue))
      }
    }
  }
  
  private var pendingRequests: [String: Request] = [:]
  
  public init() {}
  
  public func get(key: KeyType) -> CacheRequest<OutputType> {
    let result = CacheRequest<OutputType>()
    
    let request = Request(URL: key, success: { data in
      Logger.log("Fetched \(key) from the network fetcher")
      result.succeed(data)
      self.pendingRequests[key.absoluteString!] = nil
    }, failure: { error in
      Logger.log("Failed fetching \(key) from the network fetcher", .Error)
      result.fail(error)
      self.pendingRequests[key.absoluteString!] = nil
    })
    
    pendingRequests[key.absoluteString!] = request
    return result
  }
  
  public func set(value: NSData, forKey key: NSURL) {}
  
  public func onMemoryWarning() {}
  
  public func clear() {}
}