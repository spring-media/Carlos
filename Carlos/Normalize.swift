import Foundation

extension CacheLevel {
  
  /**
  Normalizes the CacheLevel into a BasicCache.
  Use this function when you want to have a value of type BasicCache (e.g. to store as a instance property) and you don't care about the specific class of the CacheLevel you're going to obtain from the sequence of Carlos composition calls
  
  - returns: The CacheLevel normalized to appear as a BasicCache.
  */
  public func normalize() -> BasicCache<KeyType, OutputType> {
    if let normalized = self as? BasicCache<KeyType, OutputType> {
      return normalized
    } else {
      return BasicCache<KeyType, OutputType>(
        getClosure: self.get,
        setClosure: self.set,
        clearClosure: self.clear,
        memoryClosure: self.onMemoryWarning
      )
    }
  }
}
