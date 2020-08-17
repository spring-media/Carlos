import Foundation
import MapKit

import Quick
import Nimble

import Carlos
import OpenCombine

final class MKDistanceFormatterTransformerTests: QuickSpec {
  override func spec() {
    describe("MKDistanceFormatter") {
      var formatter: MKDistanceFormatter!
      var cancellable: AnyCancellable?
      
      beforeEach {
        formatter = MKDistanceFormatter()
        formatter.units = .metric
      }
      
      afterEach {
        cancellable?.cancel()
        cancellable = nil
      }
      
      context("when used as a transformer") {
        context("when transforming") {
          let originDistance: CLLocationDistance = 10293.12
          var resultString: String!
          
          beforeEach {
            cancellable = formatter.transform(originDistance)
              .sink(receiveCompletion: { _ in }, receiveValue: { resultString = $0 })
          }
          
          it("should return the expected string") {
            expect(resultString).toEventually(equal("10 km"))
          }
        }
        
        context("when inverse transforming") {
          let originString = "10 km"
          var resultDistance: CLLocationDistance!
          
          beforeEach {
            cancellable = formatter.inverseTransform(originString)
              .sink(receiveCompletion: { _ in }, receiveValue: { resultDistance = $0 })
          }
          
          it("should return the expected number") {
            expect(resultDistance).toEventually(equal(10000.0))
          }
        }
      }
    }
  }
}
