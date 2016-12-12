import Foundation

extension Future {
  /**
   Snoozes the result (.Success or .Failure) of this Future by the given time
   
   - parameter time: The number of seconds this Future's result should be snoozed for
   
   - returns: A new Future that will return the result of this Future after the given snooze time
   */
  public func snooze(_ time: TimeInterval) -> Future<T> {
    let snoozed = Promise<T>()
    
    onCompletion { _ in
      GCD.delay(time, closure: {
        snoozed.mimic(self)
      })
    }
    
    return snoozed.future
  }
}
