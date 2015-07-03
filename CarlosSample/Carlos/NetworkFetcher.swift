//
//  NetworkFetcher.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

public class NetworkFetcher: CacheLevel {
  class Request {
    let URL : NSURL
    
    var session : NSURLSession { return NSURLSession.sharedSession() }
    var task : NSURLSessionDataTask? = nil
    
    init(URL: NSURL, failure fail : ((NSError?) -> ()), success succeed : (NSData) -> ()) {
      self.URL = URL
      self.task = session.dataTaskWithURL(URL) {[weak self] (data, response, error) in
        if let strongSelf = self {
          strongSelf.onReceiveData(data, response: response, error: error, failure: fail, success: succeed)
        }
      }
      task?.resume()
    }
    
    private func onReceiveData(data : NSData!, response : NSURLResponse!, error : NSError!, failure fail : ((NSError?) -> ()), success succeed : (NSData) -> ()) {
      let URL = self.URL
      
      if let error = error {
        if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
          return
        }
        
        dispatch_async(dispatch_get_main_queue(), { fail(error) })
        return
      }
      
      // Intentionally avoiding `if let` to continue in golden path style.
      let httpResponse = response as! NSHTTPURLResponse
      if httpResponse.statusCode != 200 {
        failWithCode(10, failure: fail)
        return
      }
      
      if !httpResponse.hnk_validateLengthOfData(data) {
        failWithCode(9, failure: fail)
        return
      }
      
      let value = data
      if value == nil {
        failWithCode(11, failure: fail)
        return
      }
      
      dispatch_async(dispatch_get_main_queue()) { succeed(value) }
    }
    
    private func failWithCode(code: Int, failure fail : ((NSError?) -> ())) {
      let error = NSError(domain: "Carlos", code: code, userInfo: nil)
      dispatch_async(dispatch_get_main_queue()) { fail(error) }
    }
  }
  
  private var pendingRequests: [String: Request] = [:]
  
  public init() {}
  
  public func onMemoryWarning() {}
  
  public func get(key: FetchableType, onSuccess success: (NSData) -> Void, onFailure failure: (NSError?) -> Void) {
    let x = Request(URL: NSURL(string: key.key)!, failure: { error in
      failure(error)
      self.pendingRequests[key.key] = nil
    }, success: { data in
      success(data)
      self.pendingRequests[key.key] = nil
    })
    
    pendingRequests[key.key] = x
  }
  
  public func set(value: NSData, forKey key: FetchableType) {}
  
  public func clear() {}
}