//
//  Extensions.swift
//  CarlosSample
//
//  Created by Monaco, Vittorio on 03/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

extension NSHTTPURLResponse {
  //TODO: Rename (btw, do we need this?)
  func hnk_validateLengthOfData(data : NSData) -> Bool {
    let expectedContentLength = self.expectedContentLength
    if (expectedContentLength > -1) {
      let dataLength = data.length
      return Int64(dataLength) >= expectedContentLength
    }
    return true
  }
}

extension String {
  func MD5String() -> String {
    if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
      let MD5Calculator = MD5(data)
      let MD5Data = MD5Calculator.calculate()
      let resultBytes = UnsafeMutablePointer<CUnsignedChar>(MD5Data.bytes)
      let resultEnumerator = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: MD5Data.length)
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

//TODO: Do we need this?
func < (lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

//TODO: Do we need this?
func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
  return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}

extension NSFileManager {
  //TODO: Do we need this?
  func enumerateContentsOfDirectoryAtPath(path : String, orderedByProperty property : String, ascending : Bool, usingBlock block : (NSURL, Int, inout Bool) -> Void ) {
    
    let directoryURL = NSURL(fileURLWithPath: path)
    if directoryURL == nil { return }
    var error : NSError?
    if let contents = self.contentsOfDirectoryAtURL(directoryURL!, includingPropertiesForKeys: [property], options: NSDirectoryEnumerationOptions.allZeros, error: &error) as? [NSURL] {
      
      let sortedContents = contents.sorted({(URL1 : NSURL, URL2 : NSURL) -> Bool in
        
        // Maybe there's a better way to do this. See: http://stackoverflow.com/questions/25502914/comparing-anyobject-in-swift
        
        var value1 : AnyObject?
        if !URL1.getResourceValue(&value1, forKey: property, error: nil) { return true }
        var value2 : AnyObject?
        if !URL2.getResourceValue(&value2, forKey: property, error: nil) { return false }
        
        
        if let string1 = value1 as? String, let string2 = value2 as? String {
          return ascending ? string1 < string2 : string2 < string1
        }
        
        if let date1 = value1 as? NSDate, let date2 = value2 as? NSDate {
          return ascending ? date1 < date2 : date2 < date1
        }
        
        if let number1 = value1 as? NSNumber, let number2 = value2 as? NSNumber {
          return ascending ? number1 < number2 : number2 < number1
        }
        
        return false
      })
      
      for (i, v) in enumerate(sortedContents) {
        var stop : Bool = false
        block(v, i, &stop)
        if stop { break }
      }
    } else {
      println("Failed to list directory")
    }
  }
}