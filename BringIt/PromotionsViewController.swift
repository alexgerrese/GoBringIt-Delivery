//
//  PromotionsViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 6/18/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//
import UIKit
import RealmSwift

class PromotionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    
    // MARK: - Variables
    var passedPromotionID = ""
    var promotion = Promotion()
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        setupUI()
        
        // Setup Realm
        setupRealm()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        self.title = "Promotion"
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        promotion = realm.objects(Promotion.self).filter("id = %@", passedPromotionID).first!
        
    }
    
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 50
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // TO-DO: Make dynamic to include/exclude button?
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "promotionTitleCell", for: indexPath) as! PromotionsTitleTableViewCell
            
            cell.backgroundImage.image = UIImage(data: promotion.image! as Data)
            //        cell.title.text = promotion.
            
            return cell

        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "promotionDescriptionCell", for: indexPath)
            
            cell.textLabel?.text = promotion.details
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "promotionButtonCell", for: indexPath) as! ButtonTableViewCell
            
            cell.button.setTitle("Visit Restaurant", for: .normal) // TO-DO: Make this dynamic after testing
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Past Orders" //TO-DO: Change when dynamic
//    }
    
//    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.font = Constants.headerFont
//        header.textLabel?.textColor = UIColor.black
//        header.textLabel?.textAlignment = .left
//        header.backgroundView?.backgroundColor = UIColor.white
//        header.textLabel?.text = header.textLabel?.text?.uppercased()
//        
//    }
//    
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return Constants.headerHeight
//    }

    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension PromotionsViewController: ButtonDelegate {
    
    func buttonTapped(cell: ButtonTableViewCell) {
        
    }
}
