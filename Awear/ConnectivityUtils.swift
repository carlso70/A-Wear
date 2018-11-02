//
//  ConnectivityUtils.swift
//  Awear
//
//  Created by James Carlson on 11/1/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import Foundation
import WatchConnectivity

class ConnectivityUtils: NSObject {
    
    static func sendVolumeLevelMessageToWatch(session: WCSession?, level: Float) {
        if let validSession = session {
            validSession.sendMessage(["VoiceLevel": level], replyHandler: nil, errorHandler: nil)
        }
    }
   
    static func sendCalibrateMessageToWatch(session: WCSession?, isCalibrating : Bool) {
        if let validSession = session {
            validSession.sendMessage(["Calibrating": isCalibrating], replyHandler: nil, errorHandler: nil)
            print("Sending isCalibrating messag")
        } else {
            print("BAD SESSION ")
        }
    }
    
    static func sendLevelThresholdMessageToWatch(session: WCSession?, level: Float, maxValue: Float, minValue: Float) {
        if let validSession = session {
            //            validSession.sendMessage(["LevelThreshold": ["level":level, "maxValue": maxValue, "minValue": minValue]], replyHandler: nil, errorHandler: nil)
            validSession.sendMessage(["LevelThreshold":level], replyHandler: nil, errorHandler: nil)
        }
    }

}
