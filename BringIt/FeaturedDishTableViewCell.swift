//
//  FeaturedDishTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/23/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class FeaturedDishTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var myCollectionViewWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension FeaturedDishTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        myCollectionView.delegate = dataSourceDelegate
        myCollectionView.dataSource = dataSourceDelegate
        myCollectionView.tag = row
        myCollectionView.backgroundColor = UIColor.white
        myCollectionView.setContentOffset(myCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        myCollectionView.reloadData()
        myCollectionViewWidth.constant = UIScreen.main.bounds.width
    }
    
    var collectionViewOffset: CGFloat {
        set { myCollectionView.contentOffset.x = newValue }
        get { return myCollectionView.contentOffset.x }
    }
}
