//
//  SpecialInstructionsTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/19/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class SpecialInstructionsTableViewCell: UITableViewCell {

    @IBOutlet weak var textFieldBackgroundView: UIView!
    @IBOutlet weak var specialInstructions: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textFieldBackgroundView.layer.cornerRadius = Constants.cornerRadius
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
