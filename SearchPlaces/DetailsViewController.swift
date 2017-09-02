//
//  DetailsViewController.swift
//  SearchPlaces
//
//  Created by Roshan Nagose on 02/09/17.
//  Copyright © 2017 SearchPlaces. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps

class DetailsViewController: UIViewController,CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // add map
        
        let camera = GMSCameraPosition.camera(withLatitude: (selectedPlace?.coordinate.latitude)!,
                                              longitude: (selectedPlace?.coordinate.longitude)!,
                                              zoom: zoomLevel)
        
        
        
        mapView = GMSMapView.map(withFrame: CGRect(x: Double(view.bounds.origin.x), y:64, width: Double(view.bounds.size.width), height: Double(view.bounds.size.height)*3/4), camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.consumesGesturesInView = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: (selectedPlace?.coordinate.latitude)!,
                                              longitude: (selectedPlace?.coordinate.longitude)!,
                                              zoom: zoomLevel)
        
        let position = CLLocationCoordinate2D(latitude: (selectedPlace?.coordinate.latitude)!, longitude: (selectedPlace?.coordinate.longitude)!)
        let marker = GMSMarker(position: position)
        marker.title = selectedPlace?.name
        marker.map = mapView
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
