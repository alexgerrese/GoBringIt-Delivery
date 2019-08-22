//
//  PastOrderTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class PastOrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var orderDetails: UILabel!
    @IBOutlet weak var dateView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
