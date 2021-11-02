//
//  DriveView.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import SwiftUI
import MapKit

struct DriveGridItemView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            content
                .frame(minWidth: 150, minHeight: 150)
//                .padding(40)
        }
        
    }
}

struct DriveView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var presentedAsModal: Bool
    
    var drive: DriveV1
    
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
        NavigationView {
            ScrollView(.vertical){
                VStack{
                    //                VStack {
                    //                    HStack{
                    //                        let startTime = timeFormatter.string(from: drive.path.first!.date)
                    //                        let endTime = timeFormatter.string(from: drive.path.last!.date)
                    //                        Text(startTime)
                    //                            .font(.subheadline)
                    //                        Image(systemName: "arrow.right.circle.fill")
                    //                            .foregroundColor(.red)
                    //                            .font(.subheadline)
                    //                        Text(endTime)
                    //                            .font(.subheadline)
                    //                    }.frame(maxWidth: .infinity)
                    //                    HStack {
                    //                        Text(measurementFormatter.string(from: drive.distance))
                    //                            .font(.subheadline)
                    //                        Text(relativeDateFormatter.localizedString(fromTimeInterval: drive.duration))
                    //                            .font(.subheadline)
                    //                        Text(measurementFormatter.string(from: drive.fuelEfficiency))
                    //                            .font(.subheadline)
                    //                    }.frame(maxWidth: .infinity)
                    //                }
                    MapView(route: drive.mkPolyline)
                        .frame(height: 300.0)
                    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
                    LazyVGrid(columns: columns) {
                        DriveGridItemView {
                            Text("Test 1")
                        }
                        DriveGridItemView {
                            Text("Test 2")
                        }
                        DriveGridItemView {
                            Text("Test 3")
                        }
                        DriveGridItemView {
                            Text("Test 4")
                        }
                    }
//                    VStack {
//                        Text(startLocationName)
//                            .font(.subheadline)
//                            .onAppear {
//                                HumanReadableLocationManager.lookUpCurrentLocation(location: self.drive.points.first!) { [self] placemark in
//                                    if let placemark = placemark {
//                                        DispatchQueue.main.async {
//                                            self.startLocationName = placemark
//                                        }
//                                    }
//                                }
//                            }
//                        Image(systemName: "arrow.down.circle.fill")
//                            .foregroundColor(.red)
//                        Text(endLocationName)
//                            .font(.subheadline)
//                            .onAppear {
//                                HumanReadableLocationManager.lookUpCurrentLocation(location: self.drive.points.last!) { [self] placemark in
//                                    if let placemark = placemark {
//                                        DispatchQueue.main.async {
//                                            self.endLocationName = placemark
//                                        }
//                                    }
//                                }
//                            }
//                    }
//
                }
                .navigationBarItems(trailing: Button(action: {
                    print("Dismissing sheet view...")
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done").bold()
                })
            }
        }
        
    }
    
    init(presentedAsModal modalVal: Binding<Bool> = .constant(true), drive: DriveV1) {
        _presentedAsModal = modalVal
        self.drive = drive
    }
}

struct DriveView_Previews: PreviewProvider {
    static let exampleDriveString = "AQAxOVVVQjNGNjhLQTAwMDk0OGSEAAAAZAMAAF9vY3NGfn5nZ04/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/P11z5GBdc+RgAAAAsgAAZHPkYGRz5GADjgAnAQBrc+Rga3PkYAIAADEBAHNz5GBzc+RgAAAAMQEAenPkYHpz5GAAAAAxAQCBc+RggXPkYAEAAD4BAIlz5GCJc+RgAAAASAEBkHPkYJBz5GABAABNAQKXc+Rgl3PkYAZaAU8BF55z5GCec+RgAAAAVgEDpnPkYKZz5GAKLgFYAQutc+RgrXPkYA03AFcBKrRz5GC0c+RgAAAAVgE7vHPkYLxz5GAAAABYATzDc+Rgw3PkYBtvAFoBOcpz5GDKc+RgAAAAWQEs0XPkYNFz5GAcbQBNAQrZc+Rg2XPkYA5tAE0BCeBz5GDgc+RgH+AAUwEk53PkYOdz5GAAAABXATvuc+Rg7nPkYAAAAFoBPfZz5GD2c+RgNvkAWgE3/XPkYP1z5GA38gBkATsEdORgBHTkYDrnAG8BOQx05GAMdORgAAAAcQErE3TkYBN05GAp4QBwATkadORgGnTkYDHRAHQBOSF05GAhdORgNL0AbgE0KXTkYCl05GAAAABsATMwdORgMHTkYC6mAGwBLzd05GA3dORgLtIAagE3P3TkYD905GAAAABqATZGdORgRnTkYCDwAGMBHk105GBNdORgBv0AYwELVHTkYFR05GALIQFsASJcdORgXHTkYCVEAWsBQGN05GBjdORgQUcBaAFEanTkYGp05GBDTgFmAURxdORgcXTkYEFRAWgBP3l05GB5dORgNEMBaQEigHTkYIB05GASSQFoAReHdORgh3TkYC0EAGwBPo905GCPdORgP2QBbwFBlnTkYJZ05GBAZQFwAT6ddORgnXTkYD8OAHQBPaR05GCkdORgAAAAdgFArHTkYKx05GAAAAB2AUSzdORgs3TkYAAAAHYBP7p05GC6dORgO0QAeQFCwnTkYMJ05GA+VgBvAT3JdORgyXTkYDtYAG4BOdB05GDQdORgAAAAbQEN13TkYNd05GAIeABvASTfdORg33TkYB5OAXEBPeZ05GDmdORgJFMBcgET7XTkYO105GAhOAB0ASf0dORg9HTkYCpJAHQBK/x05GD8dORgKlYAdAEqA3XkYAN15GAlYABzASEKdeRgCnXkYBRoAHMBEBJ15GASdeRgC0UAdQENGXXkYBl15GADcgB1AQAyCg=="
    
    static var previews: some View {
        let driveData = Data(base64Encoded: exampleDriveString)!
        let drive = try? DriveV1(data: driveData)
        DriveView(drive: drive!)
    }
}
