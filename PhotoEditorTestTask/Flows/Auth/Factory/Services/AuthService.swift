//
//  AuthService.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import FirebaseAuth

enum AuthError: Error {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case unknownError(message: String)
    
    var userMessage: String {
        switch self {
        case .invalidCredentials:
            return L10n.invalidEmailOrPassword
        case .emailAlreadyInUse:
            return L10n.thisEmailIsAlreadyRegistered
        case .weakPassword:
            return L10n.thePasswordIsTooSimple
        case .networkError:
            return L10n.checkYourInternetConnection
        case .unknownError(let message):
            return L10n.errorOccurred(message)
        }
    }
}

protocol IAuthService {
    func isEmailValidForRegistration(_ email: String) async -> Result<Bool, AuthError>
    func register(_ email: String, _ password: String) async -> Result<User, AuthError>
    func login(_ email: String, _ password: String) async -> Result<User, AuthError>
}

final class FirebaseAuthService: IAuthService {
    
    // Soon deprecated
    func isEmailValidForRegistration(_ email: String) async -> Result<Bool, AuthError> {
        do {
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            let isValid = methods.isEmpty
            return .success(isValid)
        } catch {
            print(error.localizedDescription)
            // In case of error we block registration process
            return .failure(mapErrorToAuthError(error))
        }
    }
    
    func register(_ email: String, _ password: String) async -> Result<User, AuthError> {
        do {
            let authData = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = User(id: authData.user.uid, email: authData.user.email ?? "")
            return .success(user)
        } catch {
            print(error.localizedDescription)
            return .failure(mapErrorToAuthError(error))
        }
    }
    
    func login(_ email: String, _ password: String) async -> Result<User, AuthError> {
        do {
            let authData = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = User(id: authData.user.uid, email: authData.user.email ?? "")
            return .success(user)
        } catch {
            print(error.localizedDescription)
            return .failure(mapErrorToAuthError(error))
        }
    }
    
    private func mapErrorToAuthError(_ error: any Error) -> AuthError {
        let error = error as NSError
        guard error.domain == AuthErrors.domain else {
            return AuthError.unknownError(message: error.localizedDescription)
        }
        switch error.code {
        case AuthErrorCode.invalidEmail.rawValue, AuthErrorCode.wrongPassword.rawValue:
            return AuthError.invalidCredentials
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return AuthError.emailAlreadyInUse
        case AuthErrorCode.weakPassword.rawValue:
            return AuthError.weakPassword
        case AuthErrorCode.networkError.rawValue:
            return AuthError.networkError
        default:
            return AuthError.unknownError(message: error.localizedDescription)
        }
    }
}
