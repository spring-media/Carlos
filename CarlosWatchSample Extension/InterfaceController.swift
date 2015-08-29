import WatchKit
import Foundation
import CarlosWatch

private struct Country {
  let name: String
  let flagURL: NSURL
}

class InterfaceController: WKInterfaceController {
  @IBOutlet var tableView: WKInterfaceTable!
  
  let imageCache = CacheProvider.imageCache().capRequests(3)
  
  private let countries = [
    Country(name: "Italy", flagURL: NSURL(string: "http://2.bp.blogspot.com/-51ZhmfLCi9s/VBLNUQL-giI/AAAAAAAAAfA/LTayxh5K3C4/s1600/flag_italy_mini.gif")!),
    Country(name: "Germany", flagURL: NSURL(string: "http://www.weezerpedia.com/wiki/images/e/eb/Flag-germany.png")!),
    Country(name: "France", flagURL: NSURL(string: "http://www.worldflagsportal.com/pics/thumbnails/france-flag.png")!),
    Country(name: "Netherlands", flagURL: NSURL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Flag_of_the_Netherlands.svg/50px-Flag_of_the_Netherlands.svg.png")!),
    Country(name: "South Africa", flagURL: NSURL(string: "https://8b90b43d6bcfc09ee36c-3ad5470e7d4bb324e402ac2f90d6d0ba.ssl.cf3.rackcdn.com/soaf_1.gif")!),
    Country(name: "USA", flagURL: NSURL(string: "http://www.scramblestuff.us/images/us_flag.png")!),
    Country(name: "Australia", flagURL: NSURL(string: "http://dropdownaustralia.com/wp-content/uploads/2013/11/Australian-Flag.png")!),
    Country(name: "Spain", flagURL: NSURL(string: "http://www.romanhomes.com/vacation_rentals/images/navona-campo-fiori-turtles-dream/navona-campo-fiori-turtles-dream/flag-spain-small.jpg")!),
    Country(name: "Austria", flagURL: NSURL(string: "http://flagpedia.net/data/flags/mini/at.png")!),
    Country(name: "Congo", flagURL: NSURL(string: "https://www.usaid.gov/sites/default/files/styles/40x24_flag/public/missions/flags/congo-democratic-republic-of.gif?itok=xRT3uqRi")!),
    Country(name: "Cuba", flagURL: NSURL(string: "http://flagpedia.net/data/flags/mini/cu.png")!),
    Country(name: "UK", flagURL: NSURL(string: "http://images.smh.com.au/2012/07/18/3464759/Olympic-Flag-Icon_Great_Britain.gif")!)
  ]
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    tableView.setNumberOfRows(countries.count, withRowType: "CountryRow")

    for (idx, country) in countries.enumerate() {
      if let row = tableView.rowControllerAtIndex(idx) as? CountryRow {
        row.countryName.setText(country.name)
        row.flagImage.setImage(UIImage(named: "placeholder"))
        
        imageCache.get(country.flagURL).onSuccess {
          row.flagImage.setImage($0)
        }
      }
    }
  }
}
