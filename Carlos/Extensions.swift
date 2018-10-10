import Foundation
import CommonCrypto

extension String {
  func MD5Data() -> Data? {
    guard let messageData = self.data(using:.utf8) else {
      return nil
    }
    
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    _ = digestData.withUnsafeMutableBytes { digestBytes in
      messageData.withUnsafeBytes { messageBytes in
        CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
      }
    }
    
    return digestData
  }
  
  func MD5String() -> String {
    guard let md5Data = MD5Data() else {
      return self
    }
    return String(data: md5Data, encoding: .utf8) ?? self
  }
}
