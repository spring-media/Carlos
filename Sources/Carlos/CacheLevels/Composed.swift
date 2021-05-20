import Combine
import Foundation

extension CacheLevel {
  /**
   Composes two cache levels

   - parameter cache: The second cache level

   - returns: A new cache level that is the result of the composition of the two cache levels
   */
  public func compose<A: CacheLevel>(_ cache: A) -> BasicCache<A.KeyType, A.OutputType> where A.KeyType == KeyType, A.OutputType == OutputType {
    BasicCache(
      getClosure: { key in
        self.get(key)
          .catch { _ -> AnyPublisher<OutputType, Error> in
            Logger.log("Composed| error on getting value for key \(key) on cache \(String(describing: self)).", .info)

            return cache.get(key)
              .flatMap { value -> AnyPublisher<(OutputType, Void), Error> in
                let get = Just(value).setFailureType(to: Error.self)
                let set = self.set(value, forKey: key)
                return Publishers.Zip(get, set)
                  .eraseToAnyPublisher()
              }
              .map(\.0)
              .eraseToAnyPublisher()
          }.eraseToAnyPublisher()
      },
      setClosure: { value, key in
        Publishers.Zip(
          self.set(value, forKey: key),
          cache.set(value, forKey: key)
        )
        .map { _ in () }
        .eraseToAnyPublisher()
      },
      clearClosure: {
        self.clear()
        cache.clear()
      },
      memoryClosure: {
        self.onMemoryWarning()
        cache.onMemoryWarning()
      }
    )
  }
}
