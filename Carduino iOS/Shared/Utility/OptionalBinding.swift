//
//  OptionalBinding.swift
//  Carduino iOS
//
//  Created by Alex Taffe on 7/6/21.
//

import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
