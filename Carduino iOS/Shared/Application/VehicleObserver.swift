//
//  VehicleObserver.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import Foundation

class VehicleObserver: ObservableObject {
    @Published var vehicles: [Vehicle] = {
        var vehiclesURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") ?? URL(string: "/")!
        vehiclesURL.appendPathComponent("vehicles.json")
        
        if !FileManager.default.fileExists(atPath: vehiclesURL.path) {
            do {
                try "[]".write(to: vehiclesURL, atomically: true, encoding: .utf8)
            } catch let error {
                print("Failed to create default vehicles file")
            }
        }
        
        guard let data = try? Data(contentsOf: vehiclesURL) else {
            return [Vehicle]()
        }
        guard var vehicles = try? JSONDecoder().decode([Vehicle].self, from: data) else {
            print("Failed to decode json for vehicles")
            return [Vehicle]()
        }
        
        // get only VINs from drives that we don't have a record for
        var driveVins = DriveManager.getAllDriveVINs().filter { driveVin in
            vehicles.filter({ $0.vin != driveVin }).count == 0
        }
        
        for vin in driveVins {
            vehicles.append(Vehicle(vin: vin))
        }
        
        return vehicles
    }()
    
}
