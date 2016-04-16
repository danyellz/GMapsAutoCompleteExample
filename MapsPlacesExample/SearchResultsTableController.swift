//
//  SearchResultsClient.swift
//  MapsPlacesExample
//
//  Created by TY on 4/9/16.
//  Copyright © 2016 Ty Daniels Dev. All rights reserved.
//
//Tableviewcontroller to hold autocomplete results when searchBar NSRange > 0

import UIKit
import GoogleMaps

//Protocol for delegating pin values of selected table row to be added to GMSMapView
protocol LocateOnTheMap{
    
    func locateWithLongitude(lon:Double, andLatitude lat:Double, andTitle title: String)
}

class SearchResultsTableController: UITableViewController {
    
    //searchResults holds all address strings relative to/closest to searchBar text input
    var searchResults: [String]!
    var delegate: LocateOnTheMap!
    //Call client for getting Google Places locations
    var addressSearchClient = AddressSearchClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make searchResults an array of location strings
        self.searchResults = Array()
        //Instantiate tableView cell identifier for reuse
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //Populate tableView with number of rows as results returned from search
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    //Add address string to corresponding tableView cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath)
        cell.textLabel?.text = self.searchResults[indexPath.row]
        return cell
    }
    
    //TableView cell selection for adding annotation to GMSMapView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Format string of selected cell before it is added to annotation marker
        let formattedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
        self.addressSearchClient.geoCodeAddress(formattedAddress, withCompletionHandler: {(status, success) in
            
            //When cell is selected prepare coordinates for map with Protocol
            dispatch_async(dispatch_get_main_queue(), {
            self.delegate.locateWithLongitude(self.addressSearchClient.formattedAddressLong, andLatitude: self.addressSearchClient.formattedAddressLat, andTitle: self.searchResults[indexPath.row])
            self.dismissViewControllerAnimated(true, completion: nil)
                
        })
    })
    }
    
    //Reload table view / add updated address strings into tableView as searchBar text changes
    func reloadDataWithArray(array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    //Create an alert for errors
    func showAlertMessage(message: String){
        let alertController = UIAlertController(title: "AutoCompleteDemo", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let closeAlertAction  = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) {(alertAction) -> Void in
    }
        alertController.addAction(closeAlertAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
