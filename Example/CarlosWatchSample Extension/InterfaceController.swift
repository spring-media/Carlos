import WatchKit
import Foundation

import Carlos
import Combine

private struct Country {
  let name: String
  let flagURL: URL
}

class InterfaceController: WKInterfaceController {
  @IBOutlet var tableView: WKInterfaceTable!
  
  let imageCache = CacheProvider.imageCache()
  
  private var cancellables = Set<AnyCancellable>()
  
  private let countries = [
    Country(name: "Italy", flagURL: URL(string: "http://2.bp.blogspot.com/-51ZhmfLCi9s/VBLNUQL-giI/AAAAAAAAAfA/LTayxh5K3C4/s1600/flag_italy_mini.gif")!),
    Country(name: "Germany", flagURL: URL(string: "http://www.weezerpedia.com/wiki/images/e/eb/Flag-germany.png")!),
    Country(name: "France", flagURL: URL(string: "http://www.worldflagsportal.com/pics/thumbnails/france-flag.png")!),
    Country(name: "Netherlands", flagURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Flag_of_the_Netherlands.svg/50px-Flag_of_the_Netherlands.svg.png")!),
    Country(name: "South Africa", flagURL: URL(string: "https://8b90b43d6bcfc09ee36c-3ad5470e7d4bb324e402ac2f90d6d0ba.ssl.cf3.rackcdn.com/soaf_1.gif")!),
    Country(name: "USA", flagURL: URL(string: "http://www.scramblestuff.us/images/us_flag.png")!),
    Country(name: "Australia", flagURL: URL(string: "http://dropdownaustralia.com/wp-content/uploads/2013/11/Australian-Flag.png")!),
    Country(name: "Spain", flagURL: URL(string: "http://www.romanhomes.com/vacation_rentals/images/navona-campo-fiori-turtles-dream/navona-campo-fiori-turtles-dream/flag-spain-small.jpg")!),
    Country(name: "Austria", flagURL: URL(string: "http://flagpedia.net/data/flags/mini/at.png")!),
    Country(name: "Congo", flagURL: URL(string: "https://www.usaid.gov/sites/default/files/styles/40x24_flag/public/missions/flags/congo-democratic-republic-of.gif?itok=xRT3uqRi")!),
    Country(name: "Cuba", flagURL: URL(string: "http://flagpedia.net/data/flags/mini/cu.png")!),
    Country(name: "UK", flagURL: URL(string: "http://images.smh.com.au/2012/07/18/3464759/Olympic-Flag-Icon_Great_Britain.gif")!)
  ]
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    tableView.setNumberOfRows(countries.count, withRowType: "CountryRow")

    for (idx, country) in countries.enumerated() {
      if let row = tableView.rowController(at: idx) as? CountryRow {
        row.countryName.setText(country.name)
        row.flagImage.setImage(UIImage(named: "placeholder"))
        
        imageCache.get(country.flagURL).sink(receiveCompletion: { _ in }) { image in
          row.flagImage.setImage(image)
        }.store(in: &cancellables)
      }
    }
  }
}
