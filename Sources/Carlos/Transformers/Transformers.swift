import Combine
import Foundation
import MapKit

public enum NSDateFormatterError: Error {
  case invalidInputString
}

/**
 NSDateFormatter extension to conform to the TwoWayTransformer protocol

 This class transforms from NSDate to String (transform) and viceversa (inverseTransform)
 */
extension DateFormatter: TwoWayTransformer {
  public typealias TypeIn = Date
  public typealias TypeOut = String

  public func transform(_ val: TypeIn) -> AnyPublisher<TypeOut, Error> {
    AnyPublisher.create { promise in
      promise(.success(self.string(from: val)))
    }
    .eraseToAnyPublisher()
  }

  public func inverseTransform(_ val: TypeOut) -> AnyPublisher<TypeIn, Error> {
    AnyPublisher.create { promise in
      guard let date = self.date(from: val) else {
        promise(.failure(NSDateFormatterError.invalidInputString))
        return
      }

      promise(.success(date))
    }
    .eraseToAnyPublisher()
  }
}

public enum NSNumberFormatterError: Error {
  case cannotConvertToString
  case invalidString
}

/**
 NSNumberFormatter extension to conform to the TwoWayTransformer protocol

 This class transforms from NSNumber to String (transform) and viceversa (inverseTransform)
 */
extension NumberFormatter: TwoWayTransformer {
  public typealias TypeIn = NSNumber
  public typealias TypeOut = String

  public func transform(_ val: TypeIn) -> AnyPublisher<TypeOut, Error> {
    AnyPublisher.create { promise in
      guard let string = self.string(from: val) else {
        promise(.failure(NSNumberFormatterError.cannotConvertToString))
        return
      }

      promise(.success(string))
    }
    .eraseToAnyPublisher()
  }

  public func inverseTransform(_ val: TypeOut) -> AnyPublisher<TypeIn, Error> {
    AnyPublisher.create { promise in
      guard let number = self.number(from: val) else {
        promise(.failure(NSNumberFormatterError.invalidString))
        return
      }

      promise(.success(number))
    }
    .eraseToAnyPublisher()
  }
}

/**
 MKDistanceFormatter extension to conform to the TwoWayTransformer protocol

 This class transforms from CLLocationDistance to String (transform) and viceversa (inverseTransform)
 */
extension MKDistanceFormatter: TwoWayTransformer {
  public typealias TypeIn = CLLocationDistance
  public typealias TypeOut = String

  public func transform(_ val: TypeIn) -> AnyPublisher<TypeOut, Error> {
    AnyPublisher.create { $0(.success(self.string(fromDistance: val))) }
      .eraseToAnyPublisher()
  }

  public func inverseTransform(_ val: TypeOut) -> AnyPublisher<TypeIn, Error> {
    AnyPublisher.create { $0(.success(self.distance(from: val))) }
      .eraseToAnyPublisher()
  }
}
