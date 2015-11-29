import Foundation
import Quick
import Nimble
import Carlos

class CacheProviderTests: QuickSpec {
  override func spec() {
    describe("Cache provider") {
      context("when calling imageCache") {
        var cache: BasicCache<NSURL, UIImage>!
        
        beforeEach {
          cache = CacheProvider.imageCache()
        }
        
        it("should always return new instances") {
          expect(CacheProvider.imageCache()).notTo(beIdenticalTo(cache))
        }
      }
      
      context("when calling dataCache") {
        var cache: BasicCache<NSURL, NSData>!
        
        beforeEach {
          cache = CacheProvider.dataCache()
        }
        
        it("should always return new instances") {
          expect(CacheProvider.dataCache()).notTo(beIdenticalTo(cache))
        }
      }
      
      context("when calling JSONCache") {
        var cache: BasicCache<NSURL, AnyObject>!
        
        beforeEach {
          cache = CacheProvider.JSONCache()
        }
        
        it("should always return new instances") {
          expect(CacheProvider.JSONCache()).notTo(beIdenticalTo(cache))
        }
      }
      
      context("when calling sharedImageCache") {
        var cache: BasicCache<NSURL, UIImage>!
        
        beforeEach {
          cache = CacheProvider.sharedImageCache
        }
        
        it("should always return the same instance") {
          expect(CacheProvider.sharedImageCache).to(beIdenticalTo(cache))
        }
      }
      
      context("when calling sharedDataCache") {
        var cache: BasicCache<NSURL, NSData>!
        
        beforeEach {
          cache = CacheProvider.sharedDataCache
        }
        
        it("should always return the same instance") {
          expect(CacheProvider.sharedDataCache).to(beIdenticalTo(cache))
        }
      }
      
      context("when calling sharedJSONCache") {
        var cache: BasicCache<NSURL, AnyObject>!
        
        beforeEach {
          cache = CacheProvider.sharedJSONCache
        }
        
        it("should always return the same instance") {
          expect(CacheProvider.sharedJSONCache).to(beIdenticalTo(cache))
        }
      }
    }
  }
}