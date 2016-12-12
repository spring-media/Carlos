import Foundation
import PiedPiper

/// A wrapper fetcher that explicitly takes a get closure
public final class BasicFetcher<A, B>: Fetcher {
  public typealias KeyType = A
  public typealias OutputType = B
  
  private let getClosure: (_ key: A) -> Future<B>
  
  /**
   Initializes a new instance of a BasicFetcher specifying a get closure, thus determining the behavior of the fetcher as a whole
   
   - parameter getClosure: The closure to execute when you call get(key) on this instance
   */
  public init(getClosure: @escaping (_ key: A) -> Future<B>) {
    self.getClosure = getClosure
  }
  
  /**
   Asks the fetcher to get the value for a given key
   
   - parameter key: The key you want to get the value for
   
   - returns: The result of the getClosure specified when initializing the instance
   */
  public func get(_ key: KeyType) -> Future<OutputType> {
    return getClosure(key)
  }
}
