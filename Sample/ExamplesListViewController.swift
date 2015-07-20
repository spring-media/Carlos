import Foundation
import UIKit

struct ExamplesListSection {
  let name: String
  let samples: [Example]
}

struct Example {
  let name: String
  let shortDescription: String
  let segueIdentifier: String
}

class ExamplesListViewController: UIViewController {
  private let sections = [
    ExamplesListSection(name: "Simple", samples: [
      Example(name: "Simple cache", shortDescription: "memory-disk-network", segueIdentifier: "simpleCache"),
      Example(name: "Memory warnings", shortDescription: "Simple stack with memory warnings listeners", segueIdentifier: "")
    ]),
    ExamplesListSection(name: "Advanced", samples: [
      Example(name: "Complex cache", shortDescription: "Custom stack with key and value transformations", segueIdentifier: ""),
      Example(name: "Conditioned cache", shortDescription: "Simple stack with conditioned levels", segueIdentifier: ""),
      Example(name: "Pooled cache", shortDescription: "Simple stack with requests pooling", segueIdentifier: "")
    ])
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Carlos Samples"
  }
}

extension ExamplesListViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].samples.count
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section].name
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ExampleCell.Identifier, forIndexPath: indexPath) as! ExampleCell
    
    cell.configureWithExample(sections[indexPath.section].samples[indexPath.row])
    
    return cell
  }
}

extension ExamplesListViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let example = sections[indexPath.section].samples[indexPath.row]
    
    performSegueWithIdentifier(example.segueIdentifier, sender: self)
  }
}