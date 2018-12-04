//
//  LoginVCViewController.swift
//  Awear
//
//  Created by Puja Mittal on 12/3/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import UIKit

class LoginVCViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func makeAccount(_ sender: Any) {
        guard let url = URL(string: "https://awear-client.appspot.com") else { return }
        UIApplication.shared.open(url)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
