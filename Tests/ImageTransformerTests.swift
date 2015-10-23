import Foundation
import Quick
import Nimble
import Carlos

class ImageTransformerTests: QuickSpec {
  override func spec() {
    describe("Image transformer") {
      var transformer: ImageTransformer!
      var error: ErrorType!
      
      beforeEach {
        error = nil
        
        transformer = ImageTransformer()
      }
      
      context("when transforming NSData to UIImage") {
        var result: UIImage!
        
        beforeEach {
          result = nil
        }
        
        context("when the NSData is a valid image") {
          var imageSample: UIImage!
          
          beforeEach {
            imageSample = UIImage(named: "swift-og", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            
            transformer.transform(UIImagePNGRepresentation(imageSample)!)
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
            expect(UIImagePNGRepresentation(result!)).toEventually(equal(UIImagePNGRepresentation(imageSample)))
          }
        }
        
        context("when the NSData is not a valid image") {
          beforeEach {
            transformer.transform("test for an invalid image".dataUsingEncoding(NSUTF8StringEncoding)!)
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
          imageSample = UIImage(named: "swift-og", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
          
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
          expect(result).toEventually(equal(UIImagePNGRepresentation(imageSample)))
        }
      }
    }
  }
}