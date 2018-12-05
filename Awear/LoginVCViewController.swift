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
        
        print("LOGIN")
        Alamofire.request(awearUrl, method: .post, parameters: ["username": username.text ?? "", "password": password.text ?? ""], encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                let response = JSON as! NSDictionary
                print(response.object(forKey: "username")!)
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
        //        performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
}
