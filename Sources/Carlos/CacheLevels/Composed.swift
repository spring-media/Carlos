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
      getClosure: { [weak self] key in
        guard let self = self else {
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }

        return self.get(key)
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
      setClosure: { [weak self] value, key in
        guard let self = self else {
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }

        return Publishers.Zip(
          self.set(value, forKey: key),
          cache.set(value, forKey: key)
        )
        .map { _ in () }
        .eraseToAnyPublisher()
      },
      removeClosure: { [weak self] key in
        guard let self = self else {
          return Empty(completeImmediately: true).eraseToAnyPublisher()
        }

        return Publishers.Zip(self.remove(key), cache.remove(key))
          .map { _ in () }
          .eraseToAnyPublisher()
      },
      clearClosure: { [weak self] in
        self?.clear()
        cache.clear()
      },
      memoryClosure: { [weak self] in
        self?.onMemoryWarning()
        cache.onMemoryWarning()
      }
    )
  }
}
