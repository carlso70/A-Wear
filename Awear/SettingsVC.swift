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
import Alamofire

class SettingsVC : UIViewController{
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var outdoorSwitch: UISwitch!
    @IBOutlet weak var resetStatsBtn: UIButton!
    @IBOutlet weak var statsSwitch: UISwitch!
    @IBOutlet weak var disableBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var outdoorLbl: UILabel!
    @IBOutlet weak var outdoorMnlSwitch: UISwitch!
    @IBOutlet weak var disablePicker: UIDatePicker!
    @IBOutlet weak var lblDisable: UIDatePicker!
    
    
    var changed = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let awearUrl = "https://awear-222521.appspot.com/getuser";
        
        var outdoor = UserDefaults.standard.bool(forKey: "outdoorAutoEnable")
        var manout = UserDefaults.standard.bool(forKey: "outdoorManEnable")
        
        Alamofire.request(awearUrl, method: .post, parameters: ["username": UserDefaults.standard.string(forKey: "username") ?? "-1"], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let JSON):
                print("SUCCESS IN API REQUEST IN Settings VC")
                let response = JSON as! NSDictionary
                print(response)
                AdminUtils.updateSettings(response: response)
                outdoor = response.object(forKey: "outdoorMode") as! Bool
                manout = response.object(forKey: "outdoorMode") as! Bool
            case .failure(let error):
                print(error)
            }
        }
        
        print(UserDefaults.standard.dictionaryRepresentation())
        
        //        let outdoor = UserDefaults.standard.bool(forKey: "outdoorAutoEnable")
        //        let manout = UserDefaults.standard.bool(forKey: "outdoorManEnable")
        //
        
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
        
        disablePicker.countDownDuration = 300;
        
        let custDis = UserDefaults.standard.bool(forKey: "customDisabled");
        
        if(custDis){
            disablePicker.isHidden = true;
            disableBtn.isHidden = true;
            lblDisable.isHidden = true;
        }else{
            disablePicker.isHidden = false;
            disableBtn.isHidden = false;
            lblDisable.isHidden = false;
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
            let alert = UIAlertController(title: "Automatic Outdoor Mode", message: "Automatic Outdoor mode is now active. This will cause your application to be in Indoor mode when connected to WiFi and Outdoor mode when not connected.", preferredStyle: .alert)
            
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
        print(customDisable);
        UserDefaults.standard.set(true, forKey: "customDisabled");
        UserDefaults.standard.set(customDisable, forKey: "customDisableTime");
        
        let alert = UIAlertController(title: "Disabled", message:  "You have disabled the application", preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
        
        disablePicker.isHidden = true;
        disableBtn.isHidden = true;
        lblDisable.isHidden = true; 
        
    }
    
    func saveOnline() {
        /*
         * Add user post request
         * body:
         *      {
         *          username: string,
         *          password: string,
         *          isParent: bool,
         *          child: string,
         *          enabled: bool,
         *          outdoorMode: bool,
         *          recordStats: bool
         *      }
         */
        let awearUrl = "https://awear-222521.appspot.com/updateUser"
        let parameters = ["username": UserDefaults.standard.string(forKey: "username") ?? "",
                          "password": UserDefaults.standard.string(forKey: "password") ?? "",
                          "isParent": UserDefaults.standard.bool(forKey: "isParent"),
                          "child": UserDefaults.standard.string(forKey: "child") ?? "",
                          "enabled": UserDefaults.standard.bool(forKey: "audioEnabled"),
                          "outdoorMode": UserDefaults.standard.bool(forKey: "outdoorManEnable"),
                          "recordStats": UserDefaults.standard.bool(forKey: "recordStats")] as [String : Any];
        
        print("Parameters = \(parameters)")
        Alamofire.request(awearUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let JSON):
                print("SUCCESS IN API REQUEST IN Settings VC")
                let response = JSON as! NSDictionary
                print(response)
                AdminUtils.updateSettings(response: response)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func save(_ sender: Any) {
        let alert = UIAlertController(title: "Saved!", message: "All setting changes have been saved.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
        
        changed = false;
        
        if(statsSwitch.isOn) {
            UserDefaults.standard.set(true, forKey: "recordStats");
        } else{
            UserDefaults.standard.set(false, forKey: "recordStats");
        }
        
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

        self.saveOnline()
    }
    
    
}
