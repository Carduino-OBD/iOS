//
//  DriveView.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import SwiftUI
import MapKit

struct DriveView: View {
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
    
    @Binding var presentedAsModal: Bool
    
    @Binding var drive: DriveV1
    
    
    var body: some View {
        VStack {
            MapView(route: drive.mkPolyline)
            Button("dismiss") { self.presentedAsModal = false }
        }
    }
    
    init(presentedAsModal modalVal: Binding<Bool> = .constant(true), drive: Binding<DriveV1>) {
        _presentedAsModal = modalVal
        _drive = drive
    }
}

//struct DriveView_Previews: PreviewProvider {
//    static let exampleDriveString = "AQAxOVVVQjNGNjhLQTAwMDk0OGSEAAAAZAMAAF9vY3NGfn5nZ04/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/P11z5GBdc+RgAAAAsgAAZHPkYGRz5GADjgAnAQBrc+Rga3PkYAIAADEBAHNz5GBzc+RgAAAAMQEAenPkYHpz5GAAAAAxAQCBc+RggXPkYAEAAD4BAIlz5GCJc+RgAAAASAEBkHPkYJBz5GABAABNAQKXc+Rgl3PkYAZaAU8BF55z5GCec+RgAAAAVgEDpnPkYKZz5GAKLgFYAQutc+RgrXPkYA03AFcBKrRz5GC0c+RgAAAAVgE7vHPkYLxz5GAAAABYATzDc+Rgw3PkYBtvAFoBOcpz5GDKc+RgAAAAWQEs0XPkYNFz5GAcbQBNAQrZc+Rg2XPkYA5tAE0BCeBz5GDgc+RgH+AAUwEk53PkYOdz5GAAAABXATvuc+Rg7nPkYAAAAFoBPfZz5GD2c+RgNvkAWgE3/XPkYP1z5GA38gBkATsEdORgBHTkYDrnAG8BOQx05GAMdORgAAAAcQErE3TkYBN05GAp4QBwATkadORgGnTkYDHRAHQBOSF05GAhdORgNL0AbgE0KXTkYCl05GAAAABsATMwdORgMHTkYC6mAGwBLzd05GA3dORgLtIAagE3P3TkYD905GAAAABqATZGdORgRnTkYCDwAGMBHk105GBNdORgBv0AYwELVHTkYFR05GALIQFsASJcdORgXHTkYCVEAWsBQGN05GBjdORgQUcBaAFEanTkYGp05GBDTgFmAURxdORgcXTkYEFRAWgBP3l05GB5dORgNEMBaQEigHTkYIB05GASSQFoAReHdORgh3TkYC0EAGwBPo905GCPdORgP2QBbwFBlnTkYJZ05GBAZQFwAT6ddORgnXTkYD8OAHQBPaR05GCkdORgAAAAdgFArHTkYKx05GAAAAB2AUSzdORgs3TkYAAAAHYBP7p05GC6dORgO0QAeQFCwnTkYMJ05GA+VgBvAT3JdORgyXTkYDtYAG4BOdB05GDQdORgAAAAbQEN13TkYNd05GAIeABvASTfdORg33TkYB5OAXEBPeZ05GDmdORgJFMBcgET7XTkYO105GAhOAB0ASf0dORg9HTkYCpJAHQBK/x05GD8dORgKlYAdAEqA3XkYAN15GAlYABzASEKdeRgCnXkYBRoAHMBEBJ15GASdeRgC0UAdQENGXXkYBl15GADcgB1AQAyCg=="
//    
//    static var previews: some View {
//        let driveData = Data(base64Encoded: exampleDriveString)!
//        let drive = try? DriveV1(data: driveData)
//        DriveView(drive: Binding(drive)!)
//    }
//}
