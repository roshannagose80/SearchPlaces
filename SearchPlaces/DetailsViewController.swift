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
import CoreData

class DetailsViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: NSManagedObject?
    
    var photoScrollView:UIScrollView!
    var photoCollectionView:UICollectionView!
    
    var photoItems:NSMutableArray!
    
    var fullImageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        titleLabel.text = selectedPlace?.value(forKeyPath: "name") as? String
        
        self.photoItems = NSMutableArray()
        
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // add map
        let camera = GMSCameraPosition.camera(withLatitude: (selectedPlace?.value(forKeyPath: "latitude") as? Double)!,
                                              longitude: (selectedPlace?.value(forKeyPath: "longitude") as? Double)!,
                                              zoom: zoomLevel)
        
        
        
        mapView = GMSMapView.map(withFrame: CGRect(x: Double(view.bounds.origin.x), y:64, width: Double(view.bounds.size.width), height: Double(view.bounds.size.height)*3/4-64), camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.consumesGesturesInView = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        
        //mapView.isHidden = true
        
        photoScrollView = UIScrollView(frame: CGRect(x: Double(view.bounds.origin.x), y:Double(mapView.frame.origin.y + mapView.frame.size.height), width: Double(view.bounds.size.width), height: Double(view.bounds.size.height)*1/4))
        photoScrollView.contentSize = CGSize(width: photoScrollView.frame.size.width, height: photoScrollView.frame.size.height)
        
        photoScrollView.backgroundColor = UIColor.red
        view.addSubview(photoScrollView)
        
        
        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width:150, height: photoScrollView.frame.size.height)
        
        photoCollectionView = UICollectionView(frame: CGRect(x:0, y:0, width: photoScrollView.frame.size.width, height: photoScrollView.frame.size.height), collectionViewLayout: flowLayout)
        
        photoCollectionView.backgroundColor = UIColor.white
        photoCollectionView.showsVerticalScrollIndicator = false
        photoCollectionView.showsHorizontalScrollIndicator = false
        photoScrollView.addSubview(photoCollectionView)
        
        photoCollectionView.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        photoScrollView.isScrollEnabled = false;
        
        loadAllPhotoForPlace(placeID: (selectedPlace?.value(forKeyPath: "placeId") as? String)!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: (selectedPlace?.value(forKeyPath: "latitude") as? Double)!,
                                              longitude: (selectedPlace?.value(forKeyPath: "longitude") as? Double)!,
                                              zoom: zoomLevel)
        
        let position = CLLocationCoordinate2D(latitude: (selectedPlace?.value(forKeyPath: "latitude") as? Double)!, longitude: (selectedPlace?.value(forKeyPath: "longitude") as? Double)!)
        let marker = GMSMarker(position: position)
        marker.title = selectedPlace?.value(forKeyPath: "name") as? String
        marker.map = mapView
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
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
    
    func loadAllPhotoForPlace(placeID: String) {
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                
                // use DispatchGroup for fetch all photos
                
                let group = DispatchGroup()
                
                photos?.results.forEach({ (metaData) in
                    group.enter()
                    GMSPlacesClient.shared().loadPlacePhoto(metaData, callback: {
                        (photo, error) -> Void in
                        if let error = error {
                            
                            // TODO: handle the error.
                            print("Error: \(error.localizedDescription)")
                        } else {
                            
                            self.photoItems.add(photo ?? UIImage())
                        }
                        
                        group.leave()
                    })
                })
                
                // notify when all task finished
                group.notify(queue: DispatchQueue.global(qos: .background)) {
                    
                    // load all photos
                    DispatchQueue.main.async {
                        self.photoCollectionView.reloadData()
                    }
                }
                
                
            }
        }
    }
    
}

extension DetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
      
        if let image = self.photoItems.object(at: indexPath.row) as? UIImage{
            
            cell.locationImageView.image = image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        
        if let image = cell.locationImageView.image {
            
            let vc : PhotoDetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: PhotoDetailsViewController.self)) as! PhotoDetailsViewController
            vc.selectedImage = image
            
            self.present(vc, animated: true, completion: nil)
            
        } else {
            print("no photo")
        }
    }
    
}
