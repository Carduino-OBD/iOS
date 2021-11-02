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

class DriveV1: Drive, ObservableObject, Identifiable, Hashable, Equatable {
    
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
    
    deinit {
        print("Deinit")
    }
    
    
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
        
        guard polylineCoordinates.count >= 2 else {
            throw DriveParseError.needsAtLeast2Points
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.path.first!.date)
    }
    
    static func == (lhs: DriveV1, rhs: DriveV1) -> Bool {
        return lhs.path.first!.date == rhs.path.first!.date
    }
    
    
    var startPoint: DrivePointV1 {
        get {
            return self.path.first!
        }
    }
    
    var endPoint: DrivePointV1 {
        get {
            return self.path.last!
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
    
    
    /// Returns the fuel used during this trip. Due to the lack of precision in OBD II, returns a possible upper and lower bound
    var fuelUsed: ClosedRange<Measurement<UnitVolume>> {
        get {
            let fuelTankSizeGallons = VehicleObserver().vehicles.filter({ $0.vin == self.vin }).first!.fuelTankSize.converted(to: .gallons).value
            
            let startFuelTankLevelPercentUpper = Double(self.startFuelTankLevelPercent + 1) / 255.0
            let endFuelTankLevelPercentUpper = Double(self.endFuelTankLevelPercent - 1) / 255.0
            
            let startFuelTankLevelPercentLower = Double(self.startFuelTankLevelPercent - 1) / 255.0
            let endFuelTankLevelPercentLower = Double(self.endFuelTankLevelPercent + 1) / 255.0
            
            
            let upperBoundGallonsUsed = fuelTankSizeGallons * startFuelTankLevelPercentUpper - fuelTankSizeGallons * endFuelTankLevelPercentUpper
            let lowerBoundGallonsUsed = fuelTankSizeGallons * startFuelTankLevelPercentLower - fuelTankSizeGallons * endFuelTankLevelPercentLower
            
            
            return Measurement(value: lowerBoundGallonsUsed, unit: .gallons)...Measurement(value: upperBoundGallonsUsed, unit: .gallons)
        }
    }
    
    var fuelEfficiency: Measurement<UnitFuelEfficiency> {
        get {
            let distanceMiles = self.distance.converted(to: .miles).value
            
            let upperBoundGallonsUsed = self.fuelUsed.lowerBound.converted(to: .gallons).value
            let lowerBoundGallonsUsed = self.fuelUsed.upperBound.converted(to: .gallons).value

            let upperBoundMPG = distanceMiles / upperBoundGallonsUsed
            let lowerBoundMPG = distanceMiles / lowerBoundGallonsUsed
            
            let averageMPG = (upperBoundMPG + lowerBoundMPG) / 2
        
            return Measurement(value: averageMPG, unit: UnitFuelEfficiency.milesPerGallon)
        }
    }
}
