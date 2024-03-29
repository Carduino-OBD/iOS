//
//  FloatingPointClean.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/7/21.
//

import Foundation


extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
