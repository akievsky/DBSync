//
//  AuthManager.swift
//  DBSyncWrapper
//
//  Created by Oleksandr Kyivskyi on 10/9/15.
//  Copyright © 2015 Oleksandr Kyivskyi. All rights reserved.
//

import UIKit
import SwiftyDropbox

public class AuthManager {
    
    public typealias AuthManagerChangeHandler = (Bool) -> Void
    
    private var handlers = [String: AuthManagerChangeHandler]()
    
    static let sharedAuthManager = AuthManager()
    
    public var linked : Bool {
        return DropboxAuthManager.sharedAuthManager.hasStoredAccessTokens()
    }
    
    public func authorizeFromController(controller: UIViewController) {
        Dropbox.authorizeFromController(controller)
    }
    
    public func unlinkAccount() {
        Dropbox.unlinkClient()
        deliverCallbacks(linked)
    }
    
    public func handleRedirectURL(url: NSURL) {
        let wasLinked = linked
        
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success( _):
                print("Success! User is logged into Dropbox.")
            case .Error( _, let description):
                print("Error: \(description)")
            }
        }
        
        if wasLinked != linked {
            deliverCallbacks(linked)
        }
    }
    
    public func addAuthListener(listenerId: String, handler: AuthManagerChangeHandler) {
        self.handlers[listenerId] = handler
    }
    
    public func removeAuthListener(listenerId: String) {
        self.handlers[listenerId] = nil
    }
    
    private func deliverCallbacks(status: Bool) {
        for handler in handlers.values {
            handler(status)
        }
    }
}