//
//  AppDelegate.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 5/25/21.
//

#if os(iOS)
import UIKit
#endif

import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    var bluetoothManager: BluetoothManager!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        syncEngine = SyncEngine(objects: [
//            SyncObject(type: Drive.self)
//        ])
//        application.registerForRemoteNotifications()
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
            self.bluetoothManager = BluetoothManager()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
}
