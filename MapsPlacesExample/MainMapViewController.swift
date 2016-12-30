//
//  ViewController.swift
//  MapsPlacesExample
//
//  Created by TY on 4/9/16.
//  Copyright © 2016 Ty Daniels Dev. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MainMapViewController: UIViewController, UISearchBarDelegate, LocateOnTheMap, GMSAutocompleteFetcherDelegate {
    /**
     * Called when an autocomplete request returns an error.
     * @param error the error that was received.
     */

    let cllocationManager: CLLocationManager = CLLocationManager()

    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    @IBOutlet weak var resultText: UILabel!
    
    var googleMaps: GMSMapView!
    var addressSearchClient = AddressSearchClient()
    var searchResultsTable: SearchResultsTableController!
    var resultsArray = [String]()
    var gmsFetcher: GMSAutocompleteFetcher?
    
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
        
        //Set up autocomplete filter parameters for GMSAutoCompleteFetcher
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        
        //Add parameters to AutoCompleteFetcher
        gmsFetcher = GMSAutocompleteFetcher(bounds: nil, filter: filter)
        gmsFetcher?.delegate = self
    }
    
    //Add Google Maps to the view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.googleMaps = GMSMapView(frame: self.view.frame)
        self.view.addSubview(self.googleMaps)
        
        searchResultsTable = SearchResultsTableController()
        searchResultsTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Begin search bar button animation
        DispatchQueue.main.async(execute: {
        self.performAnimation()
        })
    }
    
    //Search bar button animation
    func performAnimation(){
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
    
    //Locate on map with LocateOnTheMap protocol delegate created in SearchResultsTableController
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
        DispatchQueue.main.async(execute: {
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10)
            self.googleMaps.camera = camera
            
            marker.title = "Searched: \(title)"
            marker.map = self.googleMaps
            
            //End loading animation
            activityView.removeFromSuperview()
            activitySpinner.stopAnimating()
            
        })
    }
    
    //Call GMSAutoCompleteFetcherDelegate extension when GMSFetcher text is changed (searchbar)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        //When new character is added, remove all previous results in tableView
        self.resultsArray.removeAll()
        
        //Populate tableView with address strings as characters are added
        gmsFetcher?.sourceTextHasChanged(searchText)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        
        for prediction in predictions {
            
            //Format strings to be added to tableView cells
            if let prediction = prediction as GMSAutocompletePrediction!{
                self.resultsArray.append(prediction.attributedFullText.string)
            }
        }
        
        //Add most similar addresses from searchbar to tableview cells
        self.searchResultsTable.reloadDataWithArray(self.resultsArray)
        print(resultsArray)
    }
    func didFailAutocompleteWithError(_ error: Error) {
        resultText?.text = error.localizedDescription
    }

}

//Implement GMSAutoCompleteFetcherDelegate protocol to handle custom string prediction



