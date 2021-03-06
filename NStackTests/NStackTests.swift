//
//  NStackTests.swift
//  NStackTests
//
//  Created by Kasper Welner on 07/09/15.
//  Copyright © 2015 Nodes. All rights reserved.
//

import UIKit
import XCTest
import Serializable
import Alamofire
@testable import NStack

class NStackTests: XCTestCase {

    let configuration: Configuration = {
        var conf = Configuration(plistName: "NStack", translationsClass: Translations.self)
        conf.verboseMode = true
        conf.updateAutomaticallyOnStart = false
        NStack.start(configuration: conf)
        return conf
    }()

    override func setUp() {
        super.setUp()

    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUpdate() {
        let expectation = expectationWithDescription("testOpen")

        NStackConnectionManager.doAppOpenCall(oldVersion: "1.0", currentVersion: "1.0") { (response) -> Void in
            switch response.result {
            case .Success(_):
                expectation.fulfill()
            case .Failure(let error):
                XCTAssert(false, "App open call failed - \(error.localizedDescription)")
                XCTAssertNil(error, "Error: \(error)")
            }
        }

        waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testTranslations() {

        TranslationManager.sharedInstance.lastFetchedLanguage = nil
        TranslationManager.sharedInstance.languageOverride = Language(id: 11, name: "English (UK)", locale: "en-GB", direction: "LRM", data: NSDictionary())

        XCTAssertEqual(tr.defaultSection.successKey, "Success", "defaultSection.successKey does not have expected content in fallback!")

        let expectation = expectationWithDescription("testFetchTranslations")
        
        TranslationManager.sharedInstance.fetchAvailableLanguages { (response) -> Void in
            switch response.result {
            case .Success(let languages):
                XCTAssert(languages.count > 0, "No languages available")
                guard let secondLang = languages.last else { return }
                TranslationManager.sharedInstance.languageOverride = secondLang
                TranslationManager.sharedInstance.updateTranslations { (error) -> Void in
                    XCTAssertEqual(tr.defaultSection.successKey,
                        "DET VAR EN SUCCESS",
                        "defaultSection.successKey does not have expected content in response from API!")
                    expectation.fulfill()
                }

            case .Failure(let error):
                XCTAssert(false, "Fetching languages failed - \(error.localizedDescription)")
            }
        }
        waitForExpectationsWithTimeout(15, handler: nil)
    }
    
    func testVersionUtils() {
        XCTAssertTrue(NStackVersionUtils.isVersion("1.0.1", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1 ", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1.  ", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("2.0", greaterThanVersion: "1.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("2.0.0", greaterThanVersion: "1.0"))
        
        XCTAssertTrue(NStackVersionUtils.isVersion("1.0.1", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1 ", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("1.1.  ", greaterThanVersion: "1.0.0"))
        XCTAssertTrue(NStackVersionUtils.isVersion("2.0", greaterThanVersion: "1.1.2.1"))
        XCTAssertTrue(NStackVersionUtils.isVersion("2.0.0", greaterThanVersion: "1.9.11111"))
        
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0", greaterThanVersion: "1.0.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0 ", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.  ", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0", greaterThanVersion: "2.0"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0", greaterThanVersion: "2.0.0"))
        
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.0", greaterThanVersion: "1.0.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.0", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.0.0.  ", greaterThanVersion: "1.1"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.1.2.1", greaterThanVersion: "2.0"))
        XCTAssertFalse(NStackVersionUtils.isVersion("1.9.11111", greaterThanVersion: "2.0.0"))
    }
}
