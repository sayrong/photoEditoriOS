//
//  MainCoordinatorView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI

struct MainCoordinatorView: View {

    @ObservedObject var coordinator: MainCoordinator
   
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.view(for: .selection)
                .navigationDestination(for: MainCoordinator.Route.self) { route in
                    coordinator.view(for: route)
                }
                .sheet(item: $coordinator.presentedSheet) { route in
                    coordinator.view(for: route)
                        .presentationDetents([.large])
                        .presentationBackground(alignment: .bottom) {
                            Asset.Colors.background.swiftUIColor
                        }
                }
                .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
                    coordinator.view(for: route)
                    
                }
        }
    }
}
