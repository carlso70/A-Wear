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
    
}
