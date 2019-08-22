//
//  OrderTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/20/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var menuItemName: UILabel!
    @IBOutlet weak var otherDetails: UILabel!
    @IBOutlet weak var price: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
