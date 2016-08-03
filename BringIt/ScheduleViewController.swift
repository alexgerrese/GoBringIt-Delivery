//
//  ScheduleViewController.swift
//  BringIt
//
//  Created by Alexander's MacBook on 5/13/16.
//  Copyright © 2016 Campus Enterprises. All rights reserved.
//

import UIKit
import CVCalendar
import CoreData

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ScheduleEntry data structure
    struct ScheduleEntry {
        var date: NSDate
        var serviceType: String
        var timeLabel: String
        var descriptionLabel: String
        var priceLabel: String
    }
    
    struct Header {
        var month: String
        var numOccurences: Int
    }
    
    //var entries = [ScheduleEntry(date: NSDate(), serviceType: "Food Delivery", timeLabel: "10:45PM", descriptionLabel: "Sushi Love", priceLabel: "42.59"), ScheduleEntry(date: NSDate(), serviceType: "Room/Apt Clean", timeLabel: "3:15PM", descriptionLabel: "Deluxe", priceLabel: "60.00"), ScheduleEntry(date: NSDate(), serviceType: "Food Delivery", timeLabel: "9:30AM", descriptionLabel: "Dunkin' Donuts", priceLabel: "12.67")]
    var entries: [Order]?

    // MARK: - IBOutlets
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var monthAndYearLabel: UILabel!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var scrollViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var myViewHeight: NSLayoutConstraint!
    @IBOutlet weak var switchViewsButton: UISegmentedControl!
    
    var selectedDay: DayView!
    var selectedDate: String?
    var selectedIndexPath: Int?
    
    // CoreData
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.navigationItem.title = "Order History"
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGrayColor()
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.blackColor()])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Set label to current month
        monthAndYearLabel.text = CVDate(date: NSDate()).globalDescription
        menuView.dayOfWeekTextColor = UIColor.whiteColor()
        
        // TO-DO: CHAD! 
            // 1. Please load all previous orders by this user from the db and put them in an array in the ScheduleEntry struct format above. Please sort them by date, with the most recent on top.
            // 2. This array will need to be separated into sections by month, with the header of each section being the name of the month and the number of entries for that month (for example, "JUNE (3)"). Please let me know if you need help with this because it is confusing.
            // 3. We need to mark on the calendar which dates have a ScheduleEntry item. If you can give me the dates of each entry formatted as an NSDate, I can mark them on the calendar with a little dot.
        // Insert code hereeeeeeee
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Deselect cells when view appears
        if let indexPath = myTableView.indexPathForSelectedRow {
            myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        // Fetch all inactive carts, if any exist
        
        let fetchRequest = NSFetchRequest(entityName: "Order")
        let sortDescriptor = NSSortDescriptor(key: "dateOrdered", ascending: false)
        let firstPredicate = NSPredicate(format: "isActive == %@", false)
        fetchRequest.predicate = firstPredicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [Order] {
                entries = fetchResults
                print(fetchResults.count)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        myTableView.reloadData()
    }
    
    // Set up Calendar View
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // TO-DO: Alex! When we have calculated the headers situations (how many months have orders), make this dynamic
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TO-DO: Alex! When we have calculated the headers situations (how many months have orders), make this dynamic
        return entries!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("scheduleCell", forIndexPath: indexPath) as! ScheduleTableViewCell
        
        // Get date components for sorting
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Day, fromDate: entries![indexPath.row].dateOrdered!)
        let monthFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MMM"
        let month = monthFormatter.stringFromDate(entries![indexPath.row].dateOrdered!)
        cell.monthLabel.text = month
        cell.dayLabel.text = String(components.day)
        
        /* Display service type
        if entries![indexPath.row].restaurant != nil {
            cell.serviceTypeLabel.text = "Food Delivery"
        } else {
            cell.serviceTypeLabel.text = "Maid My Day"
        }*/

        // Calculate time
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "H:mm"
        let time = timeFormatter.stringFromDate(entries![indexPath.row].dateOrdered!)
        cell.timeLabel.text = time
        
        // Display description
        cell.descriptionLabel.text = entries![indexPath.row].restaurant
        
        // Display price
        let price = entries![indexPath.row].totalPrice! as Double
        cell.priceLabel.text = String(format: "$%.2f", price) // BUG: WHY IS THIS NOT WORKINGGGGG?
        print(String(format: "%.2f", entries![indexPath.row].totalPrice!))
        
        return cell
    }

    @IBAction func switchViewsButtonClicked(sender: AnyObject) {
        if switchViewsButton.selectedSegmentIndex == 0 {
            scrollViewToTopConstraint.constant = 397 // TO-DO: ALEX! CHANGE THIS, SHOULDN'T BE CONSTANT!!!
            UIView.animateWithDuration(0.4) {
                self.view.layoutIfNeeded()
            }
        } else {
            scrollViewToTopConstraint.constant = 64
            UIView.animateWithDuration(0.4) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Set up custom header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        header.textLabel!.textColor = UIColor.darkGrayColor()
        header.textLabel?.font = TV_HEADER_FONT
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // TO-DO: ALEX! When we have calculated the headers situations (how many months have orders), make this dynamic
        
        return ""
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
         selectedIndexPath = indexPath.row
        
        // Get date components
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        selectedDate = dateFormatter.stringFromDate(entries![indexPath.row].dateOrdered!)
        
        return indexPath
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Send the selected orderID to the next viewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toScheduleDetail" {
            let VC = segue.destinationViewController as! ScheduleDetailViewController
            VC.order = entries![selectedIndexPath!]
            VC.date = selectedDate!
        }
    }
}

// Required CVCalendar delegates
extension ScheduleViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
    // MARK: - Calendar Appearance
    
    func dayOfWeekTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func dayLabelWeekdayOutTextColor() -> UIColor {
        return UIColor.grayColor()
    }
    
    func dayLabelWeekdayHighlightedTextColor() -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    func dayLabelPresentWeekdayHighlightedBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func presentedDateUpdated(date: Date) {
        monthAndYearLabel.text = date.globalDescription
        myView.sizeToFit()
    }
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedDay = dayView
    }
    
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        //        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
}

