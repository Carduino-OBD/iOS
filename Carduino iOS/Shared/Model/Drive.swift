//
//  Drive.swift
//  Carduino iOS (iOS)
//
//  Created by Alex Taffe on 5/18/21.
//

import Foundation
import RealmSwift
import IceCream
import CloudKit
import CoreLocation

class DrivePoint: Object {
    var point: CLLocation
    var time: Date
    
    init(point: CLLocation, time: Date) {
        self.point = point
        self.time = time
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

class Drive: Object {
    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var isDeleted = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
        
    
    @objc dynamic var path: [DrivePoint] = [DrivePoint]()
    @objc dynamic var fuelUsed = Measurement(value: 0, unit: UnitVolume.gallons)

    var startCoordinateHumanReadableName: String?
    var endCoordinateHumanReadableName: String?
    
    
    var startPoint: DrivePoint? {
        get {
            return self.path.first
        }
    }
    
    var endPoint: DrivePoint? {
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
            for i in 1..<self.path.count {
                total += self.path[i-1].point.distance(from: self.path[i-1].point)
            }
            return Measurement(value: total, unit: UnitLength.meters)
        }
    }
    
    var duration: TimeInterval {
        get {
            guard self.path.count >= 2 else {
                return 0
            }
            return self.path.last!.time.timeIntervalSince(self.path.first!.time)
        }
    }
    
//    var fuelEfficiency: Measurement<UnitFuelEfficiency> {
//        get {
//            return Measurement(value: self.distance / self.fuelUsed, unit: UnitFuelEfficiency.milesPerGallon)
//        }
//    }
}

extension Drive: CKRecordConvertible & CKRecordRecoverable {
        


}
