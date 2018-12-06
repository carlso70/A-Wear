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


class CalendarVC : UIViewController{
    
    @IBOutlet weak var backBtn: UIButton!
    
   // var cal;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var store = EKEventStore()
        
        
        // Get the appropriate calendar
        var calendar = Calendar.current
        
        
        if store.responds(to: #selector(EKEventStore.requestAccess(to:completion:))) {
            // iOS Settings > Privacy > Calendars > MY APP > ENABLE | DISABLE
            store.requestAccess(to: .event) { granted, error in
                if granted {
                    print("User has granted permission!")
                    // Create the start date components
                    var oneDayAgoComponents = DateComponents()
                    oneDayAgoComponents.day = -1
                    var oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date())
                    
                    // Create the end date components
                    var oneYearFromNowComponents = DateComponents()
                    oneYearFromNowComponents.year = 1
                    var oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date())
                    
                    // Create the predicate from the event store's instance method
                    var predicate: NSPredicate = store.predicateForEvents(withStart: oneDayAgo ?? Date(), end: oneYearFromNow ?? Date(), calendars: nil)
                    
                    // Fetch all events that match the predicate
                    var events = store.events(matching: predicate)
                    print("The content of array is\(events)")
                    }
            }
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
}
