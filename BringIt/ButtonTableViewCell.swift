//
//  ButtonTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 6/19/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit


protocol ButtonDelegate: class {
    func buttonTapped(cell: ButtonTableViewCell)
}

class ButtonTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var button: UIButton!
    
    // MARK: - Variables
    
    var delegate: ButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(cell: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
