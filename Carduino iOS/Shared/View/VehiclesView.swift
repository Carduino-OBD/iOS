//
//  VehiclesView.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import SwiftUI

struct VehiclesView: View {
    
    @StateObject var vehicleObserver = VehicleObserver()
    var body: some View {
        Form {
            Section {
                ForEach(vehicleObserver.vehicles.indices) { idx in
                    let vehicle = vehicleObserver.vehicles[idx]
                    NavigationLink(vehicle.vin, destination: VehicleView(vehicle: self.$vehicleObserver.vehicles[idx]))
                }
            }
        }
        .navigationBarTitle(Text("Vehicles"))
    }
    
}

struct VehiclesView_Previews: PreviewProvider {
    static var previews: some View {
        VehiclesView()
    }
}
