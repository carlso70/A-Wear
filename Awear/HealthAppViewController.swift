//
//  HealthAppViewController.swift
//  Awear
//
//  Created by Kathleen Masterson on 10/31/18.
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
import HealthKit

class HealthAppViewController : UIViewController{
    let healthStore = HKHealthStore()
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var authBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: UIButton){
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction func authoriseHealthKitAccess(_ sender: UIButton) {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        ]
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (_, _) in
            print("Authorized?")
        }
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (bool, error) in
            if let e = error {
                print("Oops! Something went wrong during Authorization. \(e.localizedDescription)")
            } else {
                print("User has completed the authorization.")
            }
        }
    }
    
    
    
}
