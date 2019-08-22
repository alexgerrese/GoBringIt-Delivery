//
//  ThanksTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 8/17/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class ThanksTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        gotItButton.layer.cornerRadius = 17
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
