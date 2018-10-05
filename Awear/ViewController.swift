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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var LEVEL_THRESHOLD: Float = -10.0
    let locationMgr = CLLocationManager()

    @IBOutlet weak var currentVolume: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var calibrateButton: UIButton!
    
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        i = 6
//        tapped()
        setupNotifications()
        setupAudioRecording()
        getMyLocation()
    }
    
    func tapped() {
//        i += 1
        print("Running \(i)")
        
        switch i {
        case 1:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            print("error") //3 quick pings
            
        case 2:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            print("'success'") //2 quick pings
        case 3:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            print("warning") //2 slow pings
        case 4:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            print("light") // very light ping
        case 5:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            print("medium") // medium
            
        case 6:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            print("heavy") // decent
            
        default:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            i = 7
        }
    }
    
    @IBAction func onSliderChange(_ sender: Any) {
        print(volumeSlider.value)
        volumeLabel.text = "\(volumeSlider.value)"
        LEVEL_THRESHOLD = volumeSlider.value
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

    @IBAction func calibrateVolume(_ sender: UIButton) {
//        recorder.stop()
        levelTimer.invalidate()
        
        recorder.updateMeters()
        currentVolume.text = "\(recorder.averagePower(forChannel: 0))"
        sender.setTitle("Calibrating...", for: [])
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
        
        sender.setTitle("Calibrate", for: [])
        
        let avg: Float = sum / ct
        volumeSlider.minimumValue = avg
        volumeSlider.maximumValue = avg + 50
        volumeSlider.value = avg + 25
        LEVEL_THRESHOLD = volumeSlider.value
        volumeLabel.text = "\(volumeSlider.value)"
        
        setupAudioRecording()
    }
    
    // Callback ever 0.02 seconds
    @objc func levelTimerCallback() {
        
        recorder.updateMeters()
        
        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        currentVolume.text = "\(level)"
        
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
                generator.notificationOccurred(.error)
                print("too loud")
            }else if(diff > 7) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                print("loud")
            }else {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
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
}

