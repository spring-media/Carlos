import Foundation
import Carlos
import PiedPiper

class DelayedNetworkFetcher: NetworkFetcher {
  private static let delay = dispatch_time(DISPATCH_TIME_NOW,
    Int64(2 * Double(NSEC_PER_SEC))) // 2 seconds
  
  override func get(key: KeyType) -> Future<OutputType> {
    let request = Promise<OutputType>()
    
    super.get(key)
      .onSuccess({ value in
        dispatch_after(DelayedNetworkFetcher.delay, dispatch_get_main_queue()) {
          request.succeed(value)
        }
      })
      .onFailure({ error in
        dispatch_after(DelayedNetworkFetcher.delay, dispatch_get_main_queue()) {
          request.fail(error)
        }
      })
    
    return request.future
  }
}
