//
//  InterfaceController.swift
//  AwearWatch Extension
//
//  Created by Puja Mittal on 10/24/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation

class InterfaceController: WKInterfaceController{
    
    @IBOutlet weak var voiceLevelLabel: WKInterfaceLabel!
    @IBOutlet weak var volumeSlider: WKInterfaceSlider!
    @IBOutlet weak var calibrateButton: WKInterfaceButton!
    @IBOutlet weak var disableButton: WKInterfaceButton!
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var LEVEL_THRESHOLD: Float = -10.0
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        setupAudioRecording()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setupAudioRecording() {
    }
    
    // Callback ever 0.02 seconds
    @objc func levelTimerCallback() {
        
        recorder.updateMeters()
        
        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        voiceLevelLabel.setText("Voice Level: \(level)")
        
        // do whatever you want with isLoud
        //print("IsLoud? : ",isLoud)
        
        // Notifications
        if isLoud {
            //            let generator = UINotificationFeedbackGenerator()
            //            view.backgroundColor = UIColor.red
            // Need to stop timer and audio session before playing a vibration
            
            let diff = level - LEVEL_THRESHOLD
            if(diff > 15) {
                WKInterfaceDevice.current().play(.failure)
                print("too loud")
            }else if(diff > 7) {
                WKInterfaceDevice.current().play(.stop)
                print("loud")
            }else {
                WKInterfaceDevice.current().play(.click)
                print("not that loud")
            }
            
            recorder.stop()
            levelTimer.invalidate()
            // Vibrate, and send notification
            //            AudioServicesPlaySystemSound(1521)
            //            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            //            sendNotification()
            // Restart audio recording
            setupAudioRecording()
        }
    }
    
    
    @IBAction func calibrateButtonOnClick() {
    }
    
    @IBAction func disableButtonOnClick() {
    }
    
    
}
