//
//  SearchViewControllerTests.swift
//  SearchPlaces
//
//  Created by Roshan Nagose on 03/09/17.
//  Copyright © 2017 SearchPlaces. All rights reserved.
//

import XCTest
@testable import SearchPlaces

class SearchViewControllerTests: XCTestCase {
    
    var controllerUnderTest: SearchViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
       controllerUnderTest =  UIStoryboard(name: "Main",
                     bundle: nil).instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as! SearchViewController
    
    }
    
    override func tearDown() {
        controllerUnderTest = nil
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
    
    func testSearchControllerViewExits(){
        
        XCTAssertNotNil(controllerUnderTest.view, "SearchViewController should contain a view")

    }
    
    func testManagedObjectContextExists(){
        
        XCTAssertNotNil(controllerUnderTest.managedContext, "ManagedObjectContext Should not nil")
        
    }
    
    func testPlaceTableViewExists(){
        
        XCTAssertNotNil(controllerUnderTest.placeTableView, "PlaceTableView Should not nil")
        
    }
    
    func testPlacesArrayNotNil(){
        
        XCTAssertNotNil(controllerUnderTest.places, "PlacesArray Should not nil")
        
    }
    
}
