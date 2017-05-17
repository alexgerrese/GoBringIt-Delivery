//
//  SettingsTableViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/24/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var briefingTextLabel: UILabel!
    
    // MARK: - Variables
    
    // Tableview cells
    var infoCells = ["Contact Info", "Addresses", "Payment Methods", "Coming Soon"]
    let contactIndex = 0
    let addressIndex = 1
    let paymentIndex = 2
    let comingSoonIndex = 3
    //let helpCells = ["Coming Soon"]
    var cellNumbers = [0,0,0,0]
    var selectedCell = 0
    var userName = ""
    var userID = ""
    
    // UserDefaults
    let defaults = UserDefaults.standard
    
    // CoreData
//    let appDelegate =
//        UIApplication.shared.delegate as! AppDelegate
//    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.navigationItem.title = "Profile"
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
//        navigationController!.navigationBar.titleTextAttributes =
//            ([NSFontAttributeName: TITLE_FONT,
//                NSForegroundColorAttributeName: UIColor.black])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Check if user is already logged in
        checkLoggedIn()
        
        if let id = defaults.object(forKey: "userID") {
            userID = id  as! String
        } else {
            self.tabBarController?.selectedIndex = 0
        }
        
        // Get and display user's name
        if let name = defaults.object(forKey: "userName") {
            userName = name as! String
            // Set name
            nameLabel.text = userName
        } else {
            
            // Make call to accounts DB
            // Check if uid == userID
            // Pull name, email, phone
            let requestURL1: URL = URL(string: "http://www.gobringit.com/CHADservice.php")!
            let urlRequest1 = URLRequest(url: requestURL1)
            let session1 = URLSession.shared
            let task1 = session1.dataTask(with: urlRequest1, completionHandler: {
                (data, response, error) -> Void in
                
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                // Check HTTP Response
                if (statusCode == 200) {
                    
                    do{
                        // Parse JSON
                        let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                        
                        for User in json as! [Dictionary<String, AnyObject>] {
                            let user_id = User["uid"] as! String
                            if (user_id == self.userID) {
                                let fullname = User["name"] as! String
                                self.userName = fullname
                                // Save to userDefaults
                                self.defaults.set(fullname, forKey: "userName")
                            }
                            //  NSOperationQueue.mainQueue().addOperationWithBlock
                        }
                        
                        // Set name
                        self.nameLabel.text = self.userName
                        
                    } catch {
                        print("Error with Json: \(error)")
                    }
                }
            }) 
            task1.resume()
            
        }
        
        // Deselect cells when view appears
        if let indexPath = myTableView.indexPathForSelectedRow {
            myTableView.deselectRow(at: indexPath, animated: true)
        }
        
        // Get correct count for addresses
        if let addressesArray = defaults.object(forKey: "Addresses") {
            cellNumbers[addressIndex] = (addressesArray as AnyObject).count
            myTableView.reloadData()
        }
        
        // Fetch all inactive carts, if any exist
        
//        let fetchRequest = NSFetchRequest<Order>(entityName: "Order")
//        let sortDescriptor = NSSortDescriptor(key: "dateOrdered", ascending: false)
//        let firstPredicate = NSPredicate(format: "isActive == %@", false as CVarArg)
//        fetchRequest.predicate = firstPredicate
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        var totalCost = 0.0
//        var numOrders = 0
//        var avgOrderCost = 0.0
//        
//        do {
//            if let fetchResults = try managedContext.fetch(fetchRequest) as? [Order] {
//                
//                for i in fetchResults {
//                    totalCost += Double(i.totalPrice!)
//                    numOrders += 1
//                }
//                print(fetchResults.count)
//            }
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
//        
//        avgOrderCost = totalCost / Double(numOrders)
//        
//        if numOrders == 0 {
//            briefingTextLabel.text = "Come back here after you've made some orders to see some stats!"
//        } else {
//            briefingTextLabel.text = "You have spent \(String(format: "$%.2f", totalCost)) on \(numOrders) orders, for an average of \(String(format: "$%.2f", avgOrderCost)) per order."
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Resize itemsTableView
    override func updateViewConstraints() {
        super.updateViewConstraints()
        myTableViewHeight.constant = myTableView.contentSize.height
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        if (indexPath as NSIndexPath).section == 0 {
            cell.textLabel?.text = infoCells[(indexPath as NSIndexPath).row]
            if cellNumbers[(indexPath as NSIndexPath).row] == 0 {
                cell.detailTextLabel?.text = ""
            } else {
                cell.detailTextLabel?.text = String(cellNumbers[(indexPath as NSIndexPath).row])
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            performSegue(withIdentifier: "toContactInfo", sender: self)
        } else if (indexPath as NSIndexPath).row == 1 {
            performSegue(withIdentifier: "toDeliverToPayingWithFromProfile", sender: self)
        } else if (indexPath as NSIndexPath).row == 2 {
            performSegue(withIdentifier: "toPaymentMethods", sender: self)
        } else {
            performSegue(withIdentifier: "toComingSoon", sender: self)
        }
    }
    
    @IBAction func logOutButtonClicked(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        let signOut = UIAlertAction(title: "Yes, sign me out", style: .default, handler: { (action) -> Void in
            print("SignOut Button Pressed")
            
            // RESET SENSITIVE INFO
            self.defaults.set(false, forKey: "loggedIn")
            self.defaults.set(nil, forKey: "userID")
            self.defaults.set("", forKey: "stripeCustomerID")
            
            self.checkLoggedIn()
        })
        let cancel = UIAlertAction(title: "No, cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel Button Pressed")
        })
        
        alertController.addAction(signOut)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func returnToSettings(_ segue: UIStoryboardSegue) {
    }
    
    // Check if user is already logged in. If not, present SignInViewController.
    func checkLoggedIn() {
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if !loggedIn {
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as! SignInViewController
//            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - Compose Email Methods
    
    @IBAction func sendEmailButtonTapped(_ sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["info@campusenterprises.org"])
        mailComposerVC.setSubject("BringIt Contact Form")
        mailComposerVC.setMessageBody("[Write your email here and we'll get back to  you ASAP!]", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDeliverToPayingWithFromProfile" {
            let VC = segue.destinationViewController as! DeliverToPayingWithViewController
            if self.selectedCell == 1 {
                VC.selectedCell = "Deliver To"
            } else if self.selectedCell == 2 {
                VC.selectedCell = "Paying With"
            }
        }
    }*/
    
    
}
