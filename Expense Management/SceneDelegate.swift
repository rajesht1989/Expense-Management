//
//  SceneDelegate.swift
//  Expense Management
//
//  Created by Rajesh Thangaraj on 27/05/20.
//  Copyright © 2020 Rajesh Thangaraj. All rights reserved.
//

import UIKit
import ZCUIFramework

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else {
                return
        }
//        window = UIWindow(windowScene: windowScene)
        
        // ZohoAuth Configuration
        
        let scope = ["ZohoCreator.meta.READ", "ZohoCreator.data.READ", "ZohoCreator.meta.CREATE", "ZohoCreator.data.CREATE", "ZohoCreator.data.CREATE", "aaaserver.profile.READ", "ZohoContacts.userphoto.READ", "ZohoContacts.contactapi.READ"]
        let clientID = "1000.3KN1CJ6LTBX9598Z24WFB2B0TPP2BH"
        let clientSecret = "89bf639a6b5c757fcf89116182afc6367686044b8a"
        let urlScheme = "expenses://"
        let accountsUrl = "https://accounts.zoho.com"
    
        ZohoAuth.initWithClientID(clientID, clientSecret: clientSecret, scope: scope, urlScheme: urlScheme, mainWindow: window, accountsURL: accountsUrl)
        
        // To verify if the app is already logged in
        
        ZohoAuth.getOauth2Token { (token, error) in
            if token == nil {
                // Not logged in
                self.showLoginScreen()
            } else {
                // App logged in already.
                self.launchDashboard()
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set < UIOpenURLContext > ) {
        if let context = URLContexts.first {
            let _ = ZohoAuth.handleURL(context.url,
                                       sourceApplication: context.options.sourceApplication,
                                       annotation: context.options.annotation)
        }
    }
    
    func showLoginScreen() {
        ZohoAuth.presentZohoSign( in: { (token, error) in
            if token != nil {
                // success login
                self.launchDashboard()
            }
        })
    }
    
    @objc func logout() {
        ZohoAuth.revokeAccessToken { (error) in
            self.showLoginScreen()
        }
    }
    
    func launchDashboard() {
        DispatchQueue.main.async {
            Creator.configure(delegate: self)
            
            let sectionController = ZCUIService.getViewController(for: Application(appOwnerName: AppConstants.appOwner ?? "", appLinkName: AppConstants.appLinkName ?? ""))

            self.window?.rootViewController = UINavigationController(rootViewController: sectionController)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                sectionController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "⎋", style: .done, target: self, action: #selector(self.logout))
            }
        }
    }
}




extension SceneDelegate: ZCUIServiceDelegate {
    func openURL(for openURLTasks: [OpenUrlTask]) {
        
    }
    
    func oAuthToken(with completion: @escaping AccessTokenCompletion) {
        ZohoAuth.getOauth2Token {
            (token, error) in
            completion(token, error)
        }
    }
    
    func configuration() -> CreatorConfiguration {
        return CreatorConfiguration(creatorURL: "https://creator.zoho.com")
    }
    
  
}

