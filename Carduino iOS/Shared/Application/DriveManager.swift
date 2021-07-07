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
        let drives = try? FileManager.default.contentsOfDirectory(at: icloudDestinationURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            .filter({ $0.pathExtension == "cdu" }) // We only want CDU documents
            .map({ try? Data(contentsOf: $0) }) // Attempt to read in the data
            .compactMap { $0 } // Remove any failed attempts at reading
            .map({ try? DriveV1(data: $0) }) // Convert the data to drives
            .compactMap { $0 } // Remove any failed attempts at parsing
        
        if drives == nil {
            print("Warning: unable to retrieve drives")
        }
        return drives ?? [DriveV1]()
    }
    
    static func getDateMappedDrives() -> [Date: [DriveV1]] {
        return getDrives().reduce([Date: [DriveV1]](), { result, drive in
            var result = result
            let components = Calendar.current.dateComponents([.year, .month, .day], from: drive.path.first!.date)
            let date = Calendar.current.date(from: components)!
            let existing = result[date] ?? [DriveV1]()
            result[date] = existing + [drive]
            return result
        })
    }
    
    static func getAllDriveVINs() -> [String] {
        return Array(Set(getDrives().map({ $0.vin })))
    }
}
