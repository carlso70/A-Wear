//
//  LoginVCViewController.swift
//  Awear
//
//  Created by Puja Mittal on 12/3/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import UIKit
import Alamofire

class LoginVCViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func makeAccount(_ sender: Any) {
        guard let url = URL(string: "https://awear-client.appspot.com") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func login(_ sender: Any) {
        let awearUrl = "https://awear-222521.appspot.com/login";
        
        if (username.text == "" || password.text == "") {
            let alert = UIAlertController(title: "Error", message: "Fill out all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        
        Alamofire.request(awearUrl, method: .post, parameters: ["username": username.text ?? "-1", "password": password.text ?? "-1"], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                let response = JSON as! NSDictionary
                print(response.object(forKey: "username")!)
                
                AdminUtils.updateSettings(response: response)
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            case .failure(let error):
                print("Request failed with error: \(error)")
                let alert = UIAlertController(title: "Failure", message: "Failed to login. Invalid credentials.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
