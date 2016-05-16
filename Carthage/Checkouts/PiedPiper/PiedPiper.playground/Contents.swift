import PiedPiper
import UIKit

initializePlayground()

// Promises

func testPromise() -> Promise<Int> {
  return Promise()
}

let test = testPromise()

test.onSuccess { value in
  let success = value
  print("Succeeded with value \(success)")
}.onFailure { err in
  let failure = err
  print("Failed with error \(failure)")
}

// Pick your poison, but only one!
test.succeed(102)
//test.fail(NSError(domain: "Test", code: 10, userInfo: nil))

// Async

GCD.background { Void -> Int in
  print("The result of this computation...")
  return 10
}.main { result in
  let magic = result
  print("...goes straight here! \(magic)")
}

// Function composition

func randomInt() -> Int {
  return 4 //Guaranteed random, inspired by http://xkcd.com/221/
}

func stringifyInt(number: Int) -> String {
  return "\(number)"
}

func helloString(input: String) -> String {
  return "Hello \(input)"
}

let composition = randomInt >>> stringifyInt >>> helloString
