//
//  PixabayJsonParserTests.swift
//  Tests
//
//  Created by Артур Гнедой on 30.11.2020.
//  Copyright © 2020 Артур Гнедой. All rights reserved.
//

@testable import t_chat

import XCTest

class PixabayJsonParserTests: XCTestCase {
    
    func testShouldReturnResultWithError_If_ResponseHasNoImageData() {
        let testJSON: [String: Any] = [ "totalHits": 0, "total": 0 ]
        guard let data = try? JSONSerialization.data(withJSONObject: testJSON, options: .prettyPrinted) else {
            return
        }
        
        let sut = PixabayParser()
        let result = sut.photoList(from: data)
        
        switch result {
        case .failure(let error):
            XCTAssertTrue(error is JsonParseError)
        default:
            XCTFail("Test should fail")
        }
        
        XCTAssertThrowsError(try result.get())
    }
    
    func testShouldReturnResultWithImageData_If_ResponseHasImages() {
        let testJSON: [String: Any] = [
            "hits": [
                [
                    "previewURL": "https://cdn.pixabay.com/photo/2013/10/15/09/12/flower-195893_150.jpg",
                    "largeImageURL": "https://pixabay.com/get/ed6a99fd0a76647_1280.jpg"
                ]
            ]
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: testJSON, options: .prettyPrinted) else {
            return
        }
        
        let sut = PixabayParser()
        let result = sut.photoList(from: data)
        
        switch result {
        case .success(let photos):
            XCTAssertEqual(photos.count, 1)
        default:
            XCTFail("No Images provided")
        }
    }

}
