//
//  StatisticsViewController.swift
//  Awear
//
//  Created by Kathleen Masterson on 10/31/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import Foundation
import UIKit

class StatisticsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var but: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var logs: [Logs] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = "Heart Rate: \(logs[indexPath.row].heartRate)\nVoice Level: \(logs[indexPath.row].voiceLevel)\nThreshold: \(logs[indexPath.row].threshold)"

        let alert = UIAlertController(title: "Log on \(logs[indexPath.row].dateStr)", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell"/*Identifier*/, for: indexPath)
        cell.textLabel?.text = logs[indexPath.row].dateStr
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Load Data */
        let result = StatisticManager.fetchAll()
        
        for data in result {
            logs.append(Logs.init(date: data.value(forKey: "Date") as! Date,
                                  heartRate: data.value(forKey: "heartRate") as! Double,
                                  threshold: data.value(forKey: "threshold") as! Float,
                                  voiceLevel: data.value(forKey: "voiceLevel") as! Float))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func back(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
 
}
