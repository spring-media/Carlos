import Foundation
import Quick
import Nimble
import Carlos

#if !os(macOS)
import UIKit

class ImageTransformerTests: QuickSpec {
  override func spec() {
    describe("Image transformer") {
      var transformer: ImageTransformer!
      var error: Error!
      var sampleData: Data!
      
      beforeEach {
        error = nil
        
        transformer = ImageTransformer()
      }
      
      beforeSuite {
        sampleData = Data(base64Encoded: base64EncodedImage, options: .ignoreUnknownCharacters)
      }
      
      afterSuite {
        sampleData = nil
      }
      
      context("when transforming NSData to UIImage") {
        var result: UIImage!
        
        beforeEach {
          result = nil
        }
        
        context("when the NSData is a valid image") {
          var imageSample: UIImage!
          
          beforeEach {
            imageSample = UIImage(data: sampleData)
            
            transformer.transform(imageSample.pngData()! as NSData)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should call the success closure") {
            expect(result).toEventuallyNot(beNil())
          }
          
          it("should not call the error closure") {
            expect(error).toEventually(beNil())
          }
          
          it("should return the expected data") {
            expect(result!.pngData()).toEventually(equal(imageSample.pngData()))
          }
        }
        
        context("when the NSData is not a valid image") {
          beforeEach {
            transformer.transform(("test for an invalid image".data(using: .utf8) as NSData?)!)
              .onSuccess({ result = $0 })
              .onFailure({ error = $0 })
          }
          
          it("should not call the success closure") {
            expect(result).toEventually(beNil())
          }
          
          it("should call the error closure") {
            expect(error).toEventuallyNot(beNil())
          }
        }
        
      }
      
      context("when transforming UIImage to NSData") {
        var imageSample: UIImage!
        var result: NSData!
        
        beforeEach {
          imageSample = UIImage(data: sampleData)
          
          transformer.inverseTransform(imageSample)
            .onSuccess({ result = $0 })
            .onFailure({ error = $0 })
        }
        
        it("should call the success closure") {
          expect(result).toEventuallyNot(beNil())
        }
        
        it("should not call the failure closure") {
          expect(error).toEventually(beNil())
        }
        
        it("should return the expected data") {
          expect(result).toEventually(equal(imageSample.pngData() as NSData?))
        }
      }
    }
  }
}
#endif
