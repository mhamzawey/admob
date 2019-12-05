//
//  AppDelegate.swift
//  AdMob
//
//  Created by Mohamed Hamza on 21/11/2019.
//  Copyright © 2019 Mohamed Hamza. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AppLovinSDK
import MoPub


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        ALSdk.initializeSdk()
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "97583e6c1e86464da7450b63a3920853")
        MoPub.sharedInstance().initializeSdk(with: sdkConfig){
            
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

