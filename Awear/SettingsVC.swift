//
//  SettingsVC.swift
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

class SettingsVC : UIViewController{
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var vibrationSlider: UISlider!
    @IBOutlet weak var vibrationLvl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vibrationSlider.minimumValue = 1;
        vibrationSlider.maximumValue = 3;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIButton){
      dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onVibrateChange(_ sender: Any){
        let vol = lroundf(vibrationSlider.value);
        vibrationLvl.text = "\(vol)";
    }
}
