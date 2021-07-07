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
    
    @State var errorShown: Bool = false
    @State var errorMessage: String = ""
    
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
                        try DriveManager.importDrive(data: data, fileName: url.lastPathComponent)
                    } catch let error {
                        errorShown = true
                        errorMessage = "Failed to import drive due to error \(error)"
                    }
                    
                })
                .accentColor(.red)
                .alert(isPresented: $errorShown) {
                    Alert(title: Text(errorMessage))
                }
        }
    }
}
