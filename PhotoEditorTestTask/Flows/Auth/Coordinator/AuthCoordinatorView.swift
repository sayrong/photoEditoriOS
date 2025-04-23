//
//  AuthCoordinatorView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 23.04.2025.
//

import SwiftUI

struct AuthCoordinatorView: View {

    @ObservedObject var coordinator: AuthCoordinator
   
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.view(for: .login)
                .navigationDestination(for: AuthCoordinator.Route.self) { route in
                    coordinator.view(for: route)
                }
                .sheet(item: $coordinator.presentedSheet) { route in
                    coordinator.view(for: route)
                }
        }
    }
}
