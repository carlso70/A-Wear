//
//  InterfaceController.swift
//  AwearWatch Extension
//
//  Created by Puja Mittal on 10/24/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import AVFoundation

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    /* Session sets up the dispatch queue for messages recieved from phone */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.processPhoneMessages(message: message)
        }
    }
    
    @IBOutlet weak var voiceLevelLabel: WKInterfaceLabel!
    @IBOutlet weak var volumeSlider: WKInterfaceSlider!
    @IBOutlet weak var calibrateButton: WKInterfaceButton!
    @IBOutlet weak var disableButton: WKInterfaceButton!
    
    let session = WCSession.default
    
    /* Handles incoming messages from the apple watch */
    func processPhoneMessages(message: [String: Any]) {
        
        /* Trigger calibration */
        if let isCalibrating = message["Calibrating"] as? Bool {
            if isCalibrating {
                calibrateButton.setTitle("Calibrating...")
            } else {
                calibrateButton.setTitle("Calibrate")
            }
        }
        
        /* Change level threshold */
        if let level = message["LevelThreshold"] as? Float {
            volumeSlider.setValue(level)
        }
 
        /* Update voice level from iPhone */
        if let voice = message["VoiceLevel"] as? Float {
            voiceLevelLabel.setText("Volume: \(voice)")
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    /* Sends a message to the */
    func disableApp(time: Int) {
        session.sendMessage(["DisableTime": time], replyHandler: nil, errorHandler: nil)
    }
    
    /* Sends a new application context to iOS app to start Calibrating */
    @IBAction func calibrateButtonOnClick() {
        session.sendMessage(["StartCalibrating": true], replyHandler: nil, errorHandler: nil)
    }
    
    @IBAction func volumeThresholdOnChange(_ value: Float) {
        session.sendMessage(["LevelThreshold": value], replyHandler: nil, errorHandler: nil)
    }
    
    @IBAction func disableButtonOnClick() {
        let action1 = WKAlertAction(title: "1", style: .destructive){
            self.disableApp(time: 1)
        }
        let action2 = WKAlertAction(title: "3", style: .destructive) {
            self.disableApp(time: 3)
        }
        let action3 = WKAlertAction(title: "24", style: .destructive) {
            self.disableApp(time: 24)
        }
        let action4 = WKAlertAction(title: "24", style: .destructive) {
            self.disableApp(time: -1) //TODO check how disable forever works
        }
        let action5 = WKAlertAction(title: "Cancel", style: .cancel) {}
        
        presentAlert(withTitle: "Disable Application", message: "Select Time", preferredStyle: .actionSheet, actions: [action1, action2, action3, action4, action5])
    }
    
    @IBAction func enableButtonOnClick() {
        session.sendMessage(["Enable": true], replyHandler: nil, errorHandler: nil)
    }

}
