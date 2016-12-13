import Foundation
import Quick
import Nimble
import Carlos
import MapKit

class MKDistanceFormatterTransformerTests: QuickSpec {
  override func spec() {
    describe("MKDistanceFormatter") {
      var formatter: MKDistanceFormatter!
      
      beforeEach {
        formatter = MKDistanceFormatter()
        formatter.units = .metric
      }
      
      context("when used as a transformer") {
        context("when transforming") {
          let originDistance: CLLocationDistance = 10293.12
          var resultString: String!
          
          beforeEach {
            formatter.transform(originDistance).onSuccess { resultString = $0 }
          }
          
          it("should return the expected string") {
            expect(resultString).to(equal("10 km"))
          }
        }
        
        context("when inverse transforming") {
          let originString = "10 km"
          var resultDistance: CLLocationDistance!
          
          beforeEach {
            formatter.inverseTransform(originString).onSuccess { resultDistance = $0 }
          }
          
          it("should return the expected number") {
            expect(resultDistance).to(equal(10000.0))
          }
        }
      }
    }
  }
}
