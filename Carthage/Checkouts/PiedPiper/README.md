# Pied Piper

[![Build Status](https://www.bitrise.io/app/15d84dbcea6e8eaa.svg?token=xrhXybdly56q5EbX-vD8Nw&branch=master)](https://www.bitrise.io/app/15d84dbcea6e8eaa)
[![CI Status](https://travis-ci.org/WeltN24/PiedPiper.svg?branch=master)](https://travis-ci.org/WeltN24/PiedPiper)
[![Version](https://img.shields.io/cocoapods/v/PiedPiper.svg?style=flat)](http://cocoapods.org/pods/PiedPiper)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/PiedPiper.svg?style=flat)](http://cocoapods.org/pods/PiedPiper)
[![Platform](https://img.shields.io/cocoapods/p/PiedPiper.svg?style=flat)](http://cocoapods.org/pods/PiedPiper)

> A small set of classes and functions to make easy use of `Future`s, `Promise`s and async computation in general. All written in Swift for `iOS 8+`, `WatchOS 2`, `tvOS` and `Mac OS X` apps.

# Contents of this Readme

- [What is Pied Piper?](#what-is-pied-piper)
- [Installation](#installation)
- [Playground](#playground)
- [Requirements](#requirements)
- [Usage](#usage)
	- [Usage examples](#usage-examples)
	- [Futures](#futures)
	- [Promises](#promises)
	- [GCD Computation](#gcd-computation)
	- [Advanced usage with Futures](#advanced-usage-with-futures)
	- [Function composition](#function-composition)
- [Tests](#tests)
- [Future development](#future-development)
- [Apps using Pied Piper](#apps-using-pied-piper)
- [Authors](#authors)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## What is Pied Piper?

`Pied Piper` is a small set of classes, functions and convenience operators to **write easy asynchronous code** in your application.

With `Pied Piper` you can:

- Use [`Future`](#futures)s and [`Promise`](#promises)s for your async tasks
- Write easy to read async code [on top of GCD](#gcd-computation)
- [Compose asynchronous functions](#function-composition) in an intuitive way

## Installation

### CocoaPods

`Pied Piper` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "PiedPiper"
```

### Submodule

If you don't use CocoaPods, you can still add `Pied Piper` as a submodule, drag and drop `PiedPiperSample.xcodeproj` into your project, and embed `PiedPiper.framework` in your target.

- Drag `PiedPiperSample.xcodeproj` to your project
- Select your app target
- Click the `+` button on the `Embedded binaries` section
- Add `PiedPiper.framework`

### Carthage

`Carthage` is also supported.

### Manual

You can directly drag and drop the needed files into your project, but keep in mind that this way you won't be able to automatically get all the latest `Pied Piper` features (e.g. new files including new operations).

The files are contained in the `PiedPiper` folder and work for the `iOS`, `watchOS`, `MacOS` and `tvOS` frameworks.

## Playground

We ship a small Xcode Playground with the project, so you can quickly see how `Pied Piper` works and experiment with your custom layers, layers combinations and different configurations for requests pooling, capping, etc.

To use our Playground, please follow these steps:

- Open the Xcode project `PiedPiperSample.xcodeproj`
- Select the `Pied Piper` framework target, and a **64-bit platform** (e.g. `iPhone 6`)
- Build the target with `⌘+B`
- Click the Playground file `PiedPiper.playground`
- Write your code

## Requirements

- iOS 8.0+
- WatchOS 2+
- Mac OS X 10.9+
- Xcode 7.3+
- tvOS 9+

## Usage

To run the example project, clone the repo.

### Usage examples

### Futures

A `Future` is an object representing a computation that may not have happened yet. You can add callback handlers for the success, failure, and cancelation events of a specific `Future`.

Please keep in mind that a `Future` is not a signal. It can only fail, succeed or cancel (mutually exclusive) and it can only do so once.

Please also note that a `Future` is "read-only". This means you can not actively determine the result of an instance. If you are implementing your own asynchronous computations, please have a look at [promises](#promises) instead.

```swift
// The login function returns a Future
let login = userManager.login(username, password)

// You can specify success or failure callbacks, and chain the calls together
login.onSuccess { user in
  print("User \(user.username) logged in successfully!")
}.onFailure { error in
  print("Error \(error) during login")
}.onCancel {
  print("Login was cancelled by the user")
}

// Or you can use onCompletion instead
login.onCompletion { result in
  switch result {
  case .Success(let user):
  	print("User \(user.username) logged in successfully!")
  case .Error(let error):
    print("Error \(error) during login")
  case .Cancelled:
    print("Login was cancelled by the user")
  }
}
```

Since `Pied Piper 0.8` you can use convenience initializers on `Future` if you already know the result without any asynchronous work:

```swift
let future = Future(10)

// or

let future = Future(MyError.SomeError)

// or

let future = Future(value: possiblyNil, error: MyError.SomeError)

// or

let future: Future<UIImage> = Future {
	return asyncCodeThatFetchesImage()
}
```

### Promises

`Future`s are really handy when you are the user of some async computations. But sometimes you may want to be the producer of these, and in this case you need to be able to determine when a `Future` should succeed or fail. Then you need a `Promise`.

```swift
func login(username: String, password: String) -> Future<User> {
  // Promises, like Futures, are generic
  let promise = Promise<User>()

  GCD.background {
    //Request to the server...
    //...
    if response.statusCode == 200 {
      // Success
      promise.succeed(userFromResponse(response))
    } else {
      // Your ErrorType can be used as an argument to fail
      promise.fail(LoginError.InvalidCredentials)
    }
  }

  // If the user wants to cancel the login request
  promise.onCancel {
    //cancel the request to the server
    //...
  }

  // we don't want users to be able to fail our request
  return promise.future
}
```

### GCD computation

`Pied Piper` offers some helper functions on top of GCD to run blocks of code on the main queue or on a background queue.

```swift
//Without Pied Piper
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
  // Execute your asynchronous code
  // ...
  let result = 10

  // Notify on the main queue
  dispatch_async(dispatch_get_main_queue()) {
    print("Result is \(result)")
  }
}

//With Pied Piper
GCD.background { Void -> Int in
  // Execute your asynchronous code
  return 10
}.main { result in
  print("Result is \(result)")
}
```

You can also run your asynchronous code on serial queues or your own queues.

```swift
// Serial queue
let queue = GCD.serial("test")

// Your own queue
let queue = GCD(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))

// Then...
queue.async { Void -> Int in
  return 10
}.main {
  print($0)
}
```

### Advanced usage with Futures

Since `Pied Piper 0.8` many convenience functions are available on `Future` values, like `map`, `flatMap`, `filter`, `recover`, `retry`, `zip`, `reduce`, `mergeSome` and `mergeAll`. Moreover, `traverse` is available for all `SequenceType` values.

Since `Pied Piper 0.9` some more functions are available like `snooze`, `timeout` and `firstCompleted` (the latter for a `SequenceType` of `Future` values).

Keep in mind that some of these functions (`map`, `flatMap` and `filter`) are also available on `Result` values. They work just like their `Future` counterparts.

#### FlatMap, Map, Filter

```swift
// In this snippet `doStuff` returns a Future<Int>
let newFuture = doStuff().filter { value in
  value > 0
}.flatMap { value in
  Future("\(value)")
}.map { value in
  "The result is \(value)"
}

// `newFuture` is now a Future<String> that will only succeed when the original Future succeeds with a value > 0
```

#### Recover

It's now also possible to provide a "catch-all" handler to recover a failing `Future`:

```swift
let numberOfItemsTask: Future<Int> = doLongRunningTask()
  .flatMap { result in
    result.processAndPersist()
  }.map { result in
    result.numberOfItems
  }.recover {
    cache.lastNumberOfItems
  }

numberOfItemsTask.onSuccess { numberOfItems in
  // This will be called even if one of the previous operations fails, with the rescue value `cache.lastNumberOfItems`
  // ...
}
```

#### Zip

```swift
// Example for zip

let first: Future<Int> = doFoo()
let second: Future<String> = doBar()

let zipped = first.zip(second).onSuccess { (anInteger, aString) in
  // you get an Int and a String here
}

// or:

let first: Future<Int> = doFoo()
let second: Result<String> = doBar()

let zipped = first.zip(second).onSuccess { (anInteger, aString) in
  // you get an Int and a String here
}
```

#### Reduce

```swift
// Let's assume this value contains a list of server requests where each request obtains the number of items in a given category
let serverRequests: [Future<Int>] = doFoo()

// With this `reduce` call we calculate the total number of items
let sumOfServerResults = serverRequests.reduce(0, combine: +).onSuccess {
  // We get here only if all futures succeed
  print("Sum of results is \($0)")
}
```

#### MergeAll

```swift
// Let's assume this value contains a list of server requests where each request obtains the number of items in a given category
let serverRequests: [Future<Int>] = doFoo()

// With this `mergeAll` call we collapse the requests into one containing the result of all of them, if they all succeeded, or none if one fails
let allServerResults = serverRequests.mergeAll().onSuccess { results in
  // We get here only if all futures succeed
  // `results` is an [Int]
}
```

#### All 

`all` behaves exactly like `mergeAll`, except that it doesn't bring the success values with it.

```swift
// Let's assume this value contains a list of server requests where each request obtains the number of items in a given category
let serverRequests: [Future<Int>] = doFoo()

// With this `all` call we collapse the requests into one that will succeed if all of the elements succeed, otherwise it will fail
let allServerResults = serverRequests.mergeAll().onSuccess {
  // We get here only if all futures succeed
}
```

#### MergeSome

```swift
// Let's assume this value contains a list of server requests where each request obtains the number of items in a given category
let serverRequests: [Future<Int>] = doFoo()

// With this `mergeSome` call we collapse the requests into one containing the result of just the ones that succeed
let allServerResults = serverRequests.mergeSome().onSuccess { results in
  // We get here and results.count == the number of succeeded requests
  // `results` is an [Int]
}

// Note: `merge` succeeds only when _all_ requests succeed, while `mergeSome` always succeeds and filters out the failed requests from the results
```

#### FirstCompleted

```swift
// Let's assume this value contains a list of server requests where each request comes from a different server but all of them answer the same question
let serverRequests: [Future<[Product]>] = gatherRequests()

/// With this `firstCompleted` call we basically declare we are interested in only the first result and want to discard the remaining ones
let firstResult = serverRequests.firstCompleted().onSuccess { products in
  // We get here with the first completing request
}
```

#### Traverse

```swift
// Let's assume this list contains some product identifiers
let productIdentifiers: [Int] = basketProductsIds()

// With this `traverse` call we create a Future for every identifier (for instance to retrieve details of each product), and we merge the results into one final Future
let allProductDetails = productIdentifiers.traverse({ productId in
  // Let's assume this call returns a Future<Product>
  ProductManager.retrieveDetailsForProduct(productId)
}).onSuccess { products in
  // We get here only if all futures succeed
  // `products` is a [Product]
}
```

#### Snooze

```swift
// Sometimes we may be running multiple operations in parallel and we may want to have some time in between to gather multiple values
let firstOperation = doFoo()
let secondOperation = doBar()

// With this call to `snooze` we declare we're not interested in immediate feedback from the second operation because we may want to process the result of the first, first.
secondOperation.snooze(0.5).onSuccess { value in 
}
```

#### Timeout

```swift
// Sometimes we may want to set an upper bound to the time an operation can run before moving on or showing something to the user
let longRunningOperation = doFoo()

longRunningOperation.timeout(after: 5).onFailure { err in
  if let error = err as? FutureError where error = FutureError.Timeout {
    // The operation timed out, but of course it's still running. We may keep adding observers to the original variable if we are still interested in the final result (see next lines)
    showAlert()
  }
}

longRunningOperation.onSuccess { value in
  showSuccessDialog()
}

```

#### Retry 

```swift
// Sometimes we want to retry a given block of code for a certain number of times before failing
retry(3, every: 0.5) {
  return networkManager.fetchLatestMessages() // This returns a Future
}.onSuccess { messages in
  // The operation succeeded at least once
}.onFailure { _ in
  // The operation failed 4 times (1 + retry count of 3)
}
```

### Function composition

`Pied Piper` can also be helpful when you want to compose the result of asynchronous computation in a single function or object.

There are 3 public functions as of `Pied Piper` 0.7:

- Compose functions

```swift
func randomInt() -> Int {
  return 4 //Guaranteed random
}

func stringifyInt(number: Int) -> String {
  return "\(number)"
}

func helloString(input: String) -> String {
  return "Hello \(input)!"
}

let composition = randomInt >>> stringifyInt >>> helloString

composition() //Prints "Hello 4!"
```

If one of the functions returns an `Optional`, and at call time the value is `nil`, the computation stops there:

```swift

func randomInt() -> Int {
  return 4 //Guaranteed random
}

func stringifyInt(number: Int) -> String? {
  return nil
}

func helloString(input: String) -> String {
  return "Hello \(input)"
}

let composition = randomInt >>> stringifyInt >>> helloString

composition() //Doesn't print
```

- Compose `Future`s:

```swift

func intFuture(input: Int) -> Future<Int> {
  return Future(input)
}

func stringFuture(input: Int) -> Future<String> {
  return Future("Hello \(input)!")
}

let composition = intFuture >>> stringFuture

composition(1).onSuccess { result in
  print(result) //Prints "Hello 1!"
}
```

## Tests

`Pied Piper` is thouroughly tested so that the features it's designed to provide are safe for refactoring and as bug-free as possible.

We use [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble) instead of `XCTest` in order to have a good BDD test layout.

As of today, there are around **600 tests** for `Pied Piper` (see the folder `PiedPiperTests`).

## Future development

`Pied Piper` is under development and [here](https://github.com/WeltN24/PiedPiper/issues) you can see all the open issues. They are assigned to milestones so that you can have an idea of when a given feature will be shipped.

If you want to contribute to this repo, please:

- Create an issue explaining your problem and your solution
- Clone the repo on your local machine
- Create a branch with the issue number and a short abstract of the feature name
- Implement your solution
- Write tests (untested features won't be merged)
- When all the tests are written and green, create a pull request, with a short description of the approach taken

## Apps using Pied Piper

- [Die Welt Edition](https://itunes.apple.com/de/app/welt-edition-digitale-zeitung/id372746348?mt=8)

Using Pied Piper? Please let us know through a Pull request, we'll be happy to mention your app!

## Authors

`Pied Piper` was made in-house by WeltN24

### Contributors:

Vittorio Monaco, [vittorio.monaco@weltn24.de](mailto:vittorio.monaco@weltn24.de), [@vittoriom](https://github.com/vittoriom) on Github, [@Vittorio_Monaco](https://twitter.com/Vittorio_Monaco) on Twitter

## License

`Pied Piper` is available under the MIT license. See the LICENSE file for more info.

## Acknowledgements

`Pied Piper` internally uses:

- Some parts of `ReadWriteLock.swift` (in particular the pthread-based read-write lock) belonging to **Deferred** (available on [Github](https://github.com/bignerdranch/Deferred))
