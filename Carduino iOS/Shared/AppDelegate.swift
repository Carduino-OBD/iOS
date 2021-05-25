//
//  AppDelegate.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 5/25/21.
//

import UIKit
import IceCream

class AppDelegate: NSObject, UIApplicationDelegate {
    var syncEngine: SyncEngine?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        syncEngine = SyncEngine(objects: [
            SyncObject(type: Drive.self)
        ])
        application.registerForRemoteNotifications()
        return true
    }
}
