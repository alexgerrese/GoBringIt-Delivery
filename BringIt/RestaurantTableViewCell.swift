//
//  RestaurantTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/17/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets

    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var cuisineType: UILabel!
    @IBOutlet weak var openHours: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bannerImage.layer.cornerRadius = Constants.cornerRadius
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
