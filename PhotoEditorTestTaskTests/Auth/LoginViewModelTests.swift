//
//  LoginViewModelTests.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 17.05.2025.
//

import XCTest
@testable import PhotoEditorTestTask

final class LoginViewModelTests: XCTestCase {
    
    var validator: MockValidator!
    var auth: MockAuthService!
    var delegate: MockDelegate!
    var vm: LoginViewModel!

    override func setUp() {
        super.setUp()
        validator = MockValidator()
        auth = MockAuthService()
        delegate = MockDelegate()
        vm = LoginViewModel(delegate: delegate, validator: validator, authService: auth)
    }
    
    func testValidationLogicValid() {
        validator.emailValid = true
        validator.passwordValid = true
        vm.email = "test@example.com"
        vm.password = "password"
        XCTAssertTrue(vm.canSubmitForm)
        XCTAssertTrue(vm.isEmailFieldCorrect)
        XCTAssertTrue(vm.isPasswordFieldCorrect)
    }
    
    func testValidationLogicInvalid() {
        validator.emailValid = false
        validator.passwordValid = false
        XCTAssertFalse(vm.canSubmitForm)
        XCTAssertFalse(vm.isEmailFieldCorrect)
        XCTAssertFalse(vm.isPasswordFieldCorrect)
    }
    
    func testLoginSuccess() async {
        auth.loginResult = .success(.init(id: "", email: ""))
        vm.email = "test@example.com"
        vm.password = "password"
        
        let exp = expectation(description: "Login completes")
        delegate.didCompleteHandler = {
            exp.fulfill()
        }
        
        vm.logInDidTap()
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(delegate.didComplete)
        XCTAssertNil(delegate.didFail)
    }
    
    func testLoginFailure() async {
        let error = AuthError.invalidCredentials
        auth.loginResult = .failure(error)
        vm.email = "test@example.com"
        vm.password = "password"
        
        let exp = expectation(description: "Login fails")
        delegate.didFailHandler = { _ in
            exp.fulfill()
        }
        
        vm.logInDidTap()
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertFalse(delegate.didComplete)
        XCTAssertNotNil(delegate.didFail)
        XCTAssertEqual(delegate.didFail?.message, error.userMessage)
    }
    
    func testForgotPassword() {
        vm.forgotPwdDidTap()
        XCTAssertTrue(delegate.didRequestForgot)
    }
    
    func testRegistration() {
        vm.registrationDidTap()
        XCTAssertTrue(delegate.didRequestRegistration)
    }
}
