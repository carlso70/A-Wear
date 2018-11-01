//
//  ViewController.swift
//  Awear
//
//  Created by James Carlson on 9/23/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import UIKit
import UserNotifications
import AudioToolbox
import UIKit
import AVFoundation
import CoreAudio
import CoreLocation
import CoreData
import WatchConnectivity

class ViewController: UIViewController, CLLocationManagerDelegate, WCSessionDelegate {
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var LEVEL_THRESHOLD: Float = -10.0
    var isCalibrating = false
    var VIBRATION_LEVEL = 1
    var REENABLE_TIME = Date();
    let locationMgr = CLLocationManager()
    
    @IBOutlet weak var currentVolume: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var calibrateButton: UIButton!
    @IBOutlet weak var healthAppBtn: UIButton!
    
    @IBOutlet weak var renableTime: UILabel!
    @IBOutlet weak var disableAudio: UIButton!
    @IBOutlet weak var vibrationSlider: UISlider!
    @IBOutlet weak var vibrateLvl: UILabel!
    
    // var pickerData: [String] = [String]();
    var audioEnabled =  true;
    var disableTime = 0;
    var timedEnabled = true;
    
    
    /* Setup WC Session (Watch Connectivity) */
    var session: WCSession?
    
    /* Session sets up the dispatch queue for messages recieved from watch */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.processWatchMessages(message: message)
        }
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    func sessionDidBecomeInactive(_ session: WCSession) { /* TODO */ }
    func sessionDidDeactivate(_ session: WCSession) { /* TODO */ }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makePretty();
        // Do any additional setup after loading the view, typically from a nib.
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            
            /* Send levels to watch */
            sendLevelThresholdMessageToWatch(level: volumeSlider.value, maxValue: volumeSlider.maximumValue, minValue: volumeSlider.minimumValue )
        }
        setupNotifications()
        setupAudioRecording()
        getMyLocation()
    }
    
    /* Handles incoming messages from the apple watch */
    func processWatchMessages(message: [String: Any]) {
        /* Trigger calibration */
        if message["StartCalibrating"] as? Bool != nil {
            self.calibrate()
        }
        
        /* Change level threshold */
        if let level = message["LevelThreshold"] as? Float {
            volumeSlider.value = level
            changeLevelThreshold(level: volumeSlider.value)
        }
        
        /* Disable Audio for time */
        if let downTime = message["DisableTime"] as? Int {
            self.disableTime = downTime
            self.disableApplication(time: downTime)
        }
    }
    
    /* VolumeSlider value between 1 - 10 */
    func changeLevelThreshold(level: Float) {
        volumeLabel.text = "\(volumeSlider.value)"
        LEVEL_THRESHOLD = level
    }
    
    @IBAction func onSliderChange(_ sender: Any) {
        changeLevelThreshold(level: volumeSlider.value)
        sendLevelThresholdMessageToWatch(level: volumeSlider.value, maxValue: volumeSlider.maximumValue, minValue: volumeSlider.minimumValue)
    }
    
    @IBAction func disableEnableAudio(_sender: UIButton){
        if audioEnabled {
            audioEnabled = false;
            recorder.stop();
            calibrateButton.isUserInteractionEnabled = false;
            volumeSlider.isUserInteractionEnabled = false;
            
            let earlyDate = Calendar.current.date(
                byAdding: .minute,
                value: 1,
                to: Date())
            
            REENABLE_TIME = earlyDate ?? Date();
            
            //audioEnabled = false;
            disableAudio.setTitle("Enable Listening", for: .normal);
            
            let alert = UIAlertController(title: "Listening Disabled", message: "How long do you want to disable listening?", preferredStyle: .alert)
            
            let indefAction = UIAlertAction(title: "Until Enabled", style: .default, handler: { (action) in
                self.disableTime = -1;
                self.disableApplication(time: self.disableTime)
                return
            })
            
            let oneAction = UIAlertAction(title: "1 hour", style: .default, handler: { (action) in
                self.disableTime = 1;
                self.disableApplication(time: self.disableTime)
                return
            })
            
            let threeAction = UIAlertAction(title: "3 hours", style: .default, handler: { (action) in
                self.disableTime = 3;
                self.disableApplication(time: self.disableTime)
            })
            
            let dayAction = UIAlertAction(title: "24 hours", style: .default, handler: { (action) in
                self.disableTime = 24;
                self.disableApplication(time: self.disableTime)
            })
            
            alert.addAction(oneAction)
            alert.addAction(threeAction)
            alert.addAction(dayAction)
            alert.addAction(indefAction)
            
            present(alert, animated: true, completion: nil)
            
            // add reenable time
            // print("HEEERETERTERT")
            //renableTime.text = "Disabled until: \(disableTime)"
            
            disableApplication(time: disableTime)
        } else {
            audioEnabled = true;
            REENABLE_TIME = Date();
            setupAudioRecording();
            calibrateButton.isUserInteractionEnabled = true;
            volumeSlider.isUserInteractionEnabled = true;
            //levelTimerCallback();
            disableAudio.setTitle("Disable Listening", for: .normal);
            renableTime.text = "";
            
            let alert = UIAlertController(title: "Listening Enabled", message: "Your application will now listen and notify you", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Uses core location to get the user's current location
    func getMyLocation() {
        let status  = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
            return
        }
        
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        locationMgr.delegate = self
        locationMgr.startUpdatingLocation()
    }
    
    /* CL LOCATION MANANAGER DELAGATE METHODS */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        print("Current location: \(currentLocation)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    /* END OF CL LOCATION MANAGER DELEAGATE METHODS */
    
    // Initializes a notification that can be triggered
    func setupNotifications() {
        // #1.1 - Create "the notification's category value--its type."
        let debitOverdraftNotifCategory = UNNotificationCategory(identifier: "volNotification", actions: [], intentIdentifiers: [], options: [])
        // #1.2 - Register the notification type.
        UNUserNotificationCenter.current().setNotificationCategories([debitOverdraftNotifCategory])
    }
    
    // Initializes the audio recording instance
    func setupAudioRecording() {
        // Setup recording
        view.backgroundColor = UIColor.cyan
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Option here attempts to mix with others (aka mix with system sounds, doesnt work however)
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
        } catch {
            return
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
        
        // Schedules a timer, which fires a callback(levelTimerCallback) every 0.02 seconds
        
        levelTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
    }
    
    func calibrate() {
        /* Tell watch calibration has begun */
        isCalibrating = true
        sendCalibrateMessageToWatch(isCalibrating: isCalibrating)
        
        levelTimer.invalidate()
        
        recorder.updateMeters()
        currentVolume.text = "\(recorder.averagePower(forChannel: 0))"
        calibrateButton.setTitle("Calibrating...", for: [])
        volumeLabel.text = "Calibrating..."
        
        let now = Date()
        let later = now.addingTimeInterval(5)
        var ct: Float = 0
        var sum: Float = 0
        
        while(Date() < later) {
            recorder.updateMeters()
            currentVolume.text = "\(recorder.averagePower(forChannel: 0))"
            sum = sum + recorder.averagePower(forChannel: 0)
            ct = ct + 1
        }
        
        calibrateButton.setTitle("Calibrate", for: [])
        
        let avg: Float = sum / ct
        volumeSlider.minimumValue = avg
        volumeSlider.maximumValue = avg + 50
        volumeSlider.value = avg + 25
        LEVEL_THRESHOLD = volumeSlider.value
        volumeLabel.text = "\(volumeSlider.value)"
        
        /* Tell watch calibration has ended */
        isCalibrating = false
        sendCalibrateMessageToWatch(isCalibrating: isCalibrating)
        sendLevelThresholdMessageToWatch(level: volumeSlider.value, maxValue: volumeSlider.maximumValue, minValue: volumeSlider.minimumValue)
        
        setupAudioRecording()
    }
    
    
    func sendCalibrateMessageToWatch(isCalibrating : Bool) {
        if let validSession = session {
            validSession.sendMessage(["Calibrating": isCalibrating], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func sendLevelThresholdMessageToWatch(level: Float, maxValue: Float, minValue: Float) {
        if let validSession = session {
            //            validSession.sendMessage(["LevelThreshold": ["level":level, "maxValue": maxValue, "minValue": minValue]], replyHandler: nil, errorHandler: nil)
            validSession.sendMessage(["LevelThreshold":level], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func sendVolumeLevelMessageToWatch(level: Float) {
        if let validSession = session {
            validSession.sendMessage(["VoiceLevel": level], replyHandler: nil, errorHandler: nil)
        }
    }
    
    
    /* Displays a simple error message dialog for the user */
    func displayErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func calibrateVolume(_ sender: UIButton) {
        calibrate()
    }
    
    // Callback ever 0.02 seconds
    @objc func levelTimerCallback() {
        
        checkDisabled()
        if audioEnabled {
            recorder.updateMeters()
            
            let level = recorder.averagePower(forChannel: 0)
            let isLoud = level > LEVEL_THRESHOLD
            currentVolume.text = "\(level)"
            /* Tell Apple watch the volume level */
            sendVolumeLevelMessageToWatch(level: level)
            
            // do whatever you want with isLoud
            //print("IsLoud? : ",isLoud)
            
            // Notifications
            if isLoud {
                //            let generator = UINotificationFeedbackGenerator()
                view.backgroundColor = UIColor.red
                // Need to stop timer and audio session before playing a vibration
                
                let diff = level - LEVEL_THRESHOLD
                if(diff > 15) {
                    let generator = UINotificationFeedbackGenerator()
                    //generator.notificationOccurred(.error)
                    
                    switch VIBRATION_LEVEL {
                    case 1:
                        generator.notificationOccurred(.error)
                    case 2:
                        generator.notificationOccurred(.error)
                        generator.notificationOccurred(.error)
                    case 3:
                        generator.notificationOccurred(.error)
                        generator.notificationOccurred(.error)
                        generator.notificationOccurred(.error)
                    default:
                        generator.notificationOccurred(.error)
                    }
                    
                    print("too loud")
                } else if diff > 7 {
                    let generator = UINotificationFeedbackGenerator()
                    
                    switch VIBRATION_LEVEL {
                    case 1:
                        generator.notificationOccurred(.success)
                    case 2:
                        generator.notificationOccurred(.success)
                        generator.notificationOccurred(.success)
                    case 3:
                        generator.notificationOccurred(.success)
                        generator.notificationOccurred(.success)
                        generator.notificationOccurred(.success)
                    default:
                        generator.notificationOccurred(.success)
                    }
                    
                    //generator.notificationOccurred(.success)
                    print("loud")
                } else {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    //  generator.impactOccurred()
                    
                    switch VIBRATION_LEVEL {
                    case 1:
                        generator.impactOccurred()
                    case 2:
                        generator.impactOccurred()
                        generator.impactOccurred()
                    case 3:
                        generator.impactOccurred()
                        generator.impactOccurred()
                        generator.impactOccurred()
                    default:
                        generator.impactOccurred()
                    }
                    
                    print("not that loud")
                }
                
                recorder.stop()
                levelTimer.invalidate()
                // Vibrate, and send notification
                AudioServicesPlaySystemSound(1521)
                //            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                sendNotification()
                // Restart audio recording
                setupAudioRecording()
            }
        }
    }
    
    
    func disableApplication(time: Int){
        // disable application for time Int
        
        let formatter = DateFormatter();
        formatter.dateFormat = "MMM d, h:mm a";
        var myString: String;
        
        switch time {
        case -1:
            renableTime.text = "Disabled"
            timedEnabled = false;
            print(time)
        case 1:
            let earlyDate = Calendar.current.date(
                byAdding: .second,
                value: 15,
                to: Date())
            myString = formatter.string(from: earlyDate as! Date)
            renableTime.text = "Disabled until: \(myString)"
            REENABLE_TIME = earlyDate ?? Date();
            print(myString)
        case 3:
            let earlyDate = Calendar.current.date(
                byAdding: .hour,
                value: 3,
                to: Date())
            
            myString = formatter.string(from: earlyDate as! Date)
            renableTime.text = "Disabled until: \(myString)"
            REENABLE_TIME = earlyDate ?? Date();
            print(time)
        case 24:
            let earlyDate = Calendar.current.date(
                byAdding: .hour,
                value: 24,
                to: Date())
            
            myString = formatter.string(from: earlyDate as! Date)
            renableTime.text = "Disabled until: \(myString)"
            REENABLE_TIME = earlyDate ?? Date();
            print(time)
        default:
            renableTime.text = ""
            print(time)
        }
    }
    
    func sendNotification() {
        // find out what are the user's notification preferences
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            
            // we're only going to create and schedule a notification
            // if the user has kept notifications authorized for this app
            guard settings.authorizationStatus == .authorized else { return }
            
            // create the content and style for the local notification
            let content = UNMutableNotificationContent()
            
            // #2.1 - "Assign a value to this property that matches the identifier
            // property of one of the UNNotificationCategory objects you
            // previously registered with your app."
            content.categoryIdentifier = "volNotification"
            
            // create the notification's content to be presented
            // to the user
            content.title = "Loud noise notification!"
            content.subtitle = "Exceeded maximum volume reached"
            content.body = "Please lower your voice"
            content.sound = UNNotificationSound.default
            content.badge = 1
            
            // #2.2 - create a "trigger condition that causes a notification
            // to be delivered after the specified amount of time elapses";
            // deliver after 10 seconds
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            
            // create a "request to schedule a local notification, which
            // includes the content of the notification and the trigger conditions for delivery"
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // "Upon calling this method, the system begins tracking the
            // trigger conditions associated with your request. When the
            // trigger condition is met, the system delivers your notification."
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    
    // Sends a test notification 10 seconds after pressing the button, notification will appear if app is in background
    @IBAction func sendNotification(_ sender: Any) {
        sendNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makePretty(){
        calibrateButton.layer.cornerRadius = 6
    }
    
    
    func checkDisabled(){
        if audioEnabled {
            print("enabled")
        } else {
            recorder.stop()
            calibrateButton.isUserInteractionEnabled = false;
            volumeSlider.isUserInteractionEnabled = false;
            
            if(Date() > REENABLE_TIME && timedEnabled){
                print("HERE")
                setupAudioRecording()
                audioEnabled = true;
                calibrateButton.isUserInteractionEnabled = true;
                volumeSlider.isUserInteractionEnabled = true;
                disableAudio.setTitle("Disable Listening", for: .normal);
                renableTime.text = "";
            }
        }
    }
    
}
