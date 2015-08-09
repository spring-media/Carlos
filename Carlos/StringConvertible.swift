import Foundation

/// Represents a type that can be converted to a string
public protocol StringConvertible {
  /**
  :returns: the String representation of the value
  */
  func toString() -> String
}

extension String: StringConvertible {
  /**
  :returns: The value itself
  */
  public func toString() -> String {
    return self
  }
}

extension NSString: StringConvertible {
  /**
  :returns: The value itself
  */
  public func toString() -> String {
    return self as String
  }
}
