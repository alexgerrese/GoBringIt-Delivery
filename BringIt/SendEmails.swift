//
//  SendEmails.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/22/17.
//  Copyright © 2017 Campus Enterprises. All rights reserved.
//

import Foundation
import SendGrid
import RealmSwift

extension CheckoutVC {
    
    func sendUserConfirmationEmail() {
        
        let realm = try! Realm() // Initialize Realm
        
        dispatch_group.enter()
        
        // Get first name
        let fullName    = user.fullName
        let firstName = fullName.components(separatedBy: " ")[0]
        
        // Get restaurant name
        let restaurantName = realm.objects(Restaurant.self).filter("id = %@", order.restaurantID).first!.name
        
        // Get order time string
        let orderTime = order.orderTime
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let orderTimeString = formatter.string(from: orderTime as! Date)
        
        // Get formatted dishes string
        var dishesString = ""
        
        for menuItem in order.menuItems {
            
            dishesString.append("\(menuItem.quantity) x \(menuItem.name) ")
            
            var otherDetails = "w/ "
            for side in menuItem.sides {
                if side.isSelected {
                    otherDetails = otherDetails + side.name + ", "
                }
            }
            for extra in menuItem.extras {
                if extra.isSelected {
                    otherDetails = otherDetails + extra.name + ", "
                }
            }
            
            if otherDetails == "w/ " {
                if menuItem.specialInstructions != "" {
                    otherDetails = " - $\(String(format: "%.2f", menuItem.totalCost)) <br>Special instructions: " + menuItem.specialInstructions
                } else {
                    otherDetails = " - $\(String(format: "%.2f", menuItem.totalCost))"
                }
                
            } else {
                let index = otherDetails.index(otherDetails.startIndex, offsetBy: otherDetails.characters.count - 2)
                otherDetails = otherDetails.substring(to: index)
                if menuItem.specialInstructions != "" {
                    otherDetails = otherDetails + " - $\(String(format: "%.2f", menuItem.totalCost)) <br>Special instructions: " + menuItem.specialInstructions
                } else {
                    otherDetails = otherDetails + " - $\(String(format: "%.2f", menuItem.totalCost))"
                }
            }
            
            dishesString.append(otherDetails + "<br>")
        }
        
        let total = calculateTotal()
        
        // Get formatted address string
        let address = order.address
        let addressString = (address?.streetAddress)! + "<br>" + (address?.roomNumber)! + "<br>" + "Durham, NC"
        
        // Send an advanced example
        let recipient = Address(user.email)
        let personalizations = Personalization(
            to: [recipient],
            cc: nil,
            bcc: nil,
            subject: "Your food is being prepared! (GoBringIt Order #\(order.id))"
        )
        let contents = Content.emailContent(
            plain: "Hi \(firstName),\n\n Your order from \(restaurantName) is being prepared!\n\nHere is your order summary:\n\nOrder #: \(order.id)\nOrder time: \(orderTimeString)\nDishes:\n\(dishesString)\nTotal: $\(String(format: "%.2f", calculateTotal()))\n\nDelivering to:\n\(addressString)\nPaying with: \(order.paymentMethod.method)\nPhone number: \(user.phoneNumber)\n\nThank you for using the GoBringIt app :) See you in 35-50 minutes!",
            html: "<p>Hi \(firstName),<br><br>Your order from \(restaurantName) is being prepared!<br><br>Here is your order summary:<br><br><b>Order #:</b> \(order.id)<br><b>Order time:</b> \(orderTimeString)<br><b>Delivery Address:</b><br>\(addressString)<br><b>Payment Method:</b> \(order.paymentMethod)<br><br><b>Order Details:</b><br>\(dishesString)<br><b>Subtotal:</b> $\(String(format: "%.2f", order.subtotal))<br><b>Delivery Fee:</b> $\(String(format: "%.2f", order.deliveryFee))<br><b>Total:</b> $\(String(format: "%.2f", total))<br><br>Thank you for using the GoBringIt app :) See you in 35-50 minutes!</p>"
        )
        let email = Email(
            personalizations: [personalizations],
            from: Address(email: "info@gobring.it", name: "GoBringIt Delivery"),
            content: contents,
            subject: nil
        )
        email.mailSettings.footer = Footer(
            text: "Copyright 2017 GoBringIt",
            html: "<p style=\"text-align:center\"><small>Copyright 2017 GoBringIt</small></p>"
        )
        
        email.trackingSettings.clickTracking = ClickTracking(section: .htmlBody)
        email.trackingSettings.openTracking = OpenTracking(location: .bottom)

        do {
            try Session.shared.send(request: email) { (response) in
                print(response?.httpUrlResponse?.statusCode)
                print("USER EMAIL SENT")
                
                self.dispatch_group.leave()
            }
        } catch {
            print(error)
            print("USER EMAIL DIDN'T WORK, RETRYING...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.sendUserConfirmationEmail()
            }
        }
    }
    
    func sendRestaurantConfirmationEmail() {
        
        let realm = try! Realm() // Initialize Realm
        
        dispatch_group.enter()
        
        // Get first name
        let fullName = user.fullName
        let firstName = fullName.components(separatedBy: " ")[0]
        
        // Get restaurant name
        let restaurantName = realm.objects(Restaurant.self).filter("id = %@", order.restaurantID).first!.name
        
        // Get order time string
        let orderTime = order.orderTime
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let orderTimeString = formatter.string(from: orderTime as! Date)
        
        // Get formatted dishes string
        var dishesString = ""
        
        for menuItem in order.menuItems {
            
            dishesString.append("\(menuItem.quantity) x \(menuItem.name) ")
            
            var otherDetails = "w/ "
            for side in menuItem.sides {
                if side.isSelected {
                    otherDetails = otherDetails + side.name + ", "
                }
            }
            for extra in menuItem.extras {
                if extra.isSelected {
                    otherDetails = otherDetails + extra.name + ", "
                }
            }
            
            if otherDetails == "w/ " {
                if menuItem.specialInstructions != "" {
                    otherDetails = " - $\(String(format: "%.2f", menuItem.totalCost)) <br>Special instructions: " + menuItem.specialInstructions
                } else {
                    otherDetails = " - $\(String(format: "%.2f", menuItem.totalCost))"
                }
                
            } else {
                let index = otherDetails.index(otherDetails.startIndex, offsetBy: otherDetails.characters.count - 2)
                otherDetails = otherDetails.substring(to: index)
                if menuItem.specialInstructions != "" {
                    otherDetails = otherDetails + " - $\(String(format: "%.2f", menuItem.totalCost)) <br>Special instructions: " + menuItem.specialInstructions
                } else {
                    otherDetails = otherDetails + " - $\(String(format: "%.2f", menuItem.totalCost))"
                }
            }
            
            dishesString.append(otherDetails + "<br>")
        }
        
        let total = calculateTotal()
        
        // Get formatted address string
        let address = order.address
        let addressString = (address?.streetAddress)! + "<br>" + (address?.roomNumber)! + "<br>" + "Durham, NC"
        
        // Set up recipients
        var recipients = [Address(restaurantEmail)]
//        if restaurantPrinterEmail != "" {
//            recipients.append(Address(restaurantPrinterEmail))
//        }
        
        print("RECIPIENTS: \(recipients)")
        
        let personalizations = Personalization(
            to: recipients,
            cc: nil,
            bcc: nil,
            subject: "New GoBringIt Order! (#\(order.id))"
        )
        let contents = Content.emailContent(
            plain: "<p>Receipt for \(restaurantName):<br><br><b>Order #:</b> \(order.id)<br><b>Order time:</b> \(orderTimeString)<br><br><b>Name:</b> \(fullName)<br><b>Phone number:</b><br>\(user.phoneNumber)<br><b>Email address:</b><br>\(user.email)<br><b>Delivery Address:</b><br>\(addressString)<br><b>Payment Method:</b> \(order.paymentMethod)<br><br><b>Order Details:</b><br>\(dishesString)<br><b>Subtotal:</b> $\(String(format: "%.2f", order.subtotal))<br><b>Delivery Fee:</b> $\(String(format: "%.2f", order.deliveryFee))<br><b>Total:</b> $\(String(format: "%.2f", total))<br><br>Thank you for using the GoBringIt app :) Don't forget to tip your driver!</p>",
            html: "<p>Receipt for \(restaurantName):<br><br><b>Order #:</b> \(order.id)<br><b>Order time:</b> \(orderTimeString)<br><br><b>Name:</b> \(fullName)<br><b>Phone number:</b><br>\(user.phoneNumber)<br><b>Email address:</b><br>\(user.email)<br><b>Delivery Address:</b><br>\(addressString)<br><b>Payment Method:</b> \(order.paymentMethod)<br><br><b>Order Details:</b><br>\(dishesString)<br><b>Subtotal:</b> $\(String(format: "%.2f", order.subtotal))<br><b>Delivery Fee:</b> $\(String(format: "%.2f", order.deliveryFee))<br><b>Total:</b> $\(String(format: "%.2f", total))<br><br>Thank you for using the GoBringIt app :) Don't forget to tip your driver!</p>"
        )
        let email = Email(
            personalizations: [personalizations],
            from: Address(email: "info@gobring.it", name: "GoBringIt Delivery"),
            content: contents,
            subject: nil
        )
        email.mailSettings.footer = Footer(
            text: "Copyright 2017 GoBringIt",
            html: "<p style=\"text-align:center\"><small>Copyright 2017 GoBringIt</small></p>"
        )
        
        do {
            try Session.shared.send(request: email) { (response) in
                print(response?.httpUrlResponse?.statusCode)
                print("RESTAURANT EMAIL SENT")
                
                self.dispatch_group.leave()
            }
        } catch {
            print(error)
            print("RESTAURANT EMAIL DIDN'T WORK, RETRYING...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.sendRestaurantConfirmationEmail()
            }
        }
    }
}
