//
//  VehicleObserver.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import Foundation

class VehicleObserver: ObservableObject {
    private static var vehiclesURL: URL = {
        var vehiclesURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") ?? URL(string: "/")!
        vehiclesURL.appendPathComponent("vehicles.json")
        return vehiclesURL
    }()
    
    @Published var vehicles: [Vehicle] = {
        
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
        
        return vehicles
    }()
    
    func save() throws {
        let json = try JSONEncoder().encode(self.vehicles)
        try json.write(to: VehicleObserver.vehiclesURL)
    }
    
}
