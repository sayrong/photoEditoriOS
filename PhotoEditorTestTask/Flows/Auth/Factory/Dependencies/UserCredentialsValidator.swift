//
//  UserCredentialsValidator.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 23.04.2025.
//

import Foundation

protocol IUserCredentialsValidator {
    func isValidEmail(_ email: String) -> Bool
    func isValidPassword(_ password: String) -> Bool
}

struct UserCredentialsValidator: IUserCredentialsValidator {
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx =
        "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}
