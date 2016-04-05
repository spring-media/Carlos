# Carlos

[![Build Status](https://www.bitrise.io/app/5146ccd8a33bdc42.svg?token=WncwcH_9wvpVKrjDl-lq_A&branch=master)](https://www.bitrise.io/app/5146ccd8a33bdc42)
[![CI Status](http://img.shields.io/travis/WeltN24/Carlos.svg?style=flat)](https://travis-ci.org/WeltN24/Carlos)
[![Version](https://img.shields.io/cocoapods/v/Carlos.svg?style=flat)](http://cocoapods.org/pods/Carlos)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/Carlos.svg?style=flat)](http://cocoapods.org/pods/Carlos)
[![Platform](https://img.shields.io/cocoapods/p/Carlos.svg?style=flat)](http://cocoapods.org/pods/Carlos)

> A simple but flexible cache, written in Swift for `iOS 8+`, `WatchOS 2`, `tvOS` and `Mac OS X` apps. It also ships with some utility functions to easily write asynchronous code.

# Contents of this Readme

- [What is Carlos?](#what-is-carlos)
- [Installation](#installation)
- [Playground](#playground)
- [Requirements](#requirements)
- [Usage](#usage)
- [Tests](#tests)
- [Future development](#future-development)
- [Apps using Carlos](#apps-using-carlos)
- [Authors](#authors)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## What is Carlos?

`Carlos` is a set of classes and functions that gives you many LEGO™-like building blocks based on the [Composite](https://en.wikipedia.org/wiki/Composite_pattern) and [Decorator](https://en.wikipedia.org/wiki/Decorator_pattern) design patterns to create and customize your cache infrastructure.
You start with a simple cache level or with one of the caches that `Carlos` provides you out-of-the-box, and then start applying its functions to build a tree structure of cache levels. The resulting root of the tree is a cache level itself, so you will be able to use it right away in your app.

For more information on how to use `Carlos`, please consult its complete [README](https://github.com/WeltN24/Carlos/blob/master/Carlos/README.md).

`Carlos` now also ships with a small set of functions that make it easier to write asynchronous code through the use of `Future`s and `Promise`s. The child framework is called `Pied Piper` and you can reda more about it [here](https://github.com/WeltN24/Carlos/blob/master/Futures/README.md).

## Installation

Information on how to integrate `Carlos` or `Pied Piper` in your project are available respectively [here](https://github.com/WeltN24/Carlos/blob/master/Carlos/README.md#installation) and [here](https://github.com/WeltN24/Carlos/blob/master/Futures/README.md#installation).

## Playground

`Carlos` and `Pied Piper` ship with 2 playgrounds for you to get to know the frameworks better. 
You can find more information on how to use the playground respectively [here](https://github.com/WeltN24/Carlos/blob/master/Carlos/README.md#playground) and [here](https://github.com/WeltN24/Carlos/blob/master/Futures/README.md#playground).

## Requirements

- iOS 8.0+
- WatchOS 2+
- Mac OS X 10.9+
- Xcode 7.3+
- tvOS 9+

## Usage

To run the example project, clone the repo. You'll find sample schemes for `iOS`, `watchOS`, `Mac OS` and `tvOS`.

For detailed information about what it's possible to do with `Carlos` and `Pied Piper` please respectively have a look [here](https://github.com/WeltN24/Carlos/blob/master/Carlos/README.md#usage) and [here](https://github.com/WeltN24/Carlos/blob/master/Futures/README.md#usage).

## Tests

`Carlos` and `Pied Piper` are thouroughly tested so that the features they are designed to provide are safe for refactoring and as much as possible bug-free. 

We use [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble) instead of `XCTest` in order to have a good BDD test layout, and have more than **2300 tests** covering the codebase at the moment.

## Future development

`Carlos` and `Pied Piper` are under development and [here](https://github.com/WeltN24/Carlos/issues) you can see all the open issues. They are assigned to milestones so that you can have an idea of when a given feature will be shipped.

If you want to contribute to this repo, please:

- Create an issue explaining your problem and your solution
- Clone the repo on your local machine
- Create a branch with the issue number and a short abstract of the feature name
- Implement your solution
- Write tests (untested features won't be merged)
- When all the tests are written and green, create a pull request, with a short description of the approach taken

## Apps using Carlos

- [Die Welt Edition](https://itunes.apple.com/de/app/welt-edition-digitale-zeitung/id372746348?mt=8)

Using Carlos? Please let us know through a Pull request, we'll be happy to mention your app!

## Authors

`Carlos` and `Pied Piper` were made in-house by WeltN24

### Contributors:

Vittorio Monaco, [vittorio.monaco@weltn24.de](mailto:vittorio.monaco@weltn24.de), [@vittoriom](https://github.com/vittoriom) on Github, [@Vittorio_Monaco](https://twitter.com/Vittorio_Monaco) on Twitter

Esad Hajdarevic, @esad

## License

`Carlos` and `Pied Piper` are available under the MIT license. See the LICENSE files for more info.

## Acknowledgements

`Carlos` internally uses:

- **Crypto** (available on [Github](https://github.com/krzyzanowskim/CryptoSwift)), slightly adapted to compile with Swift 2.0.
- **ConcurrentOperation** (by [Caleb Davenport](https://github.com/calebd)), unmodified.

The **DiskCacheLevel** class is inspired by [Haneke](https://github.com/Haneke/HanekeSwift). The source code has been heavily modified, but adapting the original file has proven valuable for `Carlos` development.

`Pied Piper` internally uses:

- Some parts of `ReadWriteLock.swift` (in particular the pthread-based read-write lock) belonging to **Deferred** (available on [Github](https://github.com/bignerdranch/Deferred))