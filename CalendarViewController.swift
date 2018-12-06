//
//  CalendarViewController.swift
//  Awear
//
//  Created by Kathleen Masterson on 12/6/18.
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


class CalendarViewController : UIViewController{
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var helpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func help(_ sender: Any) {
        let alert = UIAlertController(title: "Meeting Times", message: "This page allows you to add dates and times to automatically disable your application for a certain time period", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
   
}
