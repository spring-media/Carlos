import Foundation

extension NSImage: ExpensiveObject {
  /// The size of the image in pixels (W x H)
  public var cost: Int {
    return Int(size.width * size.height)
  }
}