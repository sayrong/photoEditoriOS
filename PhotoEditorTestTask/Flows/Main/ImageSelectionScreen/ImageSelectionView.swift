//
//  ImageSelectionView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI

struct ImageSelectionView: View {
    
    @ObservedObject private var viewModel: ImageSelectionViewModel
    
    init(viewModel: ImageSelectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 34) {
            Spacer()
            headerSection()
            controlSection()
            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Asset.Colors.background.swiftUIColor)
    }
    
    private func headerSection() -> some View {
        VStack {
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)

            Text(L10n.selectAnImageToStartEditing)
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private func controlSection() -> some View {
        VStack(spacing: 24) {
            Button {
                viewModel.fromLibraryDidTap()
            } label: {
                WideButtonText(L10n.selectPhoto)
            }
            .primaryButtonStyle()
            
            Button {
                viewModel.fromCameraDidTap()
            } label: {
                WideButtonText(L10n.takeAPhoto)
            }
            .secondaryButtonStyle()
        }
    }
}

#Preview {
    ImageSelectionView(viewModel: ImageSelectionViewModel())
}
