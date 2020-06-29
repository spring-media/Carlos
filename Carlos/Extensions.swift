import Foundation
import CommonCrypto

extension String {
  func MD5Data() -> Data? {
    let data = Data(self.utf8)
    let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
      var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
      CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
      return hash
    }
    
    return Data(bytes: hash, count: hash.count)
  }
  
  func MD5String() -> String {
    guard let md5Data = MD5Data() else {
      return self
    }
    return String(data: md5Data, encoding: .utf8) ?? self
  }
}
