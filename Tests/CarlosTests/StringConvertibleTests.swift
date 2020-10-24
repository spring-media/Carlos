import Foundation

import Nimble
import Quick

import Carlos

final class StringConvertibleTests: QuickSpec {
  override func spec() {
    describe("String values") {
      let value = "this is the value"

      it("should return self") {
        expect(value.toString()) == value
      }
    }

    describe("NSString values") {
      let value = "this is the value"

      it("should return self") {
        expect(value.toString()) == value
      }
    }
  }
}
