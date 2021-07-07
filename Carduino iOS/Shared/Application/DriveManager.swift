//
//  DriveManager.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import Foundation


class DriveManager {
    static func getDrives() -> [DriveV1] {
        let icloudDestinationURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") ?? URL(string: "/")!
        var drives = try? FileManager.default.contentsOfDirectory(at: icloudDestinationURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            .filter({ $0.pathExtension == "cdu" }) // We only want CDU documents
            .map({ try? Data(contentsOf: $0) }) // Attempt to read in the data
            .compactMap { $0 } // Remove any failed attempts at reading
            .map({ try? DriveV1(data: $0) }) // Convert the data to drives
            .compactMap { $0 } // Remove any failed attempts at parsing
        
        if drives == nil {
            print("Warning: unable to retrieve drives")
        }
        drives?.sort(by: { $0.path.first!.date > $1.path.first!.date })
        return drives ?? [DriveV1]()
    }
    
    static func getDateMappedDrives() -> [Date: [DriveV1]] {
        var dict = getDrives().reduce([Date: [DriveV1]](), { result, drive in
            var result = result
            let components = Calendar.current.dateComponents([.year, .month, .day], from: drive.path.first!.date)
            let date = Calendar.current.date(from: components)!
            let existing = result[date] ?? [DriveV1]()
            result[date] = existing + [drive]
            return result
        })
        
        for key in dict.keys {
            dict[key]?.sort(by: { $0.path.first!.date > $1.path.first!.date })
        }
        
        return dict
    }
    
    static func getAllDriveVINs() -> [String] {
        return Array(Set(getDrives().map({ $0.vin })))
    }
    
    static func importDrive(data: Data, fileName: String) throws {
        let drive = try DriveParser.getDrive(data: data) as! DriveV1
        let vehicleObserver = VehicleObserver()
        if  vehicleObserver.vehicles.filter({ $0.vin == drive.vin }).count == 0 {
            vehicleObserver.vehicles.append(Vehicle(vin: drive.vin, nickname: "", fuelTankSize: Measurement(value: 0, unit: .gallons)))
            try vehicleObserver.save()
        }
        print("Got Drive")
        
        guard var icloudDestinationURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            throw NSError(domain: "Could not get iCloud Drive, returning", code: -1, userInfo: nil)
        }
        icloudDestinationURL.appendPathComponent(fileName)
        try data.write(to: icloudDestinationURL)
    }
}
