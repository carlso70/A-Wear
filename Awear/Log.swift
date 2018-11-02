//
//  Log.swift
//  Awear
//
//  Created by James Carlson on 11/2/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import Foundation

class Logs {
    var date: Date
    var dateStr: String
    var heartRate: Double
    var threshold: Float
    var voiceLevel: Float
    
    init(date: Date, heartRate: Double, threshold: Float, voiceLevel: Float) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Your New Date format as per requirement change it own
        let newDate: String = dateFormatter.string(from: date) // pass Date here
        self.dateStr = newDate
        
        self.date = date
        self.heartRate = heartRate
        self.threshold = threshold
        self.voiceLevel = voiceLevel
    }
}
