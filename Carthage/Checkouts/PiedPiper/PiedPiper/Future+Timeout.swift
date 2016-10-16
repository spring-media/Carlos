import Foundation

public enum FutureError: ErrorType {
  case Timeout
}

extension Future {
  /**
   Sets a timeout before this Future has to succeed or fail
   
   - parameter timeout: The number of seconds after which this Future will fail
   
   - returns: A new Future that will time out after the given number of seconds, or will behave as this Future
   */
  public func timeout(after timeout: NSTimeInterval) -> Future<T> {
    let timedOut = Promise<T>().mimic(self)
    
    GCD.delay(timeout, closure: { FutureError.Timeout as ErrorType }).onSuccess(timedOut.fail)
    
    return timedOut.future
  }
}
