//
//  ViewController.swift
//  DBSyncWrapper
//
//  Created by Oleksandr Kyivskyi on 9/7/15.
//  Copyright (c) 2015 Oleksandr Kyivskyi. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        AuthManager.sharedAuthManager.addAuthListener("MainControllerListener") { (_) -> Void in
            self.updateUI()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AuthManager.sharedAuthManager.removeAuthListener("MainControllerListener")
    }
    
    func updateUI() {
        
        let linked = AuthManager.sharedAuthManager.linked
        
        self.userNameLabel.hidden = !linked
        
        let buttonTitle = linked ? "Logout" : "Login"
        self.loginButton?.setTitle(buttonTitle, forState: UIControlState.Normal)
        
        if let client = Dropbox.authorizedClient {
            client.usersGetCurrentAccount().response { result, error in
                if let userAccount = result {
                    self.userNameLabel.text = userAccount.name.displayName
                }
                
                if let theError = error {
                    print(theError)
                }
            }
        }
    }
    
    @IBAction func list(_: AnyObject) {
        if let client = Dropbox.authorizedClient {
            client.filesListFolder(path: "").response { response, error in
                if let result = response {
                    print("Folder contents:")
                    for entry in result.entries {
                        print(entry.name)
                    }
                } else {
                    print(error!)
                }
            }
        }
    }
    
    @IBAction func loginButtonTapped(_: AnyObject) {
        if AuthManager.sharedAuthManager.linked {
            AuthManager.sharedAuthManager.unlinkAccount()
        } else {
            AuthManager.sharedAuthManager.authorizeFromController(self)
        }
    }
    
}

