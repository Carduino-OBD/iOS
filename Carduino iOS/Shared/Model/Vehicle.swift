//
//  Vehicle.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import Foundation

struct Vehicle: Codable {
    var vin: String
    var nickname: String?
    var fuelTankSize: Measurement<UnitVolume>?
}
