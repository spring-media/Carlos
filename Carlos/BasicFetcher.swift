import Foundation

public final class BasicFetcher<A, B>: Fetcher {
  public typealias KeyType = A
  public typealias OutputType = B
  
  private let getClosure: (key: A) -> CacheRequest<B>
  
  public init(getClosure: (key: A) -> CacheRequest<B>) {
    self.getClosure = getClosure
  }
  
  public func get(key: KeyType) -> CacheRequest<OutputType> {
    return getClosure(key: key)
  }
}