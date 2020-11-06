import Foundation
import UIKit

class ExampleCell: UITableViewCell {
  static let Identifier = "ExampleCell"

  func configureWithExample(_ example: Example) {
    textLabel?.text = example.name
    detailTextLabel?.text = example.shortDescription
  }
}
