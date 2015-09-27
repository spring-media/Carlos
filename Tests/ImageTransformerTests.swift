import Foundation
import Quick
import Nimble
import Carlos

class ImageTransformerTests: QuickSpec {
  override func spec() {
    describe("Image transformer") {
      var transformer: ImageTransformer!
      
      beforeEach {
        transformer = ImageTransformer()
      }
      
      context("when transforming NSData to UIImage") {
        var result: UIImage?
        
        context("when the NSData is a valid image") {
          var imageSample: UIImage!
          
          beforeEach {
            imageSample = UIImage(named: "swift-og", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            
            result = transformer.transform(UIImagePNGRepresentation(imageSample)!)
          }
          
          it("should not return nil") {
            expect(result).notTo(beNil())
          }
          
          it("should return the expected data") {
            expect(UIImagePNGRepresentation(result!)).to(equal(UIImagePNGRepresentation(imageSample)))
          }
        }
        
        context("when the NSData is not a valid image") {
          beforeEach {
            result = transformer.transform("test for an invalid image".dataUsingEncoding(NSUTF8StringEncoding)!)
          }
          
          it("should return nil") {
            expect(result).to(beNil())
          }
        }
      }
      
      context("when transforming UIImage to NSData") {
        var imageSample: UIImage!
        var result: NSData?
        
        beforeEach {
          imageSample = UIImage(named: "swift-og", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
          
          result = transformer.inverseTransform(imageSample)
        }
        
        it("should not return nil") {
          expect(result).notTo(beNil())
        }
        
        it("should return the expected data") {
          expect(result).to(equal(UIImagePNGRepresentation(imageSample)))
        }
      }
    }
  }
}