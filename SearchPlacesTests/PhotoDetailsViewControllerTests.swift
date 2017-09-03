//
//  PhotoDetailsViewControllerTests.swift
//  SearchPlaces
//
//  Created by Roshan Nagose on 03/09/17.
//  Copyright © 2017 SearchPlaces. All rights reserved.
//

import XCTest
@testable import SearchPlaces


class PhotoDetailsViewControllerTests: XCTestCase {
    
    var controllerUnderTest: PhotoDetailsViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        controllerUnderTest =  UIStoryboard(name: "Main",
                                            bundle: nil).instantiateViewController(withIdentifier: String(describing: PhotoDetailsViewController.self)) as! PhotoDetailsViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPhotoDetailsControllerViewExits(){
        
        XCTAssertNotNil(controllerUnderTest.view, "PhotoDetailsViewController should contain a view")
        
    }
}
