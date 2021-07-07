//
//  VehicleView.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import SwiftUI
import Combine

struct VehicleView: View {
    @Binding var vehicle: Vehicle
    
    @State private var fuelTankSize = ""
    var body: some View {
        Form {
            Section {
                TextField("Nickname", text: $vehicle.nickname ?? "")
                TextField("Fuel Tank Size", text: $fuelTankSize)
                    .keyboardType(.decimalPad)
                    .onReceive(Just(fuelTankSize)) { newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        self.fuelTankSize = filtered + " gallons"
                    }
            }
        }.navigationTitle(vehicle.vin)
    }
}
