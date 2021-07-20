//
//  HumanReadableLocationManager.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/20/21.
//

import Foundation
import MapKit
import Cache

private let diskConfig = DiskConfig(name: "com.carduino.Carduino.HumanReadableLocationManagerCache",
                                    maxSize: 500 * 1000 * 1000, // limit on disk cache to 500mb
                                    protectionType: FileProtectionType.none
                                    )
private let memoryConfig = MemoryConfig(expiry: .never)

private let storage = try? Storage<CLLocation, String>(
  diskConfig: diskConfig,
  memoryConfig: memoryConfig,
  transformer: TransformerFactory.forCodable(ofType: String.self) // Storage<CLPlacemark, String>
)

class HumanReadableLocationManager {
    static func lookUpCurrentLocation(location: CLLocation, completionHandler: @escaping (String?)
                                        -> Void ) {
        do {
            guard let storage = storage else {
                throw NSError(domain: "Failed to get stoage", code: -1, userInfo: nil)
            }
            if try storage.existsObject(forKey: location) {
                completionHandler(try storage.object(forKey: location))
            }
        } catch let error {
            print("Failed to interact with cache due to error \(error)")
        }
        
        let geocoder = CLGeocoder()
        
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location,
                                        completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let firstLocation = placemarks?[0]
                                                completionHandler(firstLocation?.name)
                                            }
                                            else {
                                                // An error occurred during geocoding.
                                                completionHandler(nil)
                                            }
                                        })
    }
}
