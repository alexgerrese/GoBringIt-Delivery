//
//  MenuImageTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/12/18.
//  Copyright © 2018 Campus Enterprises. All rights reserved.
//

import UIKit

class MenuImageTableViewCell: UITableViewCell {

    @IBOutlet weak var menuItemImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
