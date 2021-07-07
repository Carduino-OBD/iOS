//
//  Carduino_iOSApp.swift
//  Shared
//
//  Created by Alex Taffe on 12/20/20.
//

import SwiftUI


@main
struct Carduino_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.openURL) var openURL
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        
        WindowGroup {
            CarduinoBaseView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext).onOpenURL(perform: { url in
                    guard let data = try? Data(contentsOf: url) else {
                        print("Invalid URL")
                        return
                    }
                    
                    do {
                        let _ = try DriveParser.getDrive(data: data) as! DriveV1
                    } catch let error{
                        print("Failed to parse drive due to error: \(error)")
                        return
                    }
                    print("Got Drive")
                    
                    guard var icloudDestinationURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
                        print("Could not get iCloud Drive, returning")
                        return
                    }
                    icloudDestinationURL.appendPathComponent(url.lastPathComponent)
                    do {
                        try data.write(to: icloudDestinationURL)
                    } catch let error {
                        print("Failed to write imported drive to iCloud due to error: \(error)")
                    }
                    
                })
                .accentColor(.red)
        }
    }
}
