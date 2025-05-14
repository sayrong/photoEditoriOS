//
//  AuthService.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 24.04.2025.
//

import FirebaseAuth
import GoogleSignIn
import FirebaseCore

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

typealias AuthStateChangeHandler = (User?) -> Void
typealias AuthStateListenerHandle = UUID

protocol IAuthService {
    func currentUser() -> User?
    func login(_ email: String, _ password: String) async -> Result<User, AuthError>
    func signInWithGoogle(presentingControllerProvider: PresentingControllerProvider) async -> Result<User, AuthError>
    func register(_ email: String, _ password: String) async -> Result<User, AuthError>
    func sendPasswordReset(withEmail email: String) async -> Result<Void, AuthError>
    func isEmailValidForRegistration(_ email: String) async -> Result<Bool, AuthError>
    func addAuthStateChangeListener(_ handler: @escaping AuthStateChangeHandler) -> AuthStateListenerHandle
    func removeAuthStateChangeListener(_ handle: AuthStateListenerHandle)
    func refreshUserToken()
}

final class FirebaseAuthService: IAuthService {
    
    private var stateChangeListeners: [AuthStateListenerHandle: AuthStateChangeHandler] = [:]
    private var firebaseListenerHandle: NSObjectProtocol?
    
    init() {
        setupFirebaseAuthListener()
    }
    
    func currentUser() -> User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(id: firebaseUser.uid, email: firebaseUser.email ?? "")
    }

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
    
    @MainActor
    func signInWithGoogle(presentingControllerProvider: PresentingControllerProvider) async -> Result<User, AuthError> {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return .failure(.unknownError(message: "clientID not found"))
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let vc = presentingControllerProvider.presentingViewController()
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: vc)
            guard let idToken = result.user.idToken?.tokenString else {
                return .failure(.unknownError(message: "idToken not found"))
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: result.user.accessToken.tokenString)
            let authData = try await Auth.auth().signIn(with: credential)
            let user = User(id: authData.user.uid, email: authData.user.email ?? "")
            return .success(user)
        } catch {
            print(error.localizedDescription)
            return .failure(mapErrorToAuthError(error))
        }
    }
    
    func sendPasswordReset(withEmail email: String) async -> Result<Void, AuthError> {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return .success(())
        } catch {
            print(error.localizedDescription)
            return .failure(mapErrorToAuthError(error))
        }
    }
    
    @discardableResult
    func addAuthStateChangeListener(_ handler: @escaping AuthStateChangeHandler) -> AuthStateListenerHandle {
        let handle = AuthStateListenerHandle()
        stateChangeListeners[handle] = handler
        return handle
    }
    
    func refreshUserToken() {
        guard let firebaseUser = Auth.auth().currentUser else {
            return
        }
        firebaseUser.getIDTokenForcingRefresh(true) { _, error in
            if let error = error {
                print("Error receiving a token: \(error.localizedDescription)")
                try? Auth.auth().signOut()
                return
            }
            print("Token successfully updated")
        }
    }
    
    func removeAuthStateChangeListener(_ handle: AuthStateListenerHandle) {
        stateChangeListeners.removeValue(forKey: handle)
    }
    
    private func setupFirebaseAuthListener() {
        firebaseListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            
            // Преобразуем Firebase User в нашу модель User
            let user = firebaseUser.map { User(id: $0.uid, email: $0.email ?? "") }
            
            // Уведомляем всех наблюдателей
            self.stateChangeListeners.values.forEach { handler in
                handler(user)
            }
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
    
    deinit {
        if let handle = firebaseListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
