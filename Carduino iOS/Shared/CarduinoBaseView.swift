//
//  ContentView.swift
//  Shared
//
//  Created by Alex Taffe on 12/20/20.
//

import SwiftUI
import CoreData

struct CarduinoBaseView: View {
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: DrivesView()) {
                        Text("Drives")
                    }
                }
            }.navigationBarTitle(Text("Carduino"))
            .accentColor(.orange)
        }
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CarduinoBaseView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
