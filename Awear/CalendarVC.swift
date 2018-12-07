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


var globalCalVC: CalendarVC?

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
        
        globalCalVC = self as! CalendarVC
        
        // Get the appropriate calendar
        let calendar = Calendar.current
        
        if store.responds(to: #selector(EKEventStore.requestAccess(to:completion:))) {
            // iOS Settings > Privacy > Calendars > MY APP > ENABLE | DISABLE
            store.requestAccess(to: .event) { granted, error in
                if granted {
                    print("User has granted permission!")
                    // Create the start date components
                    var oneDayAgoComponents = DateComponents()
                    oneDayAgoComponents.day = 0
                    let oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date())
                    
                    // Create the end date components
                    var oneYearFromNowComponents = DateComponents()
                    oneYearFromNowComponents.year = 1
                    let oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date())
                    
                    // Create the predicate from the event store's instance method
                    let predicate: NSPredicate = store.predicateForEvents(withStart: oneDayAgo ?? Date(), end: oneYearFromNow ?? Date(), calendars: nil)
                    
                    // Fetch all events that match the predicate
                    self.events = store.events(matching: predicate)
                    
                    //swift 3
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        removePastDates()
        getMostRecentDate()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func help(_ sender: Any) {
        let alert = UIAlertController(title: "Meeting Times", message: "This page allows you to view meeting times from your calendar and set them to automatically disable your application when the event starts", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you selected event: \(events[indexPath.row])")
        
        let alert = UIAlertController(title: "Disable during Event", message: "Would you like to automatically disable during this event?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.disableDates.append(self.events[indexPath.row].startDate)
            
            print(self.disableDates)
            tableView.cellForRow(at: indexPath)?.textLabel?.text = self.events[indexPath.row].title + " \tDISABLED"
            //tableView.cellForRow(at: indexPath)?.selectedBackgroundView?.backgroundColor = UIColor.red
            self.getMostRecentDate()
            return
        })
        
        let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
            
            if(self.disableDates.contains(self.events[indexPath.row].startDate)){
                tableView.cellForRow(at: indexPath)?.textLabel?.text = self.events[indexPath.row].title
                let r = self.disableDates.firstIndex(of: self.events[indexPath.row].startDate)
                self.disableDates.remove(at: r ?? 0)
            }
            
            self.getMostRecentDate()
            return
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        //let cell = tableView.dequeueReusableCell
        let event = events[indexPath.row]
        print("Current event is \(event)")
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = event.startDate.description
        cell.detailTextLabel?.isEnabled = true
        cell.detailTextLabel?.isHidden = false
        print("event cell returned")
        return cell
    }
    
    func sortArray(){
        disableDates.sort()
        disableDates = Array(Set(disableDates))
        disableDates.sort()
       // disableDates.
        print(disableDates)
    }
    
    func getMostRecentDate(){
        
        removePastDates()
        
        if(disableDates.isEmpty){
            UserDefaults.standard.set(false, forKey: "calendarDisable")
            return
        }else{
        
            sortArray()
            let d = disableDates[0]
            UserDefaults.standard.set(d, forKey: "disableDate")
            UserDefaults.standard.set(true, forKey: "calendarDisable")
        }
    }
    
    func removePastDates(){
        sortArray()
        
        if(!disableDates.isEmpty)
        {
        var d = disableDates[0]
        while(Date() > d){
            disableDates.remove(at: 0)
            
            if(disableDates.isEmpty){
                UserDefaults.standard.set(false, forKey: "calendarDisable")
                return
            }else{
                sortArray()
                d = disableDates[0]
            }
            
            
        }
        }
        
    }
}
