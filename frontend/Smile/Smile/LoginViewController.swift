//
//  LoginViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit

import FBSDKLoginKit

var userID : String!

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["user_friends"]
        return button
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginButton)
        
        loginButton.center = view.center

        // Do any additional setup after loading the view.
        
        loginButton.delegate = self
    }
    
    let session = URLSession()
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        userID = result.token.userID
        
        var request = URLRequest(url: URL(string: "/api/users/login", relativeTo: site)!)
        request.httpMethod = "POST"
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["fbId" : userID], options: [])
        
        session.dataTask(with: request).resume()
        
        dismiss(animated: true, completion: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

}
