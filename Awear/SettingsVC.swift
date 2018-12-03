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
    
    @IBOutlet weak var outdoorSwitch: UISwitch!
    @IBOutlet weak var resetStatsBtn: UIButton!
    @IBOutlet weak var statsSwitch: UISwitch!
    @IBOutlet weak var disableBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var outdoorLbl: UILabel!
    @IBOutlet weak var outdoorMnlSwitch: UISwitch!
    @IBOutlet weak var disablePicker: UIDatePicker!
    
   
    var changed = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        let outdoor = UserDefaults.standard.bool(forKey: "outdoorAutoEnable")
        let manout = UserDefaults.standard.bool(forKey: "outdoorManEnable")
        
        
        // auto switch
        if(outdoor){
            outdoorSwitch.setOn(true, animated: false)
            outdoorLbl.isHidden = true;
            outdoorMnlSwitch.isHidden = true;
            
        }
        else{
            outdoorSwitch.setOn(false, animated: false)
            outdoorLbl.isHidden = false;
            outdoorMnlSwitch.isHidden = false;
            
            if(manout){
               outdoorMnlSwitch.setOn(true, animated: false)
            }else{
                outdoorMnlSwitch.setOn(false, animated: false)
            }
            
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
    

    
    @IBAction func statsOnOff(_ sender: Any){
      changed = true;
    }
    
    @IBAction func resetStatsClick(_ sender: Any) {
        let alert = UIAlertController(title: "Reset Statistics", message: "Are you sure you want to reset your statistics? This can not be undone.", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            print("reset stats")
            StatisticManager.deleteAll()
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
    
    
    @IBAction func autoOutdoorChange(_ sender: Any) {
        changed = true;
        if(outdoorSwitch.isOn){
            let alert = UIAlertController(title: "Automatic Outdoor Mode", message: "Automatic Outdoor mode is now active. This may be inaccurate. If you need it to be completely accurate please use the manual mode.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            alert.addAction(ok)
            
            present(alert, animated: true, completion: nil)
            
            outdoorLbl.isHidden = true;
            outdoorMnlSwitch.isHidden = true;
        }else{
            outdoorLbl.isHidden = false;
            outdoorMnlSwitch.isHidden = false;
        }
    }
    
    @IBAction func outdoorEnable(_ sender: Any) {
        changed = true;
    }
    
    
    
    @IBAction func disableCustom(_ sender: Any) {
        let customDisable = disablePicker.countDownDuration;
        UserDefaults.standard.set(true, forKey: "customDisabled");
        UserDefaults.standard.set(customDisable, forKey: "customDisableTime");
    }
    
    
    
    
    
    @IBAction func save(_ sender: Any) {
        let alert = UIAlertController(title: "Saved!", message: "All setting changes have been saved.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
        
        changed = false;
        
        
        if(statsSwitch.isOn)
        {
            UserDefaults.standard.set(true, forKey: "recordStats");
        }
        else{
            UserDefaults.standard.set(false, forKey: "recordStats");
        }
        
        
        let vol = lroundf(vibrationSlider.value);
        vibrationLvl.text = "\(vol)";
        
        UserDefaults.standard.set(vol, forKey: "vibrationLevel");
        
        if(outdoorSwitch.isOn){
            UserDefaults.standard.set(true, forKey: "outdoorAutoEnable");
            
            //let alert = UIAlertController(title: "Outdoor Mode", message: "Outdoor mode is now active. You will be able to set a higher threshold and will also recieve a ping as well as a vibration notification.", preferredStyle: .alert)
            
            //let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            //alert.addAction(ok)
            
            //present(alert, animated: true, completion: nil)
        }else{
    
            UserDefaults.standard.set(false, forKey: "outdoorAutoEnable");
            
            if(outdoorMnlSwitch.isOn){
                UserDefaults.standard.set(true, forKey: "outdoorManEnable");
            }else{
                UserDefaults.standard.set(false, forKey: "outdoorManEnable");
            }
            
            
        }
        
        if(outdoorMnlSwitch.isOn){
            UserDefaults.standard.set(true, forKey: "outdoorManEnable");
        }else{
            UserDefaults.standard.set(false, forKey: "outdoorManEnable");
        }
        
        
    }
    
    
}
