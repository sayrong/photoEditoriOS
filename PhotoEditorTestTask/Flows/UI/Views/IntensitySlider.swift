//
//  IntensitySlider.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 14.05.2025.
//

import SwiftUI

struct IntensitySlider: View {
    
    @State var sliderValue: CGFloat = 0
    @Binding var filter: FilterType?

    var body: some View {
        Slider(value: $sliderValue, in: 0.0...1.0, onEditingChanged: { editing in
            if !editing {
                filter = .sepia(sliderValue)
            }
        })
        .onAppear {
            if case .sepia(let value) = filter {
                sliderValue = value
            }
        }
    }
}
