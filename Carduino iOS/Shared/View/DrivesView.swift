//
//  DrivesView.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 5/25/21.
//

import Foundation
import SwiftUI
import MapKit


struct DrivesView: View {
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    
    var body: some View {
        let dict = DriveManager.getDateMappedDrives()
        
        Form {
            ForEach(Array(dict.keys), id: \.self) { date in
                let headerText = dateFormatter.string(from: date)
                let drives = dict[date]!
                Section(header: Text(headerText)) {
                    ForEach(drives) { drive in
                        DriveRow(drive: drive)
                    }
                }
            }
            
        }
        .navigationBarTitle(Text("Drives"))
        .accentColor(.orange)
    }
}

struct DriveRow: View {
    var drive: DriveV1
    
    func lookUpCurrentLocation(location: CLLocation, completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        let geocoder = CLGeocoder()
            
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(location,
                    completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
             // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    var timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.locale = Locale.current
        formatter.unitStyle = .medium
        return formatter
    }()
    
    let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter
    }()
    
    @State var startLocationName: String = "..."
    @State var endLocationName: String = "..."
    

    var body: some View {
        
        VStack{
            HStack {
                HStack{
                    let startTime = timeFormatter.string(from: drive.path.first!.date)
                    let endTime = timeFormatter.string(from: drive.path.last!.date)
                    Text(startTime)
                        .font(.subheadline)
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.red)
                        .font(.subheadline)
                    Text(endTime)
                        .font(.subheadline)
                }.frame(maxWidth: .infinity)
                HStack {
                    Text(measurementFormatter.string(from: drive.distance))
                        .font(.subheadline)
                    Text(relativeDateFormatter.localizedString(fromTimeInterval: drive.duration))
                        .font(.subheadline)
                }.frame(maxWidth: .infinity)
            }
            MapView(route: drive.mkPolyline)
                .frame(height: 200.0)
            VStack {
                Text(startLocationName)
                    .font(.subheadline)
                    .onAppear {
                        lookUpCurrentLocation(location: self.drive.points.first!) { [self] placemark in
                            if let placemark = placemark?.name {
                                DispatchQueue.main.async {
                                    self.startLocationName = placemark
                                }
                            }
                        }
                    }
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.red)
                Text(endLocationName)
                    .font(.subheadline)
                    .onAppear {
                        lookUpCurrentLocation(location: self.drive.points.last!) { [self] placemark in
                            if let placemark = placemark?.name {
                                DispatchQueue.main.async {
                                    self.endLocationName = placemark
                                }
                            }
                        }
                    }
            }
            
        }
        .padding(.vertical, 20)
        
    }
}

struct DrivesView_Previews: PreviewProvider {
    static var previews: some View {
        DrivesView()
    }
}
