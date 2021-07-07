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
    
    var body: some View {
        let fuelTankBinding = Binding<String>(
            get: { self.vehicle.fuelTankSize.value.clean },
            set: { fuelTankSizeString in
                if fuelTankSizeString.hasSuffix(".") {
                    return
                }
                guard let newFuelTankSize = Double(fuelTankSizeString) else { return }
                
                if Locale.current.usesMetricSystem {
                    self.vehicle.fuelTankSize = Measurement(value: newFuelTankSize, unit: UnitVolume.liters)
                } else {
                    self.vehicle.fuelTankSize = Measurement(value: newFuelTankSize, unit: UnitVolume.gallons)
                }
                
            }
        )
        
        Form {
            Section(header: Text("Nickname")) {
                TextField("Nickname", text: $vehicle.nickname)
                    .autocapitalization(.words)
            }
            let fuelTankUnit =  Locale.current.usesMetricSystem ? "(Liters)" : "(Gallons)"
            Section(header: Text("Fuel Tank Size \(fuelTankUnit)")) {
                TextField("Fuel Tank Size \(fuelTankUnit)", text: fuelTankBinding)
                    .keyboardType(.decimalPad)
            }
        }.navigationTitle(vehicle.vin)
    }
    
}
