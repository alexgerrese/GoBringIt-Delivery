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

// FUTURE TO-DO: CHAD! Load past carts from web and update CoreData.

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ScheduleEntry data structure
    struct ScheduleEntry {
        var date: Foundation.Date
        var serviceType: String
        var timeLabel: String
        var descriptionLabel: String
        var priceLabel: String
    }
    
    struct Header {
        var month: String
        var numOccurences: Int
    }
    
    var entries: [Order]?

    // MARK: - IBOutlets
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var monthAndYearLabel: UILabel!
    //@IBOutlet weak var myView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    //@IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var tableViewToTopConstraint: NSLayoutConstraint!
    //@IBOutlet weak var myViewHeight: NSLayoutConstraint!
    @IBOutlet weak var switchViewsButton: UISegmentedControl!
    @IBOutlet weak var noOrdersIcon: UIImageView!
    
    var selectedDay: DayView!
    var selectedDate: String?
    var selectedIndexPath: Int?
    
    // CoreData
    let appDelegate =
        UIApplication.shared.delegate as! AppDelegate
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        self.navigationItem.title = "Order History"
        
        // Set nav bar preferences
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController!.navigationBar.titleTextAttributes =
            ([NSFontAttributeName: TITLE_FONT,
                NSForegroundColorAttributeName: UIColor.black])
        
        // Set custom back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        // Set label to current month
        monthAndYearLabel.text = CVDate(date: Foundation.Date()).globalDescription
        menuView.dayOfWeekTextColor = UIColor.white
        
        menuView.sizeToFit()
        //calendarView.clipsToBounds = true
        calendarView.sizeToFit()
        //myView.sizeToFit()
        
        //print("VIEW WIDTH: \(myView.frame.width)")
        print("CALENDAR FRAME WIDTH: \(calendarView.frame.width)")
        print("TABLEVIEW WIDTH: \(myTableView.frame.width)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Deselect cells when view appears
        if let indexPath = myTableView.indexPathForSelectedRow {
            myTableView.deselectRow(at: indexPath, animated: true)
        }
        
        // Fetch all inactive carts, if any exist
        
        var fetchRequest: NSFetchRequest<Order>
        if #available(iOS 10.0, *) {
            fetchRequest = Order.fetchRequest() as! NSFetchRequest<Order>
        } else {
            // Fallback on earlier versions
            fetchRequest = NSFetchRequest<Order>(entityName: "Order")
        }
        let sortDescriptor = NSSortDescriptor(key: "dateOrdered", ascending: false)
        let firstPredicate = NSPredicate(format: "isActive == %@", false as CVarArg)
        fetchRequest.predicate = firstPredicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let fetchResults = try managedContext.fetch(fetchRequest) as? [Order] {
                entries = fetchResults
                print(fetchResults.count)
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        myTableView.reloadData()
        
        if entries?.count == 0 {
            self.myTableView.separatorStyle = .none
            noOrdersIcon.isHidden = false
            
        } else {
            self.myTableView.separatorStyle = .singleLine
            noOrdersIcon.isHidden = true
        }
    }
    
    // Set up Calendar View
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleTableViewCell
        
        // Get date components for sorting
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: entries![(indexPath as NSIndexPath).row].dateOrdered! as Date)
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let month = monthFormatter.string(from: entries![(indexPath as NSIndexPath).row].dateOrdered! as Date)
        cell.monthLabel.text = month
        cell.dayLabel.text = String(describing: components.day!)

        // Calculate time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H:mm"
        let time = timeFormatter.string(from: entries![(indexPath as NSIndexPath).row].dateOrdered! as Date)
        cell.timeLabel.text = time
        
        // Display description
        cell.descriptionLabel.text = entries![(indexPath as NSIndexPath).row].restaurant
        
        // Display price
        let price = entries![(indexPath as NSIndexPath).row].totalPrice! as Double
        cell.priceLabel.text = String(format: "$%.2f", price) 
        print(String(format: "%.2f", entries![(indexPath as NSIndexPath).row].totalPrice!))
        
        return cell
    }

    @IBAction func switchViewsButtonClicked(_ sender: AnyObject) {
        if switchViewsButton.selectedSegmentIndex == 0 {
            tableViewToTopConstraint.constant = 319
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            }) 
        } else {
            tableViewToTopConstraint.constant = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    // Set up custom header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.groupTableViewBackground
        header.textLabel!.textColor = UIColor.darkGray
        header.textLabel?.font = TV_HEADER_FONT
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
         selectedIndexPath = (indexPath as NSIndexPath).row
        
        // Get date components
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        selectedDate = dateFormatter.string(from: entries![(indexPath as NSIndexPath).row].dateOrdered! as Date)
        
        return indexPath
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Send the selected orderID to the next viewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toScheduleDetail" {
            let VC = segue.destination as! ScheduleDetailViewController
            VC.order = entries![selectedIndexPath!]
            VC.date = selectedDate!
        }
    }
}

// Required CVCalendar delegates
extension ScheduleViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {
    
    // MARK: - Calendar Appearance
    
    func dayOfWeekTextColor() -> UIColor {
        return UIColor.white
    }
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return UIColor.white
    }
    
    func dayLabelWeekdayOutTextColor() -> UIColor {
        return UIColor.gray
    }
    
    func dayLabelWeekdayHighlightedTextColor() -> UIColor {
        return UIColor.darkGray
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return UIColor.darkGray
    }
    
    func dayLabelPresentWeekdayHighlightedBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        monthAndYearLabel.text = date.globalDescription
        //myView.sizeToFit()
        
        if entries != nil {
            for i in 0..<entries!.count {
                let calendar = Calendar.current
                let dateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: entries![i].dateOrdered! as Date)
                let day = dateComponents.day
                let month = dateComponents.month
                let year = dateComponents.year
                
                if day == date.day && month == date.month &&  year == date.year {
                    self.myTableView.scrollToRow(at: IndexPath(row: i, section: 0), at: .top, animated: true)
                    break
                }
            }
        }

    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        if entries != nil {
            for entry in entries! {
                let calendar = Calendar.current
                let dateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: entry.dateOrdered! as Date)
                let day = dateComponents.day
                let month = dateComponents.month
                let year = dateComponents.year

                if day == dayView.date.day && month == dayView.date.month &&  year == dayView.date.year {
                    return true
                }
            }
        }

        return false
    }
    
    func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat {
        return 12
    }
    
    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor.white]
    }
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedDay = dayView
    }
    
    func toggleMonthViewWithMonthOffset(_ offset: Int) {
        let calendar = Calendar.current
        //        let calendarManager = calendarView.manager
        var components = Manager.componentsForDate(Foundation.Date()) // from today
        
        components.month! += offset
        
        let resultDate = calendar.date(from: components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
        updateViewConstraints()
    }
}

