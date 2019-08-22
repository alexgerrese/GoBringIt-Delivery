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
        
        _ = try! Realm() // Initialize Realm
        
        dispatch_group.enter()
        
        // Get first name
        let fullName    = user.fullName
        let firstName = fullName.components(separatedBy: " ")[0]
        
        // Get restaurant name
        let restaurantName = restaurant.name
        
        // Travel time message
        if order.isDelivery {
            if travelTimeMessage == "" {
                travelTimeMessage = "Your order will arrive in 35-50 mins."
            }
        } else {
            travelTimeMessage = ""
        }
        
        // Get order time string
        let orderTime = order.orderTime
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let orderTimeString = formatter.string(from: orderTime! as Date)
        
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
                let index = otherDetails.index(otherDetails.startIndex, offsetBy: otherDetails.count - 2)
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
        let address = order.address!
        var addressString = ""
        if order.isDelivery {
            addressString = "<br><b>Delivery Address:</b><br>\(address.streetAddress)<br>\(address.roomNumber)<br>Durham, NC"
        } else {
            addressString = "<br><b>Pickup Address:</b><br>\(restaurant.address)"
        }
        
        // Get formatted payment method string
        var paymentMethodString = ""
        if order.isDelivery {
            paymentMethodString = "<br><b>Payment Method:</b> \(order.paymentMethod?.paymentString)"
            if order.paymentMethod?.paymentMethodID == 2 {
                paymentMethodString.append(" - Paid")
            }
        }
        
        // Get formatted delivery fee string
        var deliveryFeeString = ""
        if order.isDelivery {
            deliveryFeeString = "<br><b>Delivery Fee:</b> $\(String(format: "%.2f", order.deliveryFee))"
        }
        
        // Email to the user
        let recipient = Address(email: user.email)
        let personalizations = Personalization(
            to: [recipient],
            cc: nil,
            bcc: nil,
            subject: "Your food is being prepared! (Order #\(order.id))"
        )
        let contents = Content.emailBody(
            plain: "<p>Hi \(firstName),<br><br>Your order from \(restaurantName) is being prepared! \(travelTimeMessage)<br><br>Here is your order summary:<br><br><b>Order #:</b> \(order.id)<br><b>Order time:</b> \(orderTimeString)\(addressString)\(paymentMethodString)<br><br><b>Order Details:</b><br>\(dishesString)<br><b>Subtotal:</b> $\(String(format: "%.2f", order.subtotal))\(deliveryFeeString)<br><b>Total:</b> $\(String(format: "%.2f", total))<br><br>Thank you for using the GoBringIt app :)</p>",
            html: "<p>Hi \(firstName),<br><br>Your order from \(restaurantName) is being prepared! \(travelTimeMessage)<br><br>Here is your order summary:<br><br><b>Order #:</b> \(order.id)<br><b>Order time:</b> \(orderTimeString)\(addressString)\(paymentMethodString)<br><br><b>Order Details:</b><br>\(dishesString)<br><b>Subtotal:</b> $\(String(format: "%.2f", order.subtotal))\(deliveryFeeString)<br><b>Total:</b> $\(String(format: "%.2f", total))<br><br>Thank you for using the GoBringIt app :)</p>"
        )
        let email = Email(
            personalizations: [personalizations],
            from: Address(email: "info@gobring.it", name: "GoBringIt Delivery"),
            content: contents,
            subject: nil
        )
        email.mailSettings.footer = Footer(
            text: "Copyright 2019 © GoBringIt",
            html: "<p style=\"text-align:center\"><small>Copyright 2019 © GoBringIt</small></p>"
        )
        
        email.parameters?.trackingSettings.clickTracking = ClickTracking(section: .htmlBody)
        email.parameters?.trackingSettings.openTracking = OpenTracking(location: .bottom)

//        do {
//            try Session.shared.send(request: email) { (response) in
//                print(response.httpUrlResponse?.statusCode as Any)
//                print("USER EMAIL SENT")
//
//                self.dispatch_group.leave()
//            }
//        } catch {
//            print(error)
//            print("USER EMAIL DIDN'T WORK, RETRYING...")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.sendUserConfirmationEmail()
//            }
//        }
    }
    
    func sendRestaurantConfirmationEmail() {
        
        let realm = try! Realm() // Initialize Realm
        
        dispatch_group.enter()
        
        // Get full name
        let fullName = user.fullName
        
        // Get restaurant name
        let restaurantName = restaurant.name
        
        // Get order time string
        let orderTime = order.orderTime
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let orderTimeString = formatter.string(from: orderTime! as Date)
        
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
                let index = otherDetails.index(otherDetails.startIndex, offsetBy: otherDetails.count - 2)
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
        var addressString = ""
        if order.address?.streetAddress != "" {
            addressString = "<br><b>Delivery Address:</b><br>\(address?.streetAddress ?? "")<br>\(address?.roomNumber ?? "")<br>Durham, NC"
        } else {
            addressString = "<br><b>Pickup order"
        }
        
        // Get formatted payment method string
        var paymentMethodString = ""
        if order.isDelivery {
            paymentMethodString = "<br><b>Payment Method:</b> \(order.paymentMethod?.paymentString ?? "")"
            if order.paymentMethod?.paymentMethodID == 2 {
                paymentMethodString.append(" - Paid")
            }
        }
        
        // Get formatted delivery fee string
        var deliveryFeeString = ""
        if order.isDelivery {
            deliveryFeeString = "<br><b>Delivery Fee:</b> $\(String(format: "%.2f", order.deliveryFee))"
        }
        
        // Set up recipients
        var recipients = [Address]()
        let emails = restaurant.email.components(separatedBy: ",")
        for email in emails {
            recipients.append(Address(email: email))
        }
        
        //        let recipients = [Address(email: restaurantEmail)]
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
        let contents = Content.emailBody(
            plain: "<p>Receipt for \(restaurantName):<br><br><b>Order #:</b> \(order.id)<br><b>Order time:</b> \(orderTimeString)<br><br><b>Name:</b> \(fullName)<br><b>Phone number:</b><br>\(user.phoneNumber.toPhoneNumber())<br><b>Email address:</b><br>\(user.email)\(addressString)\(paymentMethodString)<br><br><b>Order Details:</b><br>\(dishesString)<br><b>Subtotal:</b> $\(String(format: "%.2f", order.subtotal))\(deliveryFeeString)<br><b>Total:</b> $\(String(format: "%.2f", total))<br><br>Thank you for using the GoBringIt app :) Don't forget to tip your driver!</p>",
            html: "<p>Receipt for \(restaurantName):<br><br><b>Order #:</b> \(order.id)<br><b>Order time:</b> \(orderTimeString)<br><br><b>Name:</b> \(fullName)<br><b>Phone number:</b><br>\(user.phoneNumber.toPhoneNumber())<br><b>Email address:</b><br>\(user.email)\(addressString)<br><b>Payment Method:</b> \(order.paymentMethod?.paymentString ?? "Not found")<br><br><b>Order Details:</b><br>\(dishesString)<br><b>Subtotal:</b> $\(String(format: "%.2f", order.subtotal))\(deliveryFeeString)<br><b>Total:</b> $\(String(format: "%.2f", total))<br><br>Thank you for using the GoBringIt app :) Don't forget to tip your driver!</p>"
        )
        let email = Email(
            personalizations: [personalizations],
            from: Address(email: "info@gobring.it", name: "GoBringIt Delivery"),
            content: contents,
            subject: nil
        )
        email.mailSettings.footer = Footer(
            text: "Copyright 2019 © GoBringIt",
            html: "<p style=\"text-align:center\"><small>Copyright 2019 © GoBringIt</small></p>"
        )
        
//        do {
//            try Session.shared.send(request: email) { (response) in
//                print(response.httpUrlResponse?.statusCode)
//                print("RESTAURANT EMAIL SENT")
//
//                self.dispatch_group.leave()
//            }
//        } catch {
//            print(error)
//            print("RESTAURANT EMAIL DIDN'T WORK, RETRYING...")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.sendRestaurantConfirmationEmail()
//            }
//        }
    }
}
