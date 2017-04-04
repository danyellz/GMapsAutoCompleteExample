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

class MainMapViewController: UIViewController, UISearchBarDelegate, LocateOnTheMap {
    /**
     * Called when an autocomplete request returns an error.
     * @param error the error that was received.
     */
    let cllocationManager = CLLocationManager()

    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var resultText: UILabel!
    
    fileprivate var searchTextView = UITextView()
    var searchResultsTable: SearchResultsTableController!
    var resultsArray = [GooglePlace]() {
        didSet {
            searchResultsTable.reloadDataWithArray(resultsArray)
        }
    }
    
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
    }
    
    //Add Google Maps to the view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.googleMaps = GMSMapView(frame: self.view.frame)
//        self.view.addSubview(self.googleMaps)
        
        searchResultsTable = SearchResultsTableController()
        searchResultsTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Begin search bar button animation
        DispatchQueue.main.async(execute: {
            self.performBlinkAnimation()
        })
    }
    
    fileprivate func setupView() {
        view.sv(searchTextView)
    }
    
    //Search bar button animation
    func performBlinkAnimation(){
        UINavigationBar.animate(withDuration: 1, delay: 0.25, options: .repeat, animations: {
            self.searchBtn.tintColor = UIColor.orange
        },completion: nil)
    }
    
    @IBAction func searchAddressBtn(_ sender: AnyObject) {
        //Insatantiate SearchResultsTableController table to show up when searchBtn is pressed
        let searchController = UISearchController(searchResultsController: searchResultsTable)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    //Locate on map with LocateOnThe Map protocol delegate created in SearchResultsTableController
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        //Begin loading animation
        let activityView = UIView.init(frame: view.frame)
        activityView.backgroundColor = UIColor.gray
        activityView.alpha = 1
        view.addSubview(activityView)
        
        let activitySpinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activitySpinner.center = view.center
        activitySpinner.startAnimating()
        activityView.addSubview(activitySpinner)

        //Prepare pin placement on GMapsview with addresses selected from table view
//        DispatchQueue.main.async(execute: {
//            let position = CLLocationCoordinate2DMake(lat, lon)
//            let marker = GMSMarker(position: position)
//            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10)
//            self.googleMaps.camera = camera
//            
//            marker.title = "Searched: \(title)"
//            marker.map = self.googleMaps
//            
//            //End loading animation
//            activityView.removeFromSuperview()
//            activitySpinner.stopAnimating()
//            
//        })
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
        resultText?.text = error.localizedDescription
    }
}



