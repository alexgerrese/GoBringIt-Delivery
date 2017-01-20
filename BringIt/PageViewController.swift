//
//  PageViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/14/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    // Hard-coded walkthrough data
    let pageImages = ["WT 1", "WT 2", "WT 3"]
    let pageDescriptions = ["Order delicious food from your dorm on food points with BringIt.", "Schedule a clean of your dorm or apartment with Maid My Day.", "Meet Campus Enterprises, Duke University’s on-demand economy."]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set data source to be self
        self.dataSource = self
        
        // Create first walkthrough view
        if let startWalkthroughVC = self.viewControllerAtIndex(0) {
            setViewControllers([startWalkthroughVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigate
    
    func nextPageWithIndex(_ index: Int)
    {
        if let nextWalkthroughVC = self.viewControllerAtIndex(index+1) {
            setViewControllers([nextWalkthroughVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func viewControllerAtIndex(_ index: Int) -> WalkthroughViewController?
    {
        if index == NSNotFound || index < 0 || index >= self.pageDescriptions.count {
            return nil
        }
        
        // create a new walkthrough view controller and assing appropriate date
        if let walkthroughViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController {
            walkthroughViewController.imageName = pageImages[index]
            walkthroughViewController.descriptionText = pageDescriptions[index]
            walkthroughViewController.index = index
            
            return walkthroughViewController
        }
        
        return nil
    }
}

// Create extension
extension PageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughViewController).index
        index -= 1
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughViewController).index
        index += 1
        
        return self.viewControllerAtIndex(index)
    }
}
