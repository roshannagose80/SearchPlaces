//
//  SearchViewController.swift
//  SearchPlaces
//
//  Created by Roshan Nagose on 30/08/17.
//  Copyright © 2017 SearchPlaces. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import GoogleMaps
import CoreData
import UIKit
import GooglePlaces


class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    var places: [NSManagedObject] = []
    
    /// Search controller to help us with filtering.
    var searchController: UISearchController!
    
    /// Secondary search results table view.
    var resultsTableController: GMSAutocompleteResultsViewController!

    let managedContext =
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var placeTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        reloadPlacesData()
       
        self.title = "Search Places"
        resultsTableController = GMSAutocompleteResultsViewController()
        resultsTableController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = resultsTableController
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search Places"
        placeTableView.tableHeaderView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = false // default is YES
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        definesPresentationContext = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadPlacesData(){
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Place")
        
        let sort = NSSortDescriptor(key:"date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            places = try managedContext.fetch(fetchRequest)
            
            DispatchQueue.main.async {
                self.placeTableView.reloadData()
            }
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
    
}
extension SearchViewController: UISearchBarDelegate, GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        
        searchController?.isActive = false
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Place",
                                       in: managedContext)!
        
        let placeManagedObject = NSManagedObject(entity: entity,
                                                 insertInto: managedContext)
        placeManagedObject.setValue(place.name, forKeyPath: "name")
        
        placeManagedObject.setValue(place.coordinate.latitude, forKeyPath: "latitude")
        
        placeManagedObject.setValue(place.coordinate.longitude, forKeyPath: "longitude")
        
        placeManagedObject.setValue(place.placeID, forKeyPath: "placeId")
        
        placeManagedObject.setValue(NSDate(), forKeyPath: "date")

        
        if !placeIdExists(placeId:place.placeID) {
         
            do {
                
                try managedContext.save()
                self.reloadPlacesData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        let vc : DetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: DetailsViewController.self)) as! DetailsViewController
        
        
        vc.selectedPlace = placeManagedObject
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func placeIdExists (placeId:String) -> Bool {
        
        let request =
            NSFetchRequest<NSManagedObject>(entityName: "Place")
        
        let predicate = NSPredicate(format: "placeId == %@", argumentArray: [placeId])
        
        request.predicate = predicate
        
        do {
            let count = try managedContext.count(for:request)
            
            if (count <= 1) {
                return false
            }
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        return true
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension SearchViewController: UITableViewDelegate,UITableViewDataSource  {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let place = places[indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if !(cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text =
            place.value(forKeyPath: "name") as? String
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        placeTableView.deselectRow(at: indexPath, animated: false)
        
        let placeManagedObject = places[indexPath.row]

        let vc : DetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: DetailsViewController.self)) as! DetailsViewController
        
        vc.selectedPlace = placeManagedObject
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
}
