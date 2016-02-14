//
//  BusinessFilterCellDelegate.swift
//  Yelp
//
//  Created by Rick Song on 2/13/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol BusinessFilterCellDelegate: class {
    func businessFilterCellDidToggle(cell: BusinessFilterTableViewCell, newValue:Bool)
}

class BusinessFilterTableViewCell: UITableViewCell {
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!

    weak var delegate: BusinessFilterCellDelegate?
    var identifier : BusinessFiltersSectionIdentifier?
    var code : Any?

    @IBAction func didToggleFilterSwitch(sender: AnyObject) {
        delegate?.businessFilterCellDidToggle(self, newValue: filterSwitch.on)
    }
}
