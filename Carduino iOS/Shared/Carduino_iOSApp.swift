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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CarduinoBaseView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
