//
//  DrivesView.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 5/25/21.
//

import SwiftUI
import MapKit

struct DrivesView: View {
    var body: some View {
        Form {
            Section(header: Text("1/12/20")) {
                DriveRow()
                DriveRow()
            }
            
            Section(header: Text("1/13/20")) {
                DriveRow()
                DriveRow()
            }
        }
        .accentColor(.orange)
    }
}

struct DriveRow: View {
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 25.7617,
                longitude: 80.1918
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 10,
                longitudeDelta: 10
            )
        )
    
    var body: some View {
        VStack{
            HStack {
                HStack{
                    Text("12:20pm")
                        .font(.subheadline)
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.red)
                        .font(.subheadline)
                    Text("3:10pm")
                        .font(.subheadline)
                }.frame(maxWidth: .infinity)
                HStack {
                    Text("20.3 mi")
                        .font(.subheadline)
                    Text("2 hr 50 min")
                        .font(.subheadline)
                }.frame(maxWidth: .infinity)
            }
            Map(coordinateRegion: $region)
                .frame(height: 200.0)
            HStack {
                Text("1501 Ashbury Lane")
                    .font(.subheadline)
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.red)
                Text("North Allegheny Senior High School")
                    .font(.subheadline)
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
