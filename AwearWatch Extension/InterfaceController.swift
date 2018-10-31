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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    @IBOutlet weak var voiceLevelLabel: WKInterfaceLabel!
    @IBOutlet weak var volumeSlider: WKInterfaceSlider!
    @IBOutlet weak var calibrateButton: WKInterfaceButton!
    @IBOutlet weak var disableButton: WKInterfaceButton!
    
    
    let session = WCSession.default
    
    /* Session sets up the dispatch queue for messages recieved from iOS */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.processApplicationContext()
        }
    }
    
    func processApplicationContext() {
        if let iPhoneContext = session.receivedApplicationContext as? [String : Bool] {
            if iPhoneContext["Calibrating"] == true {
                voiceLevelLabel.setText("Calibrating")
            } else {
                voiceLevelLabel.setText("Not Calibrating")
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        processApplicationContext()
        
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
    
    /* Sends a new application context to iOS app to start Calibrating */
    @IBAction func calibrateButtonOnClick() {
        session.sendMessage(["StartCalibrating": true], replyHandler: nil, errorHandler: nil) 
    }
    
    @IBAction func disableButtonOnClick() {
    }
    
    
}
