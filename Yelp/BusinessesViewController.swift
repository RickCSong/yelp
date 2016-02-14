//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, BusinessFiltersDelegate {
    @IBOutlet weak var businessesTableView: UITableView!
    
    var businessSearchBar: UISearchBar!
    var businessFilters = BusinessFilters()
    
    var businesses: [Business]!
    
    // Initialization Methods
    // ============================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the table view
        self.businessesTableView.allowsSelection = false
        self.businessesTableView.dataSource = self
        self.businessesTableView.delegate = self
        self.businessesTableView.estimatedRowHeight = 300
        self.businessesTableView.rowHeight = UITableViewAutomaticDimension
        
        // Initialize the UISearchBar
        self.businessSearchBar = UISearchBar()
        self.businessSearchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        self.businessSearchBar.sizeToFit()
        navigationItem.titleView = self.businessSearchBar
        
        // Perform an initial search
        searchBusinesses()
    }
    
    // Table View Delegate Methods
    // ============================
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let businessTableViewCell = tableView.dequeueReusableCellWithIdentifier("com.ricksong.BusinessTableViewCell", forIndexPath: indexPath) as! BusinessTableViewCell
        let business = self.businesses[indexPath.row]
        
        if let imageURL = business.imageURL {
            businessTableViewCell.businessImage.setImageWithURL(imageURL)
        }
        if let ratingImageURL = business.ratingImageURL {
            businessTableViewCell.ratingImage.setImageWithURL(ratingImageURL)
        }
        businessTableViewCell.nameLabel.text = business.name!
        businessTableViewCell.distanceLabel.text = business.distance!
        businessTableViewCell.reviewCountLabel.text = "\(business.reviewCount!) Reviews"
        businessTableViewCell.addressLabel.text = business.address!
        businessTableViewCell.categoriesLabel.text = business.categories!
        
        return businessTableViewCell
    }
    
    // Search Bar Delegate Methods
    // ============================
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.businessFilters.term = searchBar.text!
        searchBar.resignFirstResponder()
        searchBusinesses()
    }

    // BusinessFiltersDelegate Methods
    // ============================
    func initialBusinessFilters() -> BusinessFilters? {
        return self.businessFilters
    }
    
    func updateBusinessFilters(settings: BusinessFiltersViewController, didSaveBusinessFilters businessFilters:BusinessFilters) {
        self.businessFilters = businessFilters
        searchBusinesses()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Core Methods
    // ============================
    func searchBusinesses() {
        Business.searchWithTerm(self.businessFilters.term!,
            distance: self.businessFilters.distance,
            sort: self.businessFilters.sort,
            categories: Array(self.businessFilters.categories),
            deals: self.businessFilters.deals) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.businessesTableView.reloadData()
        }
    }
    
    // Transition Methods
    // ============================
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {        
        let navigationController = segue.destinationViewController as! UINavigationController
        let businessFiltersViewController = navigationController.topViewController as! BusinessFiltersViewController
        
        businessFiltersViewController.delegate = self
    }
}
