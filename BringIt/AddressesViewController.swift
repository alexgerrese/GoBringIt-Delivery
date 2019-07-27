//
//  AddressesViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/20/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import Moya

class AddressesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var addNewAddressButton: UIButton!
    
    // MARK: - Variables
    
    let defaults = UserDefaults.standard // Initialize UserDefaults
    
    var addresses = List<DeliveryAddress>()
    var canPickup = Bool()
    var order = Order()
    var user = User()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        setupUI()
        
        // Setup tableview
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupRealm()
        myTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRealm() {
        
        let realm = try! Realm() // Initialize Realm
        
        // Check if addresses for current User already exists in Realm
        let predicate = NSPredicate(format: "isCurrent = %@", NSNumber(booleanLiteral: true))
        user = realm.objects(User.self).filter(predicate).first!
        
        addresses = (user.addresses)
        
        if !(addresses.count > 0) {
            
            // TO-DO: Handle empty state
            
        }
    }
    
    /* Do initial UI setup */
    func setupUI() {
        
        setCustomBackButton()
        
        self.title = "Addresses"
        addNewAddressButton.layer.cornerRadius = Constants.cornerRadius
    }
    
    /* Customize tableView attributes */
    func setupTableView() {
        
        // Set tableView cells to custom height and automatically resize if needed
        self.myTableView.estimatedRowHeight = 50
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.setNeedsLayout()
        self.myTableView.layoutIfNeeded()
        
    }

    @IBAction func addNewAddressButtonTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: "toAddNewAddress", sender: self)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath)
        
        let address = addresses[indexPath.row]
        let addressString = address.streetAddress + "\n" + address.roomNumber + "\n" + "Durham, NC"
        
        cell.textLabel?.text = addressString
        
        // Change checkmark color
        cell.tintColor = Constants.green
        
        if address.isCurrent {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Default Address"
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
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let realm = try! Realm() // Initialize Realm
        
        for i in 0..<addresses.count {
            if i == indexPath.row {
                try! realm.write() {
                    
                    addresses[i].isCurrent = true
                    print("Selected \(addresses[i])")
                }
            } else {
                try! realm.write() {
                    addresses[i].isCurrent = false
                    print("Deselected \(addresses[i])")
                }
            }
        }
        
        myTableView.deselectRow(at: indexPath, animated: true)
        myTableView.reloadData()
        
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let realm = try! Realm() // Initialize Realm
        
        if editingStyle == .delete {
            
            // Delete the row from the data source
            try! realm.write {
                let address = addresses[indexPath.row]
                deleteAddress(id: address.id)
                realm.delete(address)
            }
            
            myTableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Reload tableview and adjust tableview height and recalculate costs
            myTableView.reloadData()
            updateViewConstraints()
        }
    }
    
    func deleteAddress(id: String){
        // Setup Moya provider and send network request
        let provider = MoyaProvider<CombinedAPICalls>()
        provider.request(.deleteAddress(uid: user.id, addressId: id)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    print("Status code: \(moyaResponse.statusCode)")
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let response = try moyaResponse.mapJSON() as! [String: Any]
                    print(response)
                } catch {
                    // Miscellaneous network error
                    print("Network Error")
                }
            case .failure(_):
                // Connection failed
                print("Connection failed")
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newAddressVC = segue.destination as! NewAddressVC
//        NewAddressVC.passedUserID = userID
    }

}
