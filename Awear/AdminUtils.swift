//
//  AdminUtils.swift
//  Awear
//
//  Created by James Carlson on 12/5/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import Foundation

class AdminUtils {
    static func updateSettings(response: NSDictionary) {
        UserDefaults.standard.set(response.object(forKey: "recordStats") as! Bool, forKey: "recordStats")
        UserDefaults.standard.set(response.object(forKey: "enabled") as! Bool, forKey: "audioEnabled")
        UserDefaults.standard.set(response.object(forKey: "outdoorMode") as! Bool, forKey: "outdoorManEnable")
//        UserDefaults.standard.set(response.object(forKey: "outdoorMode") as! Bool, forKey: "outdoorAutoEnable")
        UserDefaults.standard.set(response.object(forKey: "username") as! String, forKey: "username")
        UserDefaults.standard.set(response.object(forKey: "child") as! String, forKey: "child")
        UserDefaults.standard.set(response.object(forKey: "password") as! String, forKey: "password")
    }
}
