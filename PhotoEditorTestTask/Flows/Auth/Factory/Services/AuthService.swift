//
//  AuthService.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import FirebaseAuth

protocol IAuthService {
    func isEmailValidForRegistration(_ email: String) async -> Result<Bool, Error>
}

final class FirebaseAuthService: IAuthService {
    
    // Soon deprecated
    func isEmailValidForRegistration(_ email: String) async -> Result<Bool, Error> {
        do {
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            let isValid = methods.isEmpty
            return .success(isValid)
        } catch {
            print(error.localizedDescription)
            // In case of error we block registration process
            return .failure(error)
        }
    }
}
