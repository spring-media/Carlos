import Foundation

/// Abstracts objects that have a cost (useful for the MemoryCacheLevel)
public protocol ExpensiveObject {
  /// The cost of the object
  var cost: Int { get }
}

extension Data: ExpensiveObject {
  /// The number of bytes of the data block
  public var cost: Int {
    return self.count
  }
}

extension NSData: ExpensiveObject {
  /// The number of bytes of the data block
  public var cost: Int {
    return self.length
  }
}

extension String: ExpensiveObject {
  /// The number of characters of the string
  public var cost: Int {
    return self.characters.count
  }
}

extension NSString: ExpensiveObject {
  /// The number of characters of the NSString
  public var cost: Int {
    return self.length
  }
}

extension URL: ExpensiveObject {
  /// The size of the URL
  public var cost: Int {
    return String(absoluteString).cost
  }
}

extension Int: ExpensiveObject {
  /// Integers have a unit cost
  public var cost: Int {
    return 1
  }
}

extension Float: ExpensiveObject {
  /// Floats have a unit cost
  public var cost: Int {
    return 1
  }
}

extension Double: ExpensiveObject {
  /// Doubles have a unit cost
  public var cost: Int {
    return 1
  }
}

extension Character: ExpensiveObject {
  /// Characters have a unit cost
  public var cost: Int {
    return 1
  }
}
