
//
//  BannerTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

protocol BannerCellDelegate: class {
    func cancelButtonTapped(cell: BannerTableViewCell)
}

class BannerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var cuisineAndHours: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: BannerCellDelegate?
    
    @IBAction func canelButtonTapped(_ sender: UIButton) {
        delegate?.cancelButtonTapped(cell: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
