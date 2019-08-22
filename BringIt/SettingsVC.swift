//
//  SettingsVC.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/25/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift

struct SettingsSection {
    var title = ""
    var cells = [String]()
}

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    var sections = [SettingsSection]()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        setupUI()
        
        // Setup Realm
        setupRealm()
        
        // Setup tableview
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Setup cells
        setupCells()
        myTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        // Set title
        self.title = "Settings"
        
        setCustomBackButton()
        
    }
    
    func setupCells() {
        
        sections.removeAll()
        
        if checkIfLoggedIn() {
            
            sections.append(SettingsSection(title: "About You", cells: ["Account Info", "Addresses", "Payment Methods"]))
            
            sections.append(SettingsSection(title: "About Us", cells: ["Campus Enterprises", "Contact Us"]))
            
            sections.append(SettingsSection(title: "Become a Driver", cells: ["Become a Driver"]))
            
            sections.append(SettingsSection(title: "SignIn-SignOut", cells: ["Sign Out"]))
        } else {
            
            sections.append(SettingsSection(title: "About Us", cells: ["Campus Enterprises", "Contact Us"]))
            
            sections.append(SettingsSection(title: "Become a Driver", cells: ["Become a Driver"]))
            
            sections.append(SettingsSection(title: "SignIn-SignOut", cells: ["Sign In"]))
        }
        
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        if checkIfLoggedIn() {
            
            let filteredUsers = realm.objects(User.self).filter("isCurrent = %@", NSNumber(booleanLiteral: true))
            if let firstUser = filteredUsers.first {
                user = firstUser
            } else {
                signOutUser()
            }
        }
    }
    
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 45
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
    }
    
    func checkIfLoggedIn() -> Bool {
        
        print("Checking if logged in")
        
        // If not logged in, go to SignInVC
        let loggedIn = defaults.bool(forKey: "loggedIn")
        if loggedIn {
            
            return true
        }
        
        return false
    }
    
    func signOutUser() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Update UserDefaults' "loggedIn" property to false
        self.defaults.set(false, forKey: "loggedIn")
        
        // Set current Realm user's active property to false
        try! realm.write {
            user.isCurrent = false
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = sections[indexPath.section].cells[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections[section].title == "SignIn-SignOut" || sections[section].title == "Become a Driver" {
            return ""
        }
        return sections[section].title
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = Constants.headerFont
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.textAlignment = .left
        header.backgroundView?.backgroundColor = UIColor.white
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if sections[section].title == "SignIn-SignOut" || sections[section].title == "Become a Driver" {
            return CGFloat.leastNormalMagnitude
        }
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        myTableView.deselectRow(at: indexPath, animated: true)
        
        let section = sections[indexPath.section]
        let cellName = section.cells[indexPath.row]
        
        if section.title == "About You" {
            if cellName == "Account Info" {
                performSegue(withIdentifier: "toUpdateAccountInfo", sender: self)
            } else if cellName == "Addresses" {
                performSegue(withIdentifier: "toAddressesFromSettings", sender: self)
            } else if cellName == "Payment Methods" {
                performSegue(withIdentifier: "toPaymentMethodsFromSettings", sender: self)
            }
        } else if section.title == "About Us" {
            if cellName == "Campus Enterprises" {
                if let url = URL(string: "https://www.campusenterprises.org") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:])
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            } else if cellName == "Contact Us" {
                if let url = URL(string: "https://www.campusenterprises.org/contactus") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:])
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            
        } else {
            if cellName == "Sign In" {
                performSegue(withIdentifier: "toSignInFromSettings", sender: self)
            } else if cellName == "Sign Out" {
                
                // TO-DO: Add modal alert for user to confirm sign out
                
                signOutUser()
                performSegue(withIdentifier: "toSignInFromSettings", sender: self)
            } else if cellName == "Become a Driver" {
                performSegue(withIdentifier: "toBecomeADriver", sender: self)
            }
        }
        
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
