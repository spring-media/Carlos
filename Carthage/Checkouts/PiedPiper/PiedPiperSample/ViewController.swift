import UIKit
import PiedPiper

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // MARK: Function composition
    let double = multiply(2)
    let plus3 = add(3)
    
    let composed = double >>> plus3 >>> triple
    
    print(composed(5)) // prints 39 ((5 * 2) + 3) * 3
    
    // MARK: Futures
    let future: Future<Int> = Future {
      composed(-5)
    }
    
    future
      .onSuccess {
        print("Succeeded with \($0)") // prints -21
      }
      .onCompletion { result in
        // MARK: Result
        if let value = result.value {
          print("Completed with \(value)") // prints -21 as well
        }
      }
    
    // MARK: Advanced operations on futures
    let processed = future
      .filter {
        $0 > 0
      }
      .flatMap {
        Future("Processed string result is \($0)")
      }
      .map {
        "\($0)".uppercaseString
      }
    
    processed
      .onSuccess {
        print("Processed future succeeded with value \"\($0)\"") // doesn't print
      }
      .onFailure {
        print("Processed future failed with error \($0)") // prints with error ConditionedUnsatisfied (for the filter)
      }
    
    let willSucceed = processed.recover {
      "Failed because of negative input"
    }
    
    willSucceed.onSuccess {
      print("Recovered future succeeded with value \"\($0)\"") // prints "Recovered future succeeded with value "Failed because of negative input""
    }
    
    // MARK: Operations on arrays of Futures
    let inputs = [-5, 0, 5]
    let futures: [Future<Int>] = inputs.map { input in
      Future {
        composed(input)
      }
    }
    
    let reduced = futures.reduce(0, combine: +)
    let collapsed = futures.merge()
    
    collapsed.onSuccess {
      print("Collapsed result: \($0)") // prints [-21, 9, 39]
    }
    
    reduced.onSuccess {
      print("Reduced result: \($0)") // prints 27 (-21 + 9 + 39)
    }
    
    let name = Future {
      "foo"
    }
    
    let value = Future {
      0
    }
    
    name.zip(value).onSuccess {
      print("Zipped result: \($0)") // prints ("foo", 0)
    }
  }
  
  private func multiply(by: Int) -> Int -> Int {
    return { input in
      input * by
    }
  }
  
  private func add(input: Int) -> Int -> Int {
    return { num in
      num + input
    }
  }
  
  private func triple(input: Int) -> Int {
    return input * 3
  }
}

