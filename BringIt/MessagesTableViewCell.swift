//
//  MessagesTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/17/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var message: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
