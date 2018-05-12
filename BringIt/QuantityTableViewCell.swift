//
//  QuantityTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/19/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

protocol QuantityCellDelegate: class {
    func minusButtonTapped(cell: QuantityTableViewCell)
    func plusButtonTapped(cell: QuantityTableViewCell)
}

class QuantityTableViewCell: UITableViewCell {

    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var value: UILabel!   
    
    var delegate: QuantityCellDelegate?
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        delegate?.minusButtonTapped(cell: self)
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        delegate?.plusButtonTapped(cell: self)
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
