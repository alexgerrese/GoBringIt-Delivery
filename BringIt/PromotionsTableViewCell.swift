//
//  PromotionsTableViewCell.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/17/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class PromotionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension PromotionsTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        myCollectionView.delegate = dataSourceDelegate
        myCollectionView.dataSource = dataSourceDelegate
        myCollectionView.tag = row
        myCollectionView.setContentOffset(myCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        myCollectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { myCollectionView.contentOffset.x = newValue }
        get { return myCollectionView.contentOffset.x }
    }
    
//    func scrollToNearestVisibleCollectionViewCell() {
//        let visibleCenterPositionOfScrollView = Float(myCollectionView.contentOffset.x + (self.myCollectionView!.bounds.size.width / 2))
//        var closestCellIndex = -1
//        var closestDistance: Float = .greatestFiniteMagnitude
//        for i in 0..<myCollectionView.visibleCells.count {
//            let cell = myCollectionView.visibleCells[i]
//            let cellWidth = cell.bounds.size.width
//            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
//            
//            // Now calculate closest cell
//            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
//            if distance < closestDistance {
//                closestDistance = distance
//                closestCellIndex = myCollectionView.indexPath(for: cell)!.row
//            }
//        }
//        if closestCellIndex != -1 {
//            self.myCollectionView.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .centeredHorizontally, animated: true)
//        }
//    }
    
}
