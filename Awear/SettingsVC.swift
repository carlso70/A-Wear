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
    
    @IBOutlet weak var statsSwitch: UISwitch!
    @IBOutlet weak var watchSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vibrationSlider.minimumValue = 1;
        vibrationSlider.maximumValue = 3;
        
        
        vibrationSlider.value = Float (UserDefaults.standard.integer(forKey: "vibrationLevel"))
        let vol = lroundf(vibrationSlider.value);
        vibrationLvl.text = "\(vol)";
        
        let wtch = UserDefaults.standard.bool(forKey: "watchConnect")
        let allow = UserDefaults.standard.bool(forKey: "watchSupported")
        
        if(!allow){
            watchSwitch.isUserInteractionEnabled = false;
        }
        
        if(wtch && allow){
            watchSwitch.setOn(true, animated: false)
        }
        else{
            watchSwitch.setOn(false, animated: false)
        }
        
        let stats = UserDefaults.standard.bool(forKey: "recordStats")
        
        if(stats){
            statsSwitch.setOn(true, animated: false)
        }
        else{
            statsSwitch.setOn(false, animated: false)
        }
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
        
        UserDefaults.standard.set(vol, forKey: "vibrationLevel");
        
    }
    
    @IBAction func watchOnOff(_ sender: Any){
        if(watchSwitch.isOn)
        {
            UserDefaults.standard.set(true, forKey: "watchConnect");
        }
        else{
            UserDefaults.standard.set(false, forKey: "watchConnect");
        }
    }
    
    @IBAction func statsOnOff(_ sender: Any){
        if(statsSwitch.isOn)
        {
            UserDefaults.standard.set(true, forKey: "recordStats");
        }
        else{
            UserDefaults.standard.set(false, forKey: "recordStats");
        }
    }
}
