import Foundation

import Nimble
import Quick

import Carlos

final class CacheProviderTests: QuickSpec {
  override func spec() {
    describe("Cache provider") {
      context("when calling imageCache") {
        var cache: BasicCache<URL, CarlosImage>!

        beforeEach {
          cache = CacheProvider.imageCache()
        }

        it("should always return new instances") {
          expect(CacheProvider.imageCache()).notTo(beIdenticalTo(cache))
        }
      }

      context("when calling dataCache") {
        var cache: BasicCache<URL, NSData>!

        beforeEach {
          cache = CacheProvider.dataCache()
        }

        it("should always return new instances") {
          expect(CacheProvider.dataCache()).notTo(beIdenticalTo(cache))
        }
      }

      context("when calling JSONCache") {
        var cache: BasicCache<URL, AnyObject>!

        beforeEach {
          cache = CacheProvider.JSONCache()
        }

        it("should always return new instances") {
          expect(CacheProvider.JSONCache()).notTo(beIdenticalTo(cache))
        }
      }

      context("when calling sharedImageCache") {
        var cache: BasicCache<URL, CarlosImage>!

        beforeEach {
          cache = CacheProvider.sharedImageCache
        }

        it("should always return the same instance") {
          expect(CacheProvider.sharedImageCache) === cache
        }
      }

      context("when calling sharedDataCache") {
        var cache: BasicCache<URL, NSData>!

        beforeEach {
          cache = CacheProvider.sharedDataCache
        }

        it("should always return the same instance") {
          expect(CacheProvider.sharedDataCache) === cache
        }
      }

      context("when calling sharedJSONCache") {
        var cache: BasicCache<URL, AnyObject>!

        beforeEach {
          cache = CacheProvider.sharedJSONCache
        }

        it("should always return the same instance") {
          expect(CacheProvider.sharedJSONCache) === cache
        }
      }
    }
  }
}
