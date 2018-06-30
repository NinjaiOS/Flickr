//
//  FlickrImageTests.swift
//  FlickrTests
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import XCTest
@testable import Flickr

class FlickrImageTests: XCTestCase {
    
    // MARK: - Properties
    
    var flickrImage: FlickrImage!
    var url: URL!
    
    // MARK: - Methods
    
    override func setUp() {
        super.setUp()
        flickrImage = FlickrImage(id: "29051950268", farm: 2, server: "1786", secret: "cdbc19e42f", title: "Greg Parrot Pic")
    }
    
    override func tearDown() {
        flickrImage = nil
        url = nil
        super.tearDown()
    }
    
    func testFlicrkImageURLshouldNotBeNil() {
        url = flickrImage.flickrImageURL()
        XCTAssertNotNil(url, "Method: flickrImageURL() should return a URL")
    }
    
    func testShouldLoadImage() {
        // given
        let promise = expectation(description: "Completion handler invoked")
        var responseError: Error?
        
        // when
        flickrImage.loadLargeImage { (image, error) in
            responseError = error
            promise.fulfill()
        }
        // then
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssertNil(responseError)
        XCTAssertNotNil(flickrImage?.thumbnail)
    }
}
