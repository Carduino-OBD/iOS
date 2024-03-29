//
//  DriveV1.swift
//  Carduino iOS (iOS)
//
//  Created by Alex Taffe on 5/18/21.
//

import Foundation
import CloudKit
import CoreLocation
import Polyline
import MapKit

struct DrivePointV1: Identifiable {
    var point: CLLocationCoordinate2D
    var date: Date
    var gpsSpeed: Measurement<UnitSpeed>
    var heading: Int16
    var altitude: Measurement<UnitLength>
    var vehicleSpeed: Measurement<UnitSpeed>
    
    var id: Date {
        get {
            return self.date
        }
    }
}

class DriveV1: Drive, ObservableObject, Identifiable {
    var path = [DrivePointV1]()
    var vin: String
    private var startFuelTankLevelPercent: UInt8
    private var endFuelTankLevelPercent: UInt8
    
    var mkPolyline: MKPolyline?
    var points: [CLLocation]
    
    var id: Date {
        get {
            return self.path.first!.date
        }
    }
    
    private static let HEADER_SIZE:UInt32 = 28
    private static let DRIVE_FRAME_SIZE:UInt32 = 14
    private static let FOOTER_SIZE:UInt32 = 1
    
    
    init(data: Data) throws {
        let versionNumber = data.subdata(in: 0..<2).withUnsafeBytes({ $0.load(as: UInt16.self) }).littleEndian
        guard versionNumber == 1 else {
            throw DriveParseError.unknownVersion(message: "\(Self.self) requires version number 1, got \(versionNumber), please check application logic")
        }
        
        var vinData = data.subdata(in: 2..<19)
        vinData.append(Data([0]))
        self.vin = String(cString: [UInt8](vinData))
        
        self.startFuelTankLevelPercent = data.subdata(in: 19..<20).withUnsafeBytes({ $0.load(as: UInt8.self) }).littleEndian
        
        let polylineSize = data.subdata(in: 20..<24).withUnsafeBytes({ $0.load(as: UInt32.self) }).littleEndian
        let driveFrameSize = data.subdata(in: 24..<28).withUnsafeBytes({ $0.load(as: UInt32.self) }).littleEndian
        
        guard driveFrameSize % DriveV1.DRIVE_FRAME_SIZE == 0 else {
            throw DriveParseError.invalidDriveFrameSize
        }
        
        guard DriveV1.HEADER_SIZE + polylineSize + driveFrameSize + DriveV1.FOOTER_SIZE + 1 == data.count else {
            throw DriveParseError.packetSizeInvalid
        }
        
        var polylineData = data.subdata(in: 28..<(28 + Int(polylineSize)))
        polylineData.append(Data([0]))
        
        let polyline = Polyline(encodedPolyline: String(cString: [UInt8](polylineData)))
        
        guard let polylineCoordinates = polyline.coordinates else {
            throw DriveParseError.polylineInvalid
        }
        
        guard let mkPolyline = polyline.mkPolyline else {
            throw DriveParseError.polylineInvalid
        }
        
        self.mkPolyline = mkPolyline
        self.points = polyline.locations!
        
        guard driveFrameSize / DriveV1.DRIVE_FRAME_SIZE == polylineCoordinates.count else {
            throw DriveParseError.mismatchedPolylineFrameCount
        }
        
        for (i, coordinate) in polylineCoordinates.enumerated() {
            let startOffset = Int(28 + polylineSize + (UInt32(i) * DriveV1.DRIVE_FRAME_SIZE))
            
            let time = data.subdata(in: startOffset..<(startOffset + 8)).withUnsafeBytes({ $0.load(as: UInt32.self) }).littleEndian
            let gpsSpeed = data.subdata(in: (startOffset + 8)..<(startOffset + 9)).withUnsafeBytes({ $0.load(as: UInt8.self) }).littleEndian
            let heading = data.subdata(in: (startOffset + 9)..<(startOffset + 11)).withUnsafeBytes({ $0.load(as: Int16.self) }).littleEndian
            let altitude = data.subdata(in: (startOffset + 11)..<(startOffset + 13)).withUnsafeBytes({ $0.load(as: Int16.self) }).littleEndian
            let vehicleSpeed = data.subdata(in: (startOffset + 13)..<(startOffset + 14)).withUnsafeBytes({ $0.load(as: UInt8.self) }).littleEndian
            
            let drivePoint = DrivePointV1(point: coordinate,
                                          date: Date(timeIntervalSince1970: TimeInterval(time)),
                                          gpsSpeed: Measurement(value: Double(gpsSpeed), unit: .kilometersPerHour),
                                          heading: heading,
                                          altitude: Measurement(value: Double(altitude), unit: .meters),
                                          vehicleSpeed: Measurement(value: Double(vehicleSpeed), unit: .kilometersPerHour)
            
            )
            self.path.append(drivePoint)
        }
        
        /*
         ```
         |-----GPS Time-----|-----GPS Speed-----|-----Heading-----|-----Altitude-----|-----Vehicle Speed-----|
               uint64_t            uint8_t              int16_t          int16_t              uint8_t
         ```
         */
        
        self.endFuelTankLevelPercent = data.subdata(in: Data.Index((28 + polylineSize + driveFrameSize))..<(Int(28 + polylineSize + driveFrameSize) + 1)).withUnsafeBytes({ $0.load(as: UInt8.self) }).littleEndian
        
    }

    var startCoordinateHumanReadableName: String?
    var endCoordinateHumanReadableName: String?
    
    
    var startPoint: DrivePointV1? {
        get {
            return self.path.first
        }
    }
    
    var endPoint: DrivePointV1? {
        get {
            return self.path.last
        }
    }
    
    
    var distance: Measurement<UnitLength> {
        get {
            guard self.path.count >= 2 else {
                return Measurement(value: 0, unit: UnitLength.meters)
            }
            var total = 0.0
            for i in 1..<self.points.count {
                total += self.points[i-1].distance(from: self.points[i])
            }
            return Measurement(value: total, unit: UnitLength.meters)
        }
    }
    
    var duration: TimeInterval {
        get {
            guard self.path.count >= 2 else {
                return 0
            }
            return self.path.last!.date.timeIntervalSince(self.path.first!.date)
        }
    }
    
    var fuelUsed: Measurement<UnitVolume> {
        get {
            return Measurement(value: 0, unit: .gallons)
        }
    }
    
    var fuelEfficiency: Measurement<UnitFuelEfficiency> {
        get {
            let distanceMiles = self.distance.converted(to: .miles).value
            
            
            
            return Measurement(value: distanceMiles, unit: UnitFuelEfficiency.milesPerGallon)
        }
    }
}
