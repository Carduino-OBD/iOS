//
//  VehiclesView.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import SwiftUI

struct VehiclesView: View {
    
    @StateObject var vehicleObserver = VehicleObserver()
    @State var firstAppear = true
    
    @State var saveError = false
    @State var saveErrorMessage = ""
    var body: some View {
        Form {
            Section {
                ForEach(vehicleObserver.vehicles.indices) { idx in
                    let vehicle = vehicleObserver.vehicles[idx]
                    // If we have a nickname, display it and the VIN. Otherwise, display just the VIN
                    let vehicleDescription = vehicle.nickname != "" ? (vehicle.nickname + " (" + vehicle.vin + ")") : vehicle.vin
                    NavigationLink(vehicleDescription, destination: VehicleView(vehicle: self.$vehicleObserver.vehicles[idx]))
                }
            }
        }
        .navigationBarTitle(Text("Vehicles"))
        .onAppear {
            if firstAppear {
                firstAppear = false
            } else {
                saveError = false
                saveErrorMessage = ""
                do {
                    try vehicleObserver.save()
                } catch let error {
                    saveError = true
                    saveErrorMessage = error.localizedDescription
                }
            }
        }
        .alert(isPresented: $saveError) {
            Alert(title: Text("Failed to save vehicle due to error \(saveErrorMessage)"))
        }
    }
    
}

struct VehiclesView_Previews: PreviewProvider {
    static var previews: some View {
        VehiclesView()
    }
}
