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
import HealthKit
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, WCSessionDelegate {
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var LEVEL_THRESHOLD: Float = 160
    var isCalibrating = false
    var VIBRATION_LEVEL = 1
    var REENABLE_TIME = Date();
    let locationMgr = CLLocationManager()
    let healthStore = HKHealthStore()
    
    var RECORD_STATS = true;
    var WATCH_CONNECT = true;
    //    var HEALTH_APP = false;
    var OUTDOOR_MODE = true;
    var OUTDOOR_AUTO = true;
    var OUTDOOR_MAN = true;
    
    @IBOutlet weak var currentVolume: UILabel!
    @IBOutlet weak var heartRateDisplay: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var calibrateButton: UIButton!
    @IBOutlet weak var heartBeatUnit: UILabel!
    @IBOutlet weak var outdoorLbl: UILabel!
    @IBOutlet weak var renableTime: UILabel!
    @IBOutlet weak var disableAudio: UIButton!
    @IBOutlet weak var healthKitAuth: UIButton!
    
    
    var audioEnabled = UserDefaults.standard.bool(forKey: "audioEnabled");
    var disableTime = 0;
    var timedEnabled = true;
    var healthEnabled = false;
    
    
    
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
            ConnectivityUtils.sendLevelThresholdMessageToWatch(session: session, level: volumeSlider.value, maxValue: volumeSlider.maximumValue, minValue: volumeSlider.minimumValue )
            
            //UserDefaults.standard.set(true, forKey: "watchConnect")
            UserDefaults.standard.set(true, forKey: "watchSupported")
            
        } else {
            UserDefaults.standard.set(false, forKey: "watchSupported")
            UserDefaults.standard.set(false, forKey: "watchConnect")
        }
        
        getUser()
        setupSettings()
        
        UserDefaults.standard.set(false, forKey: "calendarDisable")
        
        setupNotifications()
        setupAudioRecording()
        getMyLocation()
        
        print("VIBRATION LEVEL: \(VIBRATION_LEVEL)");
        
        heartRateDisplay.isHidden = true;
        heartBeatUnit.isHidden = true;
    }
    
    func getUser() {
        let awearUrl = "https://awear-222521.appspot.com/getuser";
        Alamofire.request(awearUrl, method: .post, parameters: ["username": UserDefaults.standard.string(forKey: "username") ?? "-1"], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let JSON):
                print("SUCCESS IN API REQUEST IN VIEWCONTROLLER")
                let response = JSON as! NSDictionary
                print(response)
                AdminUtils.updateSettings(response: response)
                self.setupSettings()
                if (response.object(forKey: "enabled") as! Bool == true) {
                    /* Switch audio to be enabled */
                    print("Should enalbe")
                    self.audioEnabled = true;
                    UserDefaults.standard.set(self.audioEnabled, forKey: "audioEnabled")
                    self.REENABLE_TIME = Date();
                    UserDefaults.standard.set(Date(), forKey: "reenableTime")
                    self.setupAudioRecording();
                    self.calibrateButton.isUserInteractionEnabled = true;
                    self.volumeSlider.isUserInteractionEnabled = true;
                    //levelTimerCallback();
                    self.disableAudio.setTitle("Disable Listening", for: .normal);
                    self.renableTime.text = "";
                    
                    let alert = UIAlertController(title: "Listening Enabled", message: "Your application will now listen and notify you", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                } else if (response.object(forKey: "enabled") as! Bool == false) {
                    self.disableTime = -1
                    self.disableApplication(time: -1)
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Failure", message: "Failed to load user", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                NSLog("Request failed with error: \(error)")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func setupSettings() {
        
        WATCH_CONNECT = UserDefaults.standard.bool(forKey: "watchConnect")
        RECORD_STATS = UserDefaults.standard.bool(forKey: "recordStats")
        VIBRATION_LEVEL = UserDefaults.standard.integer(forKey: "vibrationLevel")
        audioEnabled =  UserDefaults.standard.bool(forKey: "audioEnabled")
        // OUTDOOR_MODE = UserDefaults.standard.bool(forKey: "outdoorEnable")
        //        HEALTH_APP = UserDefaults.standard.bool(forKey: "healthEnable")
        OUTDOOR_AUTO = UserDefaults.standard.bool(forKey: "outdoorAutoEnable")
        OUTDOOR_MAN = UserDefaults.standard.bool(forKey: "outdoorManEnable")
        
        if(OUTDOOR_AUTO){
            checkAutoOutdoor();
        }else if(OUTDOOR_MAN){
            checkOutdoor()
        }else{
            OUTDOOR_MODE = false;
            outdoorLbl.text = ""
        }
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
            self.changeLevelThreshold(level: level)
        }
        
        /* Disable Audio for time */
        if let downTime = message["DisableTime"] as? Int {
            self.disableTime = downTime
            self.disableApplication(time: downTime)
        }
        
        if let enable = message["Enable"] as? Bool {
            if enable {
                audioEnabled = true;
                UserDefaults.standard.set(audioEnabled, forKey: "audioEnabled")
                REENABLE_TIME = Date();
                UserDefaults.standard.set(Date(), forKey: "reenableTime")
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
    }
    
    /* VolumeSlider value between 1 - 10 */
    func changeLevelThreshold(level: Float) {
        volumeLabel.text = "\(String(format: "%.01f", volumeSlider.value))"
        LEVEL_THRESHOLD = level
    }
    
    func disableEnable() {
        audioEnabled = UserDefaults.standard.bool(forKey: "audioEnabled")
        if audioEnabled {
            UserDefaults.standard.set(false, forKey: "audioEnabled")
            audioEnabled = false;
            recorder.stop();
            calibrateButton.isUserInteractionEnabled = false;
            volumeSlider.isUserInteractionEnabled = false;
            
            let earlyDate = Calendar.current.date(
                byAdding: .minute,
                value: 1,
                to: Date())
            
            REENABLE_TIME = earlyDate ?? Date();
            UserDefaults.standard.set(earlyDate, forKey: "reenableTime")
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
            return
        } else {
            audioEnabled = true;
            UserDefaults.standard.set(audioEnabled, forKey: "audioEnabled")
            UserDefaults.standard.set(false, forKey: "customDisabled");
            UserDefaults.standard.set(false, forKey: "meetingDisabled");
            
            globalCalVC!.getMostRecentDate()
            
            REENABLE_TIME = Date();
            UserDefaults.standard.set(Date(), forKey: "reenableTime")
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
    
    @IBAction func onSliderChange(_ sender: Any) {
        changeLevelThreshold(level: volumeSlider.value)
        ConnectivityUtils.sendLevelThresholdMessageToWatch(session: session, level: volumeSlider.value, maxValue: volumeSlider.maximumValue, minValue: volumeSlider.minimumValue)
    }
    
    @IBAction func disableEnableAudio(_sender: UIButton){
        self.disableEnable()
    }
    
    @IBAction func refreshUser(_ sender: Any) {
        self.getUser()
    }
    
    // Uses core location to get the user's current location
    func getMyLocation() {
        let status  = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationMgr.requestWhenInUseAuthorization()
            return
        }
        
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings to allow the app to automatically detect if you are indoors or outdoors.", preferredStyle: .alert)
            
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
        //        print("Current location: \(currentLocation)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //        print("Error \(error)")
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
        
        levelTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
    }
    
    func calibrate() {
        /* Tell watch calibration has begun */
        isCalibrating = true
        ConnectivityUtils.sendCalibrateMessageToWatch(session: self.session, isCalibrating: isCalibrating)
        
        levelTimer.invalidate()
        
        recorder.updateMeters()
        currentVolume.text = "\(recorder.averagePower(forChannel: 0) + 160)"
        calibrateButton.setTitle("Calibrating...", for: [])
        volumeLabel.text = "Calibrating..."
        
        let now = Date()
        let later = now.addingTimeInterval(5)
        var ct: Float = 0
        var sum: Float = 0
        
        while(Date() < later) {
            recorder.updateMeters()
            currentVolume.text = "\(recorder.averagePower(forChannel: 0) + 160)"
            sum = sum + recorder.averagePower(forChannel: 0) + 160
            ct = ct + 1
        }
        
        calibrateButton.setTitle("Calibrate", for: [])
        
        let avg: Float = sum / ct
        volumeSlider.minimumValue = avg
        
        //OUTDOOR_MODE = UserDefaults.standard.bool(forKey: "outdoorEnable")
        OUTDOOR_AUTO = UserDefaults.standard.bool(forKey: "outdoorAutoEnable")
        OUTDOOR_MAN = UserDefaults.standard.bool(forKey: "outdoorManEnable")
        
        if(OUTDOOR_AUTO){
            checkAutoOutdoor()
        }else if(OUTDOOR_MAN){
            checkOutdoor()
        }
        else{
            OUTDOOR_MODE = false;
            
        }
        
        if(OUTDOOR_MODE){
            volumeSlider.maximumValue = avg + 60
        }else {
            volumeSlider.maximumValue = avg + 30
        }
        
        volumeSlider.value = avg + (volumeSlider.maximumValue - avg)/2
        LEVEL_THRESHOLD = volumeSlider.maximumValue
        volumeLabel.text = "\(volumeSlider.value)"
        
        /* Tell watch calibration has ended */
        isCalibrating = false
        ConnectivityUtils.sendCalibrateMessageToWatch(session: self.session, isCalibrating: isCalibrating)
        ConnectivityUtils.sendLevelThresholdMessageToWatch(session: self.session, level: volumeSlider.value, maxValue: volumeSlider.maximumValue, minValue: volumeSlider.minimumValue)
        
        setupAudioRecording()
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
    
    func dBFS_convertTo_dB (dBFSValue: Float) -> Float
    {
        var level:Float = 0.0
        let peak_bottom:Float = -60.0 // dBFS -> -160..0   so it can be -80 or -60
        
        if dBFSValue < peak_bottom
        {
            level = 0.0
        }
        else if dBFSValue >= 0.0
        {
            level = 1.0
        }
        else
        {
            let root:Float              =   2.0
            let minAmp:Float            =   powf(10.0, 0.05 * peak_bottom)
            let inverseAmpRange:Float   =   1.0 / (1.0 - minAmp)
            let amp:Float               =   powf(10.0, 0.05 * dBFSValue)
            let adjAmp:Float            =   (amp - minAmp) * inverseAmpRange
            
            level = powf(adjAmp, 1.0 / root)
        }
        return level
    }
    
    // Callback ever 0.02 seconds
    @objc func levelTimerCallback() {
        checkDisabled()
        checkCustomDisable()
        checkCalendarDisable()
        
        OUTDOOR_AUTO = UserDefaults.standard.bool(forKey: "outdoorAutoEnable")
        OUTDOOR_MAN = UserDefaults.standard.bool(forKey: "outdoorManEnable")
        
        if(OUTDOOR_AUTO){
            checkAutoOutdoor()
        }else if(OUTDOOR_MAN){
            checkOutdoor()
        }
        else{
            OUTDOOR_MODE = false;
            outdoorLbl.text = ""
        }
        
        RECORD_STATS = UserDefaults.standard.bool(forKey: "recordStats")
        getHeartRate()
        recorder.updateMeters()
        
        //print(dBFS_convertTo_dB(dBFSValue: recorder.averagePower(forChannel: 0)))
        
        let level = recorder.averagePower(forChannel: 0) + 160
        let isLoud = level > LEVEL_THRESHOLD
        currentVolume.text = "\(String(format: "%.01f", level))"
        
        // do whatever you want with isLoud
        //print("IsLoud? : ",isLoud)
        // Need to stop timer and audio session before playing a vibration
        // Notifications
        if isLoud {
            //            let generator = UINotificationFeedbackGenerator()
            //                view.backgroundColor = UIColor.red
            // Need to stop timer and audio session before playing a vibration
            //  generator.impactOccurred()
            ConnectivityUtils.sendLoudNoiseMessageToWatch(session: session, isLoud: true)
            recordStat(voiceLevel: level)
            
            let diff = level/LEVEL_THRESHOLD
            if(diff > 1.3) {
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
                /* Save event to db */
                if(RECORD_STATS){
                    StatisticManager.save(date: Date.init(), threshold: LEVEL_THRESHOLD, voiceLevel: level, heartRate: 85)
                    print("saving stats")
                }
                
                if(OUTDOOR_MODE){
                    AudioServicesPlaySystemSound (1009)
                }
                print("too loud")
            } else if diff > 1.15 {
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
                if(OUTDOOR_MODE){
                    AudioServicesPlaySystemSound (1009)
                }
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
            getHeartRate();
        }
    }
    
    func recordStat(voiceLevel: Float) {
        var heartRate = 85.00
        do {
            /* fetchLatestHeartRateSample { (result) in
             heartRate = (result?.last?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())))!
             }*/
        }
        
        /* Save event to db */
        if(RECORD_STATS){
            StatisticManager.save(date: Date.init(), threshold: LEVEL_THRESHOLD, voiceLevel: voiceLevel, heartRate: Double(heartRate))
            print("saving stats")
        }
    }
    
    func disableApplication(time: Int){
        // disable application for time Int
        
        let formatter = DateFormatter();
        formatter.dateFormat = "MMM d, h:mm a";
        var myString: String;
        
        audioEnabled = false
        UserDefaults.standard.set(audioEnabled, forKey: "audioEnabled")
        
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
    
    func checkOutdoor(){
        OUTDOOR_MODE = UserDefaults.standard.bool(forKey: "outdoorManEnable")
        
        
        if(OUTDOOR_MODE){
            outdoorLbl.text = "OUTDOOR MODE IS ON"
        }
        else{
            outdoorLbl.text = ""
        }
        
    }
    
    func checkDisabled(){
        audioEnabled =  UserDefaults.standard.bool(forKey: "audioEnabled")
        if(!audioEnabled){
            recorder.stop()
            calibrateButton.isUserInteractionEnabled = false;
            volumeSlider.isUserInteractionEnabled = false;
            
            if(Date() > REENABLE_TIME && timedEnabled){
                print("HERE")
                setupAudioRecording()
                UserDefaults.standard.set(true, forKey: "audioEnabled")
                UserDefaults.standard.set(false, forKey: "customDisabled");
                UserDefaults.standard.set(false, forKey: "meetingDisabled");
                calibrateButton.isUserInteractionEnabled = true;
                volumeSlider.isUserInteractionEnabled = true;
                disableAudio.setTitle("Disable Listening", for: .normal);
                renableTime.text = "";
            }
        }
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
                self.heartRateDisplay.isHidden = false;
                self.heartBeatUnit.isHidden = false;
                self.healthKitAuth.isHidden = true;
                //                UserDefaults.standard.set(true, forKey: "healthEnabled")
                //                print(self.healthEnabled)
            }
        }
    }
    
    func fetchLatestHeartRateSample(
        completion: @escaping (_ samples: [HKQuantitySample]?) -> Void) {
        
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType
            .quantityType(forIdentifier: .heartRate) else {
                completion(nil)
                return
        }
        
        /// Predicate for specifiying start and end dates for the query
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date.distantPast,
                end: Date(),
                options: .strictEndDate)
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)
        
        /// Create the query
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [sortDescriptor]) { (_, results, error) in
                completion(results as? [HKQuantitySample])
        }
        
        /// Execute the query in the health store
        healthStore.execute(query)
    }
    
    func checkAutoOutdoor(){
        let curr = locationMgr.location
        
        let hor = lround(curr?.horizontalAccuracy ?? -1)
        
        //        print(hor)
        //print(hor)
        if (hor < 0)
        {
            OUTDOOR_MODE = false;
            // No Signal
        }
        else if(hor < 32)
        {
            // Full Signal
            OUTDOOR_MODE = true;
        }
        else{
            OUTDOOR_MODE = false;
        }
        
        if(OUTDOOR_MODE){
            outdoorLbl.text = "OUTDOOR MODE IS ON"
        }
        else{
            outdoorLbl.text = ""
        }
    }
    
    @IBAction func getHeartRate() {
        fetchLatestHeartRateSample { (result) in
            //this version gives the values in the form of 00.0
            let x = result?.last?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) ?? nil
            
            if(x?.description == nil)
            {
                return;
            }
            let y = x?.description
            
            self.heartRateDisplay.text = y
            print("\(String(describing: result?.last?.quantity))\n")
        }
    }
    
    func checkCustomDisable(){
        let CUSTOM_DISABLE = UserDefaults.standard.bool(forKey: "customDisabled")
        if(CUSTOM_DISABLE){
            
            audioEnabled = false;
            recorder.stop();
            calibrateButton.isUserInteractionEnabled = false;
            volumeSlider.isUserInteractionEnabled = false;
            
            //UserDefaults.standard.set(false, forKey: "audioEnabled")
            let formatter = DateFormatter();
            formatter.dateFormat = "MMM d, h:mm a";
            
            if(UserDefaults.standard.bool(forKey: "audioEnabled")){
                let time = UserDefaults.standard.integer(forKey: "customDisableTime")
                
                let earlyDate = Calendar.current.date(
                    byAdding: .second,
                    value: time,
                    to: Date())
                var myString = formatter.string(from: earlyDate as! Date)
                renableTime.text = "Disabled until: \(myString)"
                REENABLE_TIME = earlyDate ?? Date();
                
                disableAudio.setTitle("Enable Listening", for: .normal);
                UserDefaults.standard.set(false, forKey: "audioEnabled")
            }
        }
    }
    
    
    func checkCalendarDisable() {
        if(UserDefaults.standard.bool(forKey: "calendarDisable")) {
            let date = UserDefaults.standard.object(forKey: "disableDate") as! Date
            print(date)
            print("current date")
            print(Date())
            
            if(date <= Date() && !UserDefaults.standard.bool(forKey: "meetingDisabled")){
                let formatter = DateFormatter();
                formatter.dateFormat = "MMM d, h:mm a";
                
                self.audioEnabled = false;
                recorder.stop();
                calibrateButton.isUserInteractionEnabled = false;
                volumeSlider.isUserInteractionEnabled = false;
                if(UserDefaults.standard.bool(forKey: "audioEnabled")){
                    _ = UserDefaults.standard.integer(forKey: "customDisableTime")
                    
                    let earlyDate = Calendar.current.date(
                        byAdding: .minute,
                        value: 60,
                        to: Date())
                    var myString = formatter.string(from: earlyDate as! Date)
                    
                    
                    
                    renableTime.text = "Disabled until: \(myString)"
                    REENABLE_TIME = earlyDate ?? Date();
                    
                    disableAudio.setTitle("Enable Listening", for: .normal);
                    UserDefaults.standard.set(false, forKey: "audioEnabled")
                    UserDefaults.standard.set(true, forKey: "meetingDisabled");
                }
            }
        }
    }
}
