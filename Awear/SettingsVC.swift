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
    @IBOutlet weak var healthAppSwitch: UISwitch!
    
    @IBOutlet weak var outdoorSwitch: UISwitch!
    @IBOutlet weak var resetStatsBtn: UIButton!
    @IBOutlet weak var statsSwitch: UISwitch!
    @IBOutlet weak var watchSwitch: UISwitch!
    @IBOutlet weak var saveBtn: UIButton!
    
    var changed = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vibrationSlider.minimumValue = 1;
        vibrationSlider.maximumValue = 3;
        
        
        vibrationSlider.value = Float (UserDefaults.standard.integer(forKey: "vibrationLevel"))
        let vol = lroundf(vibrationSlider.value);
        vibrationLvl.text = "\(vol)";
        
        let wtch = UserDefaults.standard.bool(forKey: "watchConnect")
        let allow = UserDefaults.standard.bool(forKey: "watchSupported")
        let health = UserDefaults.standard.bool(forKey: "healthEnable")
        let outdoor = UserDefaults.standard.bool(forKey: "outdoorEnable")
        
        if(outdoor){
            outdoorSwitch.setOn(true, animated: false)
        }
        else{
            outdoorSwitch.setOn(false, animated: false)
        }
            
        
        if(health){
            healthAppSwitch.setOn(true, animated: false)
        }else{
            healthAppSwitch.setOn(false, animated: false)
        }
        
        
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
        
        if(changed){
        let alert = UIAlertController(title: "Are you sure?", message: "You have unsaved settings you will lose if you exit now.", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            print("dont save stats")
            return
        })
        
        let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
            
            return
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
      
    }
    
    @IBAction func onVibrateChange(_ sender: Any){
        let vol = lroundf(vibrationSlider.value);
        vibrationLvl.text = "\(vol)";
        
        //UserDefaults.standard.set(vol, forKey: "vibrationLevel");
        
        changed = true;
        
    }
    
    @IBAction func watchOnOff(_ sender: Any){
      changed = true;
    }
    
    @IBAction func statsOnOff(_ sender: Any){
      changed = true;
    }
    
    @IBAction func resetStatsClick(_ sender: Any) {
        let alert = UIAlertController(title: "Reset Statistics", message: "Are you sure you want to reset your statistics? This can not be undone.", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            print("reset stats")
            return
        })
        
        let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
            print("do not reset stats")
            return
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func healthAppEnabling(_ sender: Any) {
        if(!healthAppSwitch.isOn){
            //UserDefaults.standard.set(true, forKey: "healthEnable");
        
            
            
            //UserDefaults.standard.set(false, forKey: "healthEnable");
            
            let alert = UIAlertController(title: "Health Application", message: "You will not be able to use the health application functionality now.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
        }
       changed = true;
    }
    
    
    @IBAction func outdoorEnable(_ sender: Any) {
        changed = true;
    }
    
    
    @IBAction func save(_ sender: Any) {
        let alert = UIAlertController(title: "Saved!", message: "All setting changes have been saved.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
        
        changed = false;
        if(healthAppSwitch.isOn){
            UserDefaults.standard.set(true, forKey: "healthEnable");
        }else{
            
            
            UserDefaults.standard.set(false, forKey: "healthEnable");
            
            
        }
        
        if(statsSwitch.isOn)
        {
            UserDefaults.standard.set(true, forKey: "recordStats");
        }
        else{
            UserDefaults.standard.set(false, forKey: "recordStats");
        }
        
        if(watchSwitch.isOn)
        {
            UserDefaults.standard.set(true, forKey: "watchConnect");
        }
        else{
            UserDefaults.standard.set(false, forKey: "watchConnect");
        }
        
        let vol = lroundf(vibrationSlider.value);
        vibrationLvl.text = "\(vol)";
        
        UserDefaults.standard.set(vol, forKey: "vibrationLevel");
        
        if(outdoorSwitch.isOn){
            UserDefaults.standard.set(true, forKey: "outdoorEnable");
            
            //let alert = UIAlertController(title: "Outdoor Mode", message: "Outdoor mode is now active. You will be able to set a higher threshold and will also recieve a ping as well as a vibration notification.", preferredStyle: .alert)
            
            //let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            //alert.addAction(ok)
            
            //present(alert, animated: true, completion: nil)
        }else{
            
            
            UserDefaults.standard.set(false, forKey: "outdoorEnable");
            
            
        }
        
    }
    
    
}
