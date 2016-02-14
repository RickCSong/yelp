//
//  BusinessFilterSettings.swift
//  Yelp
//
//  Created by Rick Song on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

class BusinessFilters {
    struct Defaults {
        static let term : String = ""
        static let sort : YelpSortMode = YelpSortMode.BestMatched
        static let distance : Float = 0
        static let categories : Set<String> = []
        static let deals : Bool = false
    }
    
    var term: String!
    var sort: YelpSortMode!
    var distance: Float!
    var categories: Set<String>!
    var deals: Bool!
    
    init(term: String = "", sort: YelpSortMode = Defaults.sort, distance: Float = Defaults.distance, categories: Set<String> = Defaults.categories, deals: Bool = Defaults.deals) {
        self.term = term
        self.sort = sort
        self.distance = distance
        self.categories = categories
        self.deals = deals
    }
}
