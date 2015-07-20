import Foundation
import UIKit

class ExampleCell: UITableViewCell {
  static let Identifier = "ExampleCell"
  
  @IBOutlet var sampleTitleLabel: UILabel?
  @IBOutlet var sampleDescriptionLabel: UILabel?
  
  func configureWithExample(example: Example) {
    sampleTitleLabel?.text = example.name
    sampleDescriptionLabel?.text = example.shortDescription
  }
}