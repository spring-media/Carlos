import OpenCombine

/// A reified batchGetAll
public final class BatchAllCache<KeySeq: Sequence, Cache: CacheLevel>: CacheLevel where KeySeq.Iterator.Element == Cache.KeyType {
  /// A sequence of keys for the wrapped cache
  public typealias KeyType = KeySeq
  /// An array of output elements
  public typealias OutputType = [Cache.OutputType]

  private let cache: Cache
  
  public init(cache: Cache) {
    self.cache = cache
  }

  /**
   Dispatch each key in the sequence in parallel
   Merge the results -- if any key fails, it all fails
  */
  public func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    key.map(cache.get).publisher
      .setFailureType(to: Error.self)
      .flatMap { $0 }
      .collect()
      .eraseToAnyPublisher()
  }

  /**
  Zip the keys with the values and set them all
  */
  public func set(_ value: OutputType, forKey key: KeyType) -> AnyPublisher<Void, Error> {
    let initial = Just(())
      .setFailureType(to: Error.self)
      .eraseToAnyPublisher()
    return zip(value, key)
      .map(cache.set)
      .reduce(initial) { previous, current in
        previous.flatMap { current }
          .eraseToAnyPublisher()
      }
  }

  public func clear() {
    cache.clear()
  }

  public func onMemoryWarning() {
    cache.onMemoryWarning()
  }
}

extension CacheLevel {
  /**
   Wrap a <K, V> cache into a <Sequence<K>, [V]> cache where
   each k in Sequence<K> is dispatched in parallel and if any K fails,
   it all fails
   */
  public func allBatch<KeySeq: Sequence>() -> BatchAllCache<KeySeq, Self> {
    return BatchAllCache(cache: self)
  }
}
