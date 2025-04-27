//
//  PasswordResetView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 25.04.2025.
//

import SwiftUI

struct PasswordResetView: View {
    
    @ObservedObject var viewModel: PasswordResetViewModel
    
    init(viewModel: PasswordResetViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            headerSection()
            EmailTextFieldWithError(title: L10n.email,
                                    text: $viewModel.email,
                                    error: "Error",
                                    isValidating: .constant(true))
            resetButton()
            cancelButton()
            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Asset.Colors.background.swiftUIColor)
    }
    
    // MARK: - Components
    
    private func headerSection() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(Asset.Colors.secondaryAccent.swiftUIColor)
                .padding(.bottom, 8)
            
            Text(L10n.resetYourPassword)
                .titleText()
                .multilineTextAlignment(.center)
            
            Text(L10n.instructionsToResetPassword)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 16)
    }
    
    private func resetButton() -> some View {
        Button {
            
        } label: {
            Text(L10n.sendResetInstructions)
        }
        .primaryButtonStyle()
    }
    
    private func cancelButton() -> some View {
        Button {
            
        } label: {
            Text(L10n.cancel)
        }
        .primaryCancelButtonStyle()
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView(viewModel: .preview())
    }
}
