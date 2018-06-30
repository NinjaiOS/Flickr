//
//  FlickrManagerTests.swift
//  FlickrTests
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import XCTest
@testable import Flickr

class FlickrManagerTests: XCTestCase {
    
    // MARK: - Properties
    
    var sessionUnderTest: URLSession!
    var flickrManager: FlickrManager!
    var url: URL!
    
    // MARK: - Methods
    
    override func setUp() {
        super.setUp()
        flickrManager = FlickrManager()
        sessionUnderTest = URLSession(configuration: .default)
        url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrAPIKey)&text=dogs&per_page=20&format=json&nojsoncallback=1")
    }
    
    override func tearDown() {
        flickrManager = nil
        sessionUnderTest = nil
        url = nil
        super.tearDown()
    }
    
    func testValidCallToGetHTTPStatusCode200() {
        
        let promise = expectation(description: "Status code: 200")
        //when
        sessionUnderTest.dataTask(with: url!) { (data, response, error) in
            // then
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            }
            
            guard let status = response as? HTTPURLResponse, status.statusCode == 200 else {
                XCTFail("Status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            promise.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCallNetworkRequestsHandler() {
        // given
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        sessionUnderTest.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            
            promise.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
    
    func testReceivedItemsCountShouldBeTheSameEachTime() {
        // API should return us 20 items per request.
        let term = "cat"
        let promise = expectation(description: "API should return 20 items")
        
        flickrManager.makeARequestForImages(with: term) { (items, error) in
            XCTAssertNotNil(items)
            XCTAssertTrue(items?.count == 20, "API should return always 20 items")
            promise.fulfill()
        }
        // ideally it should have been 5 sec max, and yeah I know it sucks waiting 20 sec
        waitForExpectations(timeout: 20, handler: nil)
    }
    
}
