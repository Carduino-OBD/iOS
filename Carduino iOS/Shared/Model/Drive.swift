//
//  Drive.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/5/21.
//

import Foundation

enum DriveParseError: Error {
    case unknownVersion(message: String),
         invalidDriveFrameSize,
         mismatchedPolylineFrameCount,
         polylineInvalid,
         packetSizeInvalid
}

protocol Drive {
    
}

class DriveParser {
    static func getDrive(data: Data) throws -> Drive {
        let versionNumber = data.subdata(in: 0..<2).withUnsafeBytes({ $0.load(as: UInt16.self) }).littleEndian
        switch versionNumber {
        case 1:
            return try DriveV1(data: data)
        default:
            throw DriveParseError.unknownVersion(message: "Unknown drive version \(versionNumber), please try updating your app")
        }
    }
}
