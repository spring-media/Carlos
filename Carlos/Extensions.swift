import Foundation

extension String {
  internal func MD5String() -> String {
    if let data = self.data(using: String.Encoding.utf8) {
      let MD5Calculator = MD5(data)
      let MD5Data = MD5Calculator.calculate()
      let resultBytes = UnsafeMutablePointer<CUnsignedChar>(mutating: (MD5Data as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: MD5Data.count))
      let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: MD5Data.count)
      let MD5String = NSMutableString()
      for c in resultEnumerator {
        MD5String.appendFormat("%02x", c)
      }
      return MD5String as String
    } else {
      return self
    }
  }
}
