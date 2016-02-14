//
//  BusinessesFilterViewController.swift
//  Yelp
//
//  Created by Rick Song on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol BusinessFiltersDelegate: class {
    func updateBusinessFilters(settings: BusinessFiltersViewController, didSaveBusinessFilters businessFilters:BusinessFilters)
    
    func initialBusinessFilters() -> BusinessFilters?
}

enum BusinessFiltersSectionIdentifier: Int {
    case Deals = 0, Distance, SortBy, Category
}

struct BusinessFiltersSection {
    let identifier : BusinessFiltersSectionIdentifier!
    let heading : String!
    let rows : [BusinessFiltersRow]
    
    init(identifier: BusinessFiltersSectionIdentifier, heading: String, rows: [BusinessFiltersRow]) {
        self.identifier = identifier
        self.heading = heading
        self.rows = rows
    }
}

struct BusinessFiltersRow {
    let name : String!
    let code : Any?
    
    init(name: String, code: Any?) {
        self.name = name
        self.code = code
    }
}

class BusinessFiltersViewController: UIViewController, UITableViewDataSource, BusinessFilterCellDelegate {
    @IBOutlet var businessFiltersTableView: UITableView!
    
    weak var delegate: BusinessFiltersDelegate?
    
    var businessesViewController: BusinessesViewController?
    var businessFilters : BusinessFilters!
    
    // Initialization Methods
    // ============================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialBusinessFilters = self.delegate?.initialBusinessFilters()
        
        self.businessFilters = BusinessFilters(
            term: initialBusinessFilters?.term ?? BusinessFilters.Defaults.term,
            sort: initialBusinessFilters?.sort ?? BusinessFilters.Defaults.sort,
            distance: initialBusinessFilters?.distance ?? BusinessFilters.Defaults.distance,
            categories: initialBusinessFilters?.categories ?? BusinessFilters.Defaults.categories,
            deals: initialBusinessFilters?.deals ?? BusinessFilters.Defaults.deals
        )
        
        self.businessFiltersTableView.allowsSelection = false
        self.businessFiltersTableView.dataSource = self
        self.businessFiltersTableView.estimatedRowHeight = 150
        self.businessFiltersTableView.rowHeight = UITableViewAutomaticDimension
    
        self.businessFiltersTableView.reloadData()
    }
    
    // Table View Delegate Methods
    // ============================
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return BusinessFiltersViewController.TableStructure.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return BusinessFiltersViewController.TableStructure[section].heading
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BusinessFiltersViewController.TableStructure[section].rows.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let businessFilterTableViewCell = tableView.dequeueReusableCellWithIdentifier("com.ricksong.BusinessFilterTableViewCell") as! BusinessFilterTableViewCell
        
        let businessFiltersSection = BusinessFiltersViewController.TableStructure[indexPath.section]
        let businessFiltersRow = businessFiltersSection.rows[indexPath.row]
        
        businessFilterTableViewCell.identifier = businessFiltersSection.identifier
        
        businessFilterTableViewCell.filterLabel.text = businessFiltersRow.name
        
        switch businessFilterTableViewCell.identifier! {
        case .Deals:
            businessFilterTableViewCell.filterSwitch.on = self.businessFilters.deals ?? false
        case .Distance:
            businessFilterTableViewCell.filterSwitch.on = (self.businessFilters.distance == (businessFiltersRow.code as! Float))
        case .SortBy:
            businessFilterTableViewCell.filterSwitch.on = (self.businessFilters.sort == (businessFiltersRow.code as! YelpSortMode))
        case .Category:
            businessFilterTableViewCell.filterSwitch.on = (self.businessFilters.categories?.contains(businessFiltersRow.code as! String)) ?? false
        }
        
        businessFilterTableViewCell.code = businessFiltersRow.code
        businessFilterTableViewCell.delegate = self
        
        return businessFilterTableViewCell
    }
    
    func businessFilterCellDidToggle(businessFilterTableViewCell: BusinessFilterTableViewCell, newValue: Bool) {
        switch businessFilterTableViewCell.identifier! {
        case .Deals:
            self.businessFilters.deals = newValue
        case .Distance:
            if (newValue) {
                self.businessFilters.distance = (businessFilterTableViewCell.code as! Float)
            } else {
                self.businessFilters.distance = BusinessFilters.Defaults.distance
            }
        case .SortBy:
            if (newValue) {
                self.businessFilters.sort = (businessFilterTableViewCell.code as! YelpSortMode)
            } else {
                self.businessFilters.sort = BusinessFilters.Defaults.sort
            }
        case .Category:
            if (newValue) {
                self.businessFilters.categories.insert(businessFilterTableViewCell.code as! String)
            } else {
                self.businessFilters.categories.remove(businessFilterTableViewCell.code as! String)
            }
        }
        
        self.businessFiltersTableView.reloadData()
        
    }
    
    // Utility Methods
    // ============================
    func updatedBusinessFilters() -> BusinessFilters {
        return self.businessFilters
    }
    
    // Actions
    // ============================
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onUpdateButton(sender: AnyObject) {
        delegate?.updateBusinessFilters(self, didSaveBusinessFilters: updatedBusinessFilters())
    }
}

extension BusinessFiltersViewController {
    static let TableStructure: [BusinessFiltersSection] = [
        BusinessFiltersSection(identifier: .Deals, heading: "",
            rows: [
                BusinessFiltersRow(name: "Offering a Deal", code: nil)
            ]),
        BusinessFiltersSection(identifier: .Distance, heading: "Distance",
            rows: [
                // Note that distance values are in _METERS_ not _MILES_
                BusinessFiltersRow(name: "Auto", code: Float(0)),
                BusinessFiltersRow(name: "4 blocks", code: Float(800)),
                BusinessFiltersRow(name: "1 mile", code: Float(1609.34)),
                BusinessFiltersRow(name: "5 miles", code: Float(8046.72)),
                BusinessFiltersRow(name: "20 miles", code: Float(32186.9))
            ]),
        BusinessFiltersSection(identifier: .SortBy, heading: "Sort By",
            rows: [
                BusinessFiltersRow(name: "Best Matched", code: YelpSortMode.BestMatched),
                BusinessFiltersRow(name: "Distance", code: YelpSortMode.Distance),
                BusinessFiltersRow(name: "Highest Rated", code: YelpSortMode.HighestRated)
            ]),
        BusinessFiltersSection(identifier: .Category, heading: "Category",
            rows: [
                BusinessFiltersRow(name: "Afghan", code: "afghani"),
                BusinessFiltersRow(name: "African", code: "african"),
                BusinessFiltersRow(name: "American, New", code: "newamerican"),
                BusinessFiltersRow(name: "American, Traditional", code: "tradamerican"),
                BusinessFiltersRow(name: "Arabian", code: "arabian"),
                BusinessFiltersRow(name: "Argentine", code: "argentine"),
                BusinessFiltersRow(name: "Armenian", code: "armenian"),
                BusinessFiltersRow(name: "Asian Fusion", code: "asianfusion"),
                BusinessFiltersRow(name: "Asturian", code: "asturian"),
                BusinessFiltersRow(name: "Australian", code: "australian"),
                BusinessFiltersRow(name: "Austrian", code: "austrian"),
                BusinessFiltersRow(name: "Baguettes", code: "baguettes"),
                BusinessFiltersRow(name: "Bangladeshi", code: "bangladeshi"),
                BusinessFiltersRow(name: "Barbeque", code: "bbq"),
                BusinessFiltersRow(name: "Basque", code: "basque"),
                BusinessFiltersRow(name: "Bavarian", code: "bavarian"),
                BusinessFiltersRow(name: "Beer Garden", code: "beergarden"),
                BusinessFiltersRow(name: "Beer Hall", code: "beerhall"),
                BusinessFiltersRow(name: "Beisl", code: "beisl"),
                BusinessFiltersRow(name: "Belgian", code: "belgian"),
                BusinessFiltersRow(name: "Bistros", code: "bistros"),
                BusinessFiltersRow(name: "Black Sea", code: "blacksea"),
                BusinessFiltersRow(name: "Brasseries", code: "brasseries"),
                BusinessFiltersRow(name: "Brazilian", code: "brazilian"),
                BusinessFiltersRow(name: "Breakfast & Brunch", code: "breakfast_brunch"),
                BusinessFiltersRow(name: "British", code: "british"),
                BusinessFiltersRow(name: "Buffets", code: "buffets"),
                BusinessFiltersRow(name: "Bulgarian", code: "bulgarian"),
                BusinessFiltersRow(name: "Burgers", code: "burgers"),
                BusinessFiltersRow(name: "Burmese", code: "burmese"),
                BusinessFiltersRow(name: "Cafes", code: "cafes"),
                BusinessFiltersRow(name: "Cafeteria", code: "cafeteria"),
                BusinessFiltersRow(name: "Cajun/Creole", code: "cajun"),
                BusinessFiltersRow(name: "Cambodian", code: "cambodian"),
                BusinessFiltersRow(name: "Canadian", code: "New)"),
                BusinessFiltersRow(name: "Canteen", code: "canteen"),
                BusinessFiltersRow(name: "Caribbean", code: "caribbean"),
                BusinessFiltersRow(name: "Catalan", code: "catalan"),
                BusinessFiltersRow(name: "Chech", code: "chech"),
                BusinessFiltersRow(name: "Cheesesteaks", code: "cheesesteaks"),
                BusinessFiltersRow(name: "Chicken Shop", code: "chickenshop"),
                BusinessFiltersRow(name: "Chicken Wings", code: "chicken_wings"),
                BusinessFiltersRow(name: "Chilean", code: "chilean"),
                BusinessFiltersRow(name: "Chinese", code: "chinese"),
                BusinessFiltersRow(name: "Comfort Food", code: "comfortfood"),
                BusinessFiltersRow(name: "Corsican", code: "corsican"),
                BusinessFiltersRow(name: "Creperies", code: "creperies"),
                BusinessFiltersRow(name: "Cuban", code: "cuban"),
                BusinessFiltersRow(name: "Curry Sausage", code: "currysausage"),
                BusinessFiltersRow(name: "Cypriot", code: "cypriot"),
                BusinessFiltersRow(name: "Czech", code: "czech"),
                BusinessFiltersRow(name: "Czech/Slovakian", code: "czechslovakian"),
                BusinessFiltersRow(name: "Danish", code: "danish"),
                BusinessFiltersRow(name: "Delis", code: "delis"),
                BusinessFiltersRow(name: "Diners", code: "diners"),
                BusinessFiltersRow(name: "Dumplings", code: "dumplings"),
                BusinessFiltersRow(name: "Eastern European", code: "eastern_european"),
                BusinessFiltersRow(name: "Ethiopian", code: "ethiopian"),
                BusinessFiltersRow(name: "Fast Food", code: "hotdogs"),
                BusinessFiltersRow(name: "Filipino", code: "filipino"),
                BusinessFiltersRow(name: "Fish & Chips", code: "fishnchips"),
                BusinessFiltersRow(name: "Fondue", code: "fondue"),
                BusinessFiltersRow(name: "Food Court", code: "food_court"),
                BusinessFiltersRow(name: "Food Stands", code: "foodstands"),
                BusinessFiltersRow(name: "French", code: "french"),
                BusinessFiltersRow(name: "French Southwest", code: "sud_ouest"),
                BusinessFiltersRow(name: "Galician", code: "galician"),
                BusinessFiltersRow(name: "Gastropubs", code: "gastropubs"),
                BusinessFiltersRow(name: "Georgian", code: "georgian"),
                BusinessFiltersRow(name: "German", code: "german"),
                BusinessFiltersRow(name: "Giblets", code: "giblets"),
                BusinessFiltersRow(name: "Gluten-Free", code: "gluten_free"),
                BusinessFiltersRow(name: "Greek", code: "greek"),
                BusinessFiltersRow(name: "Halal", code: "halal"),
                BusinessFiltersRow(name: "Hawaiian", code: "hawaiian"),
                BusinessFiltersRow(name: "Heuriger", code: "heuriger"),
                BusinessFiltersRow(name: "Himalayan/Nepalese", code: "himalayan"),
                BusinessFiltersRow(name: "Hong Kong Style Cafe", code: "hkcafe"),
                BusinessFiltersRow(name: "Hot Dogs", code: "hotdog"),
                BusinessFiltersRow(name: "Hot Pot", code: "hotpot"),
                BusinessFiltersRow(name: "Hungarian", code: "hungarian"),
                BusinessFiltersRow(name: "Iberian", code: "iberian"),
                BusinessFiltersRow(name: "Indian", code: "indpak"),
                BusinessFiltersRow(name: "Indonesian", code: "indonesian"),
                BusinessFiltersRow(name: "International", code: "international"),
                BusinessFiltersRow(name: "Irish", code: "irish"),
                BusinessFiltersRow(name: "Island Pub", code: "island_pub"),
                BusinessFiltersRow(name: "Israeli", code: "israeli"),
                BusinessFiltersRow(name: "Italian", code: "italian"),
                BusinessFiltersRow(name: "Japanese", code: "japanese"),
                BusinessFiltersRow(name: "Jewish", code: "jewish"),
                BusinessFiltersRow(name: "Kebab", code: "kebab"),
                BusinessFiltersRow(name: "Korean", code: "korean"),
                BusinessFiltersRow(name: "Kosher", code: "kosher"),
                BusinessFiltersRow(name: "Kurdish", code: "kurdish"),
                BusinessFiltersRow(name: "Laos", code: "laos"),
                BusinessFiltersRow(name: "Laotian", code: "laotian"),
                BusinessFiltersRow(name: "Latin American", code: "latin"),
                BusinessFiltersRow(name: "Live/Raw Food", code: "raw_food"),
                BusinessFiltersRow(name: "Lyonnais", code: "lyonnais"),
                BusinessFiltersRow(name: "Malaysian", code: "malaysian"),
                BusinessFiltersRow(name: "Meatballs", code: "meatballs"),
                BusinessFiltersRow(name: "Mediterranean", code: "mediterranean"),
                BusinessFiltersRow(name: "Mexican", code: "mexican"),
                BusinessFiltersRow(name: "Middle Eastern", code: "mideastern"),
                BusinessFiltersRow(name: "Milk Bars", code: "milkbars"),
                BusinessFiltersRow(name: "Modern Australian", code: "modern_australian"),
                BusinessFiltersRow(name: "Modern European", code: "modern_european"),
                BusinessFiltersRow(name: "Mongolian", code: "mongolian"),
                BusinessFiltersRow(name: "Moroccan", code: "moroccan"),
                BusinessFiltersRow(name: "New Zealand", code: "newzealand"),
                BusinessFiltersRow(name: "Night Food", code: "nightfood"),
                BusinessFiltersRow(name: "Norcinerie", code: "norcinerie"),
                BusinessFiltersRow(name: "Open Sandwiches", code: "opensandwiches"),
                BusinessFiltersRow(name: "Oriental", code: "oriental"),
                BusinessFiltersRow(name: "Pakistani", code: "pakistani"),
                BusinessFiltersRow(name: "Parent Cafes", code: "eltern_cafes"),
                BusinessFiltersRow(name: "Parma", code: "parma"),
                BusinessFiltersRow(name: "Persian/Iranian", code: "persian"),
                BusinessFiltersRow(name: "Peruvian", code: "peruvian"),
                BusinessFiltersRow(name: "Pita", code: "pita"),
                BusinessFiltersRow(name: "Pizza", code: "pizza"),
                BusinessFiltersRow(name: "Polish", code: "polish"),
                BusinessFiltersRow(name: "Portuguese", code: "portuguese"),
                BusinessFiltersRow(name: "Potatoes", code: "potatoes"),
                BusinessFiltersRow(name: "Poutineries", code: "poutineries"),
                BusinessFiltersRow(name: "Pub Food", code: "pubfood"),
                BusinessFiltersRow(name: "Rice", code: "riceshop"),
                BusinessFiltersRow(name: "Romanian", code: "romanian"),
                BusinessFiltersRow(name: "Rotisserie Chicken", code: "rotisserie_chicken"),
                BusinessFiltersRow(name: "Rumanian", code: "rumanian"),
                BusinessFiltersRow(name: "Russian", code: "russian"),
                BusinessFiltersRow(name: "Salad", code: "salad"),
                BusinessFiltersRow(name: "Sandwiches", code: "sandwiches"),
                BusinessFiltersRow(name: "Scandinavian", code: "scandinavian"),
                BusinessFiltersRow(name: "Scottish", code: "scottish"),
                BusinessFiltersRow(name: "Seafood", code: "seafood"),
                BusinessFiltersRow(name: "Serbo Croatian", code: "serbocroatian"),
                BusinessFiltersRow(name: "Signature Cuisine", code: "signature_cuisine"),
                BusinessFiltersRow(name: "Singaporean", code: "singaporean"),
                BusinessFiltersRow(name: "Slovakian", code: "slovakian"),
                BusinessFiltersRow(name: "Soul Food", code: "soulfood"),
                BusinessFiltersRow(name: "Soup", code: "soup"),
                BusinessFiltersRow(name: "Southern", code: "southern"),
                BusinessFiltersRow(name: "Spanish", code: "spanish"),
                BusinessFiltersRow(name: "Steakhouses", code: "steak"),
                BusinessFiltersRow(name: "Sushi Bars", code: "sushi"),
                BusinessFiltersRow(name: "Swabian", code: "swabian"),
                BusinessFiltersRow(name: "Swedish", code: "swedish"),
                BusinessFiltersRow(name: "Swiss Food", code: "swissfood"),
                BusinessFiltersRow(name: "Tabernas", code: "tabernas"),
                BusinessFiltersRow(name: "Taiwanese", code: "taiwanese"),
                BusinessFiltersRow(name: "Tapas Bars", code: "tapas"),
                BusinessFiltersRow(name: "Tapas/Small Plates", code: "tapasmallplates"),
                BusinessFiltersRow(name: "Tex-Mex", code: "tex-mex"),
                BusinessFiltersRow(name: "Thai", code: "thai"),
                BusinessFiltersRow(name: "Traditional Norwegian", code: "norwegian"),
                BusinessFiltersRow(name: "Traditional Swedish", code: "traditional_swedish"),
                BusinessFiltersRow(name: "Trattorie", code: "trattorie"),
                BusinessFiltersRow(name: "Turkish", code: "turkish"),
                BusinessFiltersRow(name: "Ukrainian", code: "ukrainian"),
                BusinessFiltersRow(name: "Uzbek", code: "uzbek"),
                BusinessFiltersRow(name: "Vegan", code: "vegan"),
                BusinessFiltersRow(name: "Vegetarian", code: "vegetarian"),
                BusinessFiltersRow(name: "Venison", code: "venison"),
                BusinessFiltersRow(name: "Vietnamese", code: "vietnamese"),
                BusinessFiltersRow(name: "Wok", code: "wok"),
                BusinessFiltersRow(name: "Wraps", code: "wraps"),
                BusinessFiltersRow(name: "Yugoslav", code: "yugoslav"),
            ])
    ]
}
