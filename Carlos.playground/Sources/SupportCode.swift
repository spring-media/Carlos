//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to Carlos.playground.
//

import XCPlayground

public func sharedSubfolder() -> String {
  return "\(XCPlaygroundSharedDataDirectoryURL)/com.carlos.cache"
}

public func initializePlayground() {
  XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
}