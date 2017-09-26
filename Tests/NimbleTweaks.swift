//
//  NimbleTweaks.swift
//  Carlos
//
//  Created by Alex Salom on 25/9/17.
//  Copyright © 2017 WeltN24. All rights reserved.
//

import Foundation
import Quick
import Nimble

class NimbleTweaks: QuickSpec {
  override func spec() {
    beforeSuite {
      // Suggested on Nimble forum to prevent timeouts https://github.com/Quick/Nimble/issues/346#issuecomment-315955856
      
      // Increase the global timeout to 5 seconds:
      Nimble.AsyncDefaults.Timeout = 10
      
      // Slow the polling interval to 0.1 seconds:
      Nimble.AsyncDefaults.PollInterval = 0.1
    }
  }
}
