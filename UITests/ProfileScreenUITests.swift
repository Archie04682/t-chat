//
//  UITests.swift
//  UITests
//
//  Created by Артур Гнедой on 30.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

@testable import t_chat
import XCTest

class ProfileScreenUITests: XCTestCase {

    func testShouldEnableUserTextFieldsOnEditModeToggle() throws {
        let app = XCUIApplication()
        
        app.launchEnvironment = ["screenToLaunch": "profile"]
        app.launch()
        
        let usernameTextField = app.textFields["usernameTextField"]
        let aboutUserTextView = app.textViews["aboutUserTextView"]
        
        XCTAssertFalse(usernameTextField.exists)
        XCTAssertFalse(aboutUserTextView.exists)
        
        let editButton = app.buttons["toggleEditModeButton"]
        editButton.tap()
        
        XCTAssertTrue(usernameTextField.isHittable)
        XCTAssertTrue(aboutUserTextView.isHittable)
    }
}
