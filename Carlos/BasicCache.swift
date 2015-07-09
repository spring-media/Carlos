import Foundation

/// A wrapper cache that explicitly takes get, set, clear and memory warning closures
public class BasicCache<A, B>: CacheLevel {
  public typealias KeyType = A
  public typealias OutputType = B
  
  private let getClosure: (key: A) -> CacheRequest<B>
  private let setClosure: (key: A, value: B) -> Void
  private let clearClosure: () -> Void
  private let memoryClosure: () -> Void
  
  public init(getClosure: (key: A) -> CacheRequest<B>, setClosure: (key: A, value: B) -> Void, clearClosure: () -> Void, memoryClosure: () -> Void) {
    self.getClosure = getClosure
    self.setClosure = setClosure
    self.clearClosure = clearClosure
    self.memoryClosure = memoryClosure
  }
  
  public func get(fetchable: KeyType) -> CacheRequest<OutputType> {
    return getClosure(key: fetchable)
  }
  
  public func set(value: B, forKey fetchable: A) {
    setClosure(key: fetchable, value: value)
  }
  
  public func clear() {
    clearClosure()
  }
  
  public func onMemoryWarning() {
    memoryClosure()
  }
}