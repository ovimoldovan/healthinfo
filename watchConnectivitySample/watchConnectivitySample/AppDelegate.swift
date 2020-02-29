//
//  AppDelegate.swift
//  watchConnectivitySample
//
//  Created by Ovidiu Moldovan on 26/01/2020.
//  Copyright © 2020 Ovidiu Moldovan. All rights reserved.
//

import UIKit
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        let healthStore = HKHealthStore()
        healthStore.handleAuthorizationForExtension { (success, error) in
        }
    }

    func requestHealthKitPermission() {
        let sampleType: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .heartRate)!]
        let healthStore = HKHealthStore()
            
        healthStore.requestAuthorization(toShare: sampleType, read: sampleType) { (success, error) in
            if let error = error {
                print("Error requesting health kit authorization: \(error)")
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.requestHealthKitPermission()
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

