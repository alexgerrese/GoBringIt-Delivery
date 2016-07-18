//
//  AddToOrderTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/26/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import DLRadioButton

class AddToOrderTableViewCell: UITableViewCell {

    //@IBOutlet weak var radioButton: DLRadioButton!
    @IBOutlet weak var sideLabel: UILabel!
    @IBOutlet weak var extraCostLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
