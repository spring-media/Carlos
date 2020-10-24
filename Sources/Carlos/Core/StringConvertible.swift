import Foundation

/// Represents a type that can be converted to a string
public protocol StringConvertible {
  /**
   - returns: the String representation of the value
   */
  func toString() -> String
}

extension StringConvertible {
  public func toString() -> String {
    "Nan"
  }
}

extension String: StringConvertible {
  /**
   - returns: The value itself
   */
  public func toString() -> String {
    self
  }
}

extension NSString: StringConvertible {
  /**
   - returns: The value itself
   */
  public func toString() -> String {
    self as String
  }
}

extension URL: StringConvertible {
  /**
   - returns: The absolute string or an empty string if the absolute string is nil
   */
  public func toString() -> String {
    absoluteString
  }
}
