//
//  CalendarVC.swift
//  Awear
//
//  Created by Kathleen Masterson on 12/5/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import AudioToolbox
import UIKit
import AVFoundation
import CoreAudio
import CoreLocation
import EventKit


class CalendarVC : UIViewController,  UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var backBtn: UIButton!
    
    // var cal;
    var events: [EKEvent] = [];
    @IBOutlet weak var tableView: UITableView!
    
    var test: [String] = ["test", "test1", "hiKatie"]
    
    var disableDates: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let store = EKEventStore()
        
        // Get the appropriate calendar
        let calendar = Calendar.current
        
        if store.responds(to: #selector(EKEventStore.requestAccess(to:completion:))) {
            // iOS Settings > Privacy > Calendars > MY APP > ENABLE | DISABLE
            store.requestAccess(to: .event) { granted, error in
                if granted {
                    print("User has granted permission!")
                    // Create the start date components
                    var oneDayAgoComponents = DateComponents()
                    oneDayAgoComponents.day = -1
                    let oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date())
                    
                    // Create the end date components
                    var oneYearFromNowComponents = DateComponents()
                    oneYearFromNowComponents.year = 1
                    let oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date())
                    
                    // Create the predicate from the event store's instance method
                    let predicate: NSPredicate = store.predicateForEvents(withStart: oneDayAgo ?? Date(), end: oneYearFromNow ?? Date(), calendars: nil)
                    
                    // Fetch all events that match the predicate
                    self.events = store.events(matching: predicate)
                    print("The content of array is\(self.events)")
                    
                    var hlp = self.events[0].startDate
                    
                    print(hlp)
                    
                    self.disableDates.append(hlp ?? Date())
                    
                    print(self.disableDates)
                    
                    UserDefaults.standard.set(true, forKey: "hasDates")
                    UserDefaults.standard.set(self.disableDates, forKey: "disableDates")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
       // self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return events.count
        //return test.count
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        //cell.textLabel?.text = test[indexPath.row]
        let events = self.events[indexPath.row]
        cell.textLabel?.text = events.title
        cell.detailTextLabel!.text = events.startDate.description
//        print("event cell returned")
        return cell
    }
}
