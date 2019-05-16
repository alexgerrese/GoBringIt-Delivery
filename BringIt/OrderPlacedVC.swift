//
//  OrderPlacedVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/21/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit

class OrderPlacedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - Variables
    
    var totalSpent = 0.0
    var ETA = ""
    var streetAddress = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        setupUI()
        
        // Setup tableview
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    
    /* Do initial UI setup */
    func setupUI() {
        
        // Add haptic feedback
        if #available(iOS 10.0, *) {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
        }

        doneButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    /* Customize tableView attributes */
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 50
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
        
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderPlacedCell", for: indexPath)
        
        if indexPath.row == 0 {
            
            cell.textLabel?.text = "Order Total"
            cell.detailTextLabel?.text = "$" + String(format: "%.2f", totalSpent)
            
        } else if indexPath.row == 1 {
            
            cell.textLabel?.text = "ETA"
            cell.detailTextLabel?.text = ETA
            
            
        } else {
            
            cell.textLabel?.text = "Delivering To"
            cell.detailTextLabel?.text = streetAddress
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Order Summary"
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.textAlignment = .left
        header.backgroundView?.backgroundColor = Constants.green
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
