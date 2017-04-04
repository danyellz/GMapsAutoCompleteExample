//
//  ViewController.swift
//  MapsPlacesExample
//
//  Created by TY on 4/9/16.
//  Copyright © 2016 Ty Daniels Dev. All rights reserved.
//

import UIKit
import CoreLocation
import Stevia
import GoogleMaps

class MainMapViewController: UIViewController, UISearchBarDelegate, LocateOnTheMap {
    /**
     * Called when an autocomplete request returns an error.
     * @param error the error that was received.
     */
    let cllocationManager = CLLocationManager()

    var mapViewContainer = UIView()
    var googleMaps = GMSMapView()
    
    var searchBtn = UIBarButtonItem()
    var resultText = UILabel()
    var searchResultsTable: SearchResultsTableController!
    var resultsArray = [GooglePlace]() {
        didSet {
            searchResultsTable.reloadDataWithArray(resultsArray)
        }
    }
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Request location authorization
        self.cllocationManager.requestAlwaysAuthorization()
        self.cllocationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            cllocationManager.desiredAccuracy = kCLLocationAccuracyBest
            cllocationManager.startUpdatingLocation()
            self.searchBtn.tintColor = UIColor.clear
        }
        
        searchResultsTable = SearchResultsTableController()
        searchResultsTable.delegate = self
        
        setupView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Begin search bar button animation
        DispatchQueue.main.async(execute: {
            self.performBlinkAnimation()
        })
    }
    
    fileprivate func setupView() {
        view.sv(googleMaps)
        view.layout(
            0,
            |googleMaps| ~ view.frame.height
        )
        
        navigationItem.title = "PlaceSearch"
        view.backgroundColor = UIColor.lightGray
        
        searchBtn = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(triggerSearch))
        self.navigationItem.rightBarButtonItem = searchBtn
    }
    
    //Search bar button animation
    fileprivate func performBlinkAnimation(){
        UINavigationBar.animate(withDuration: 1, delay: 0.25, options: .repeat, animations: {
            self.searchBtn.tintColor = UIColor.orange
        },completion: nil)
    }
    
    @objc fileprivate func triggerSearch() {
        //Insatantiate SearchResultsTableController table to show up when searchBtn is pressed
        let searchController = UISearchController(searchResultsController: searchResultsTable)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search your favorite place's address..."
        self.present(searchController, animated: true, completion: nil)
    }
    
    /* 
     NOTE: Locate on map with LocateOnThe Map protocol from 
     SearchResultsTableController (triggered when selecting address from table).
     In our case, we're going to use the autocomplete functionality to show details about
     a Place object opposed to show annotations.
     */
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String, andIndex: Int) {
        //Begin loading animation
        let activityView = UIView.init(frame: view.frame)
        let activitySpinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityView.backgroundColor = UIColor.gray
        activityView.alpha = 1
        view.addSubview(activityView)
        activitySpinner.center = view.center
        activitySpinner.startAnimating()
        activityView.addSubview(activitySpinner)
        
        //MARK: Uncomment and install GoogleMaps SDK for map annotation usage
        DispatchQueue.main.async(execute: {
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10)
            self.googleMaps.camera = camera
            
            marker.title = "Searched: \(title)"
            marker.map = self.googleMaps
        })
            
        //End loading animation
        activityView.removeFromSuperview()
        activitySpinner.stopAnimating()
        
        let placeDetailVC = PlaceDetailViewController()
        placeDetailVC.place = self.resultsArray[andIndex]
        searchResultsTable.dismiss(animated: false, completion: nil)
        self.navigationController?.pushViewController(placeDetailVC, animated: true)
    }
    
    // MARK: Update addresses in searchResultsTable
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        //When new character is added, remove all previous results in tableView
        self.resultsArray.removeAll()
        //Populate tableView with address strings as characters are added
        GooglePlacesService.sharedManager.searchForPlaceNamed(name: searchBar.text!, completionHandler: { (places) -> Void in
            self.resultsArray = places!
        })
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        resultText.text = error.localizedDescription
    }
}



