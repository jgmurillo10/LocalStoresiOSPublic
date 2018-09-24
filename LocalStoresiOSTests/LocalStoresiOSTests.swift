//
//  LocalStoresiOSTests.swift
//  LocalStoresiOSTests
//
//  Created by Juan Murillo on 3/10/17.
//  Copyright © 2017 Juan Murillo. All rights reserved.
//

import XCTest
import Firebase
import SwiftKeychainWrapper

@testable import LocalStoresiOS

class LocalStoresiOSTests: XCTestCase {
    
    var loginRegisterUnderTest: LoginRegisterViewController!
    var preferencesUnderTest: PreferencesViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // setup controller instances
        loginRegisterUnderTest = LoginRegisterViewController()
        loginRegisterUnderTest.isSignIn = true
        
        preferencesUnderTest = PreferencesViewController()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    // Sign in/Register page tests
    func testSignIn() {
        let userEmail: String = "a@a.co"
        let userPassword: String = "aaaaaa"
        
        let expect = expectation(description: "User signs in successfully")
        // [START headless_email_auth]
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
            // [START_EXCLUDE]
            XCTAssertNotNil(user, "sign In failed")
            
            expect.fulfill()
        }
        // [END headless_email_auth]
        
        // Loop until the expectation is fulfilled
        waitForExpectations(timeout: 5, handler: {error in
            XCTAssertNil(error, "Error")
        })
        
    }
    
    func testRegister() {
        let userEmail: String = "abcd" + String(NSDate().timeIntervalSince1970) + "@a.co"
        let userPassword: String = "aaaaaa"
        let expect = expectation(description: "User is Registered succesfully")
        // [START create_user]
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
            // [START_EXCLUDE]
            
            XCTAssertNotNil(user, "Register Fail failed")
            
            expect.fulfill()}
        // [END create_user]
        // Loop until the expectation is fulfilled
        waitForExpectations(timeout: 5, handler: {error in
            XCTAssertNil(error, "Error")
        })
        
        
    }
    
    func testSaveInKeyChain() {
        let userEmail: String = "abcd" + String(NSDate().timeIntervalSince1970) + "@a.co"
        let userPassword: String = "aaaaaa"
        let success: Bool = loginRegisterUnderTest.saveCredentialsKeyChain(email: userEmail, password: userPassword)
        XCTAssertTrue(success, "Credentials were not saved in the keychain")
        
        
    }
    
    func testGetFromKeychain () {
        let userEmail: String = "abcd" + String(NSDate().timeIntervalSince1970) + "@a.co"
        let userPassword: String = "aaaaaa"
        loginRegisterUnderTest.saveCredentialsKeyChain(email: userEmail, password: userPassword)
        let retrievedEmail = KeychainWrapper.standard.string(forKey: "userEmail")
        
        let retrievedPassword = KeychainWrapper.standard.string(forKey: "userPassword")
        let success: Bool = retrievedEmail != nil && retrievedPassword != nil
        XCTAssertTrue(success, "Credentials were not retrieved from the keychain")

        
    }
    
    // product tests
    
    
    
    // preferences tests
    
    func testLogout () {
        testSignIn()
        let loutOutSucess: Bool = preferencesUnderTest.logOut()
         XCTAssertTrue(loutOutSucess, "Log out sucess")
        
    }
    
    // lists tests
    
    
    
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
